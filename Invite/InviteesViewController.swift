//
//  InviteesViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 9/24/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit
import AddressBook

class Friend
{
    let fullName: String?
    let lastName: String?
    let email: String
    let pfObject: PFObject?
    
    init(fullName: String?, lastName: String?, email: String, pfObject: PFObject?) {
        if let fullName = fullName {
            self.fullName = fullName
        } else {
            self.fullName = nil
        }
        if let lastName = lastName {
            self.lastName = lastName
        } else {
            self.lastName = nil
        }
        self.email = email
        if let pfObject = pfObject {
            self.pfObject = pfObject
        } else {
            self.pfObject = nil
        }
    }
}

@objc(InviteesViewController) class InviteesViewController: UIViewController, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, InputCellDelegate, UISearchBarDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController!
    
    private var recentFriends = [Friend]()
    private var allFriends = [Friend]()
    private var groupedFriends = [String: [Friend]]()
    private var groupedFriendsKeys = [String]()

    private var selectedFriends = [Friend]()
    
    private var textViewText = ""
    private var showInviteFriendsOnly = false
    private var savedSearchText = ""
    
    private var eventInvitees = [PFObject]()
    private var eventEmails = [String]()
    private var preEmails = [String]()

    var adbk: ABAddressBook!

    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.title = "Event Invitees"

        configureSearchController()
        
        buildPreEmails()
        reloadFriends()
        
        self.tableView.tableHeaderView = tableHeaderView()
        self.tableView.sectionIndexColor = UIColor.inviteBlueColor()
        self.tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        self.tableView.reloadSectionIndexTitles()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        self.definesPresentationContext = true
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func configureSearchController()
    {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.scopeButtonTitles = ["Invite Friends", "All Friends"]
        self.searchController.searchBar.selectedScopeButtonIndex = 1
        self.searchController.searchBar.placeholder = "Search for a friend to invite"
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
        self.searchController.searchBar.autocapitalizationType = UITextAutocapitalizationType.None
        self.searchController.searchBar.autocorrectionType = UITextAutocorrectionType.No
        self.searchController.searchBar.spellCheckingType = UITextSpellCheckingType.No
    }

    // MARK: - UITableView
    
    func tableHeaderView() -> UIView
    {
        let view = UIView(frame: CGRectMake(0, 0, 0, 144))
        view.backgroundColor = UIColor.clearColor()
        
        let searchBarView = UIView()
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        searchBarView.addSubview(searchController.searchBar)
        view.addSubview(searchBarView)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.inviteQuestionColor()
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.font = UIFont.inviteQuestionFont()
        label.text = "Who would you like to invite to this event?"
        view.addSubview(label)
        
        let views = ["bar": searchBarView, "label": label]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bar]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-50-[label]-50-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bar(44)]-34-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        return view
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor.inviteTableHeaderColor()
        headerView.textLabel!.font = UIFont.inviteTableHeaderFont()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0 {
            return "New Friends"
        } else if section == 1 {
            if self.recentFriends.count > 0 {
                return "Recently Invited Friends"
            } else {
                return nil
            }
        }

        let title = self.groupedFriendsKeys[section - 2]
        return title == "@" ? "Email Only" : title
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.groupedFriendsKeys.count + 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0 {
            return 1
        } else if section == 1 {
            return self.recentFriends.count > 0 ? self.recentFriends.count : 0
        }
        return self.groupedFriends[self.groupedFriendsKeys[section - 2]]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(INPUT_CELL_IDENTIFIER, forIndexPath: indexPath) as! InputCell
            cell.delegate = self
            cell.guidance.text = "Tap to enter your friends' email addresses"
            cell.guidance.hidden = !(self.textViewText == "")
            cell.guidance.font = UIFont.inviteTableSmallFont()
            cell.guidance.textColor = UIColor.inviteTableLabelColor()
            cell.textView.text = self.textViewText
            cell.textView.textColor = UIColor.inviteTableHeaderColor()
            cell.textView.font = UIFont.inviteTableSmallFont()
            addAccessoryViewToKeyboardForTextField(cell.textView)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(PROFILE_CELL_IDENTIFIER, forIndexPath: indexPath) as! ProfileCell
            let friend = self.groupedFriends[self.groupedFriendsKeys[indexPath.section - 2]]![indexPath.row]
            let friendSelected = selectedFriendsContainsFriend(friend)

            if friend.fullName == nil {
                cell.leadingFlexLabelConstraint.constant = -30
                cell.nameLabel.hidden = true
                cell.flexLabel.text = friend.email
                cell.separatorInset = UIEdgeInsetsMake(0, SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15, 0, 0)
            } else if friend.pfObject != nil {
                cell.leadingFlexLabelConstraint.constant = 10
                cell.nameLabel.hidden = true
                cell.flexLabel.text = friend.fullName
                cell.separatorInset = UIEdgeInsetsMake(0, SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 + 40 : 15 + 40, 0, 0)
            } else {
                cell.leadingFlexLabelConstraint.constant = 120
                cell.nameLabel.hidden = false
                cell.nameLabel.text = friend.fullName
                cell.flexLabel.text = friend.email
                cell.separatorInset = UIEdgeInsetsMake(0, SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 + 40 : 15 + 40, 0, 0)
            }
            
            cell.accessoryView = UIView(frame: CGRectMake(0, 0, 10, 10))
            cell.accessoryView?.backgroundColor = UIColor.inviteBackgroundSlateColor()
            cell.accessoryView?.clipsToBounds = true
            cell.accessoryView?.layer.cornerRadius = 5
            
            cell.profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
            cell.profileImageView.layer.borderWidth = 0

            if friend.pfObject != nil && friend.pfObject![FACEBOOK_ID_KEY] != nil {
                cell.profileImageView.sd_setImageWithURL(NSURL(string: "https://graph.facebook.com/\(friend.pfObject![FACEBOOK_ID_KEY])/picture?type=square&width=150&height=150"))
                cell.profileImageView.hidden = false
            } else {
                cell.profileImageView.hidden = true
            }

            if friendSelected {
                selectCell(cell, friend: friend)
            } else {
                unselectCell(cell, friend: friend)
            }
            
            return cell
        }
    }
    
    func selectCell(cell: ProfileCell, friend: Friend)
    {
        cell.backgroundColor = UIColor.inviteLightSlateColor()
        cell.accessoryView?.backgroundColor = UIColor.whiteColor()
        cell.nameLabel.textColor = UIColor.whiteColor()
        cell.flexLabel.textColor = UIColor.whiteColor()
        cell.profileImageView.layer.borderWidth = 1
    }
    
    func unselectCell(cell: ProfileCell, friend: Friend)
    {
        cell.backgroundColor = UIColor.whiteColor()
        cell.accessoryView?.backgroundColor = UIColor.inviteBackgroundSlateColor()
        cell.nameLabel.textColor = UIColor.inviteTableLabelColor()
        cell.flexLabel.textColor = friend.fullName != nil && friend.pfObject == nil ? UIColor.inviteGrayColor() : UIColor.inviteTableLabelColor()
        cell.profileImageView.layer.borderWidth = 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == 0 {
            return
        } else {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! ProfileCell
            let friend = self.groupedFriends[self.groupedFriendsKeys[indexPath.section - 2]]![indexPath.row]
            if selectedFriendsContainsFriend(friend) {
                removeFriend(friend)
                unselectCell(cell, friend: friend)
            } else {
                self.selectedFriends.append(friend)
                selectCell(cell, friend: friend)
            }
        }
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    {
        let footerView = view as! UITableViewHeaderFooterView
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        let att = NSMutableAttributedString(string: NSLocalizedString("invitees_newfriends_footer", comment: ""), attributes: [NSFontAttributeName: UIFont.inviteTableFooterFont(), NSParagraphStyleAttributeName: style])
        footerView.textLabel!.attributedText = att
    }

    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        if section == 0 {
            return NSLocalizedString("invitees_newfriends_footer", comment: "")
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if section == 0 {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 4
            let text: NSString = NSLocalizedString("invitees_newfriends_footer", comment: "")
            return text.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - (self.tableView.separatorInset.left * 2), CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: [NSFontAttributeName: UIFont.inviteTableFooterFont(), NSParagraphStyleAttributeName: style], context: nil).size.height + 20
        }
        return 0
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]?
    {
        var extraSections = ["+"]
        if self.recentFriends.count > 0 {
            extraSections.append("R")
        }
        extraSections.append(" ")
        
        return extraSections + self.groupedFriendsKeys
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
    {
        if self.recentFriends.count > 0 && index > 2 {
            return index - 1
        }
        if self.recentFriends.count == 0 && index > 1 {
            return index - 1
        }
        return index
    }
    
    // MARK: - UITextView
    
    func addAccessoryViewToKeyboardForTextField(textField: UITextView)
    {
        let doneToolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 50))
        doneToolbar.barStyle = .BlackTranslucent
        doneToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Dismiss Keyboard", style: .Done, target: self, action: "dismissKeyboard"),
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        ]
        doneToolbar.sizeToFit()
        textField.inputAccessoryView = doneToolbar
    }
    
    func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    // MARK: - Actions

    @IBAction func cancel(sender: UIBarButtonItem)
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func save(sender: UIBarButtonItem)
    {
        AppDelegate.protoEvent().savedEmailInput = self.textViewText
        convertFriendsForSave()
        AppDelegate.addToProtoEventInvitees(self.eventInvitees, emails: self.eventEmails)
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - InputCellDelegate
    
    func textViewDidChange(textView: UITextView)
    {
        self.textViewText = textView.text
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
    {
        reloadFriends()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        reloadFriends()
    }
    
    // MARK: - UISearchControllerDelegate
    
    func didDismissSearchController(searchController: UISearchController)
    {
        reloadFriends()
    }
    
    // MARK: - Reload Friends
    
    private func showInviteFriends()
    {
        self.showInviteFriendsOnly = true
        addExistingFriends()
        sortFriends()
        breakFriendsIntoGroups()
        self.tableView.reloadData()
    }
    
    private func showAllFriends()
    {
        self.showInviteFriendsOnly = false
        if !self.determineStatus() {
            // Not authorized
            // We still want to add existing friends...
            addExistingFriends()
            sortFriends()
            breakFriendsIntoGroups()
            self.tableView.reloadData()
        } else {
            addAllFriendsAndReload()
        }
    }
    
    private func reloadFriends()
    {
        self.allFriends.removeAll()
        if self.searchController.searchBar.selectedScopeButtonIndex == 0 {
            showInviteFriends()
        } else {
            showAllFriends()
        }
    }
    
    private func buildPreEmails()
    {
        var event: Event?
        if AppDelegate.hasProtoEvent() {
            event = AppDelegate.protoEvent()
        } else if AppDelegate.hasEventToDisplay() {
            event = AppDelegate.eventToDisplay()
        }
        if event == nil {
            return
        }
        if let invitees = event!.invitees {
            for invitee in invitees {
                let i = invitee as! PFObject
                self.preEmails.append(i[EMAIL_KEY] as! String)
            }
        }
        if let emails = event!.emails as? [String] {
            for email in emails {
                let e = email
                self.preEmails.append(e)
            }
            self.textViewText = AppDelegate.protoEvent().savedEmailInput
        }
    }
    
    func addExistingFriends()
    {
        for friend in AppDelegate.friends() {
            let f = friend as! PFObject
            if !self.showInviteFriendsOnly || (self.showInviteFriendsOnly && f[FACEBOOK_ID_KEY] != nil) {
                
                let searchText = self.searchController.searchBar.text
                let fullName = f[FULL_NAME_KEY] as? String
                let email = f[EMAIL_KEY] as! String
                let emailContainsText = email.uppercaseString.containsString(searchText!.uppercaseString)
                
                let friend = Friend(fullName: fullName, lastName: f[LAST_NAME_KEY] as? String, email: email, pfObject: f)
                
                if let fullName = fullName {
                    let nameContainsText = fullName.containsString(searchText!)
                    if searchText == "" || (searchText != "" && (nameContainsText || emailContainsText)) {
                        self.allFriends.append(friend)
                    }
                } else {
                    if searchText == "" || (searchText != "" && emailContainsText) {
                        self.allFriends.append(friend)
                    }
                }
                
                if self.preEmails.contains(email) {
                    self.selectedFriends.append(friend)
                }
            }
        }
    }
    
    private func breakFriendsIntoGroups()
    {
        self.groupedFriends.removeAll()
        self.groupedFriendsKeys.removeAll()
        
        var currentTitle = ""
        for friend in self.allFriends {
            if friend.lastName != nil {
                let index = friend.lastName!.startIndex
                var letter = "\(friend.lastName![index])"
                letter = letter.uppercaseString
                if currentTitle != letter {
                    currentTitle = letter
                    self.groupedFriendsKeys.append(currentTitle)
                    self.groupedFriends[currentTitle] = [Friend]()
                }
                self.groupedFriends[currentTitle]?.append(friend)
            } else {
                if currentTitle != "@" {
                    currentTitle = "@"
                    self.groupedFriendsKeys.append(currentTitle)
                    self.groupedFriends[currentTitle] = [Friend]()
                }
                self.groupedFriends[currentTitle]?.append(friend)
            }
        }
    }
    
    func determineStatus() -> Bool {
        let status = ABAddressBookGetAuthorizationStatus()
        switch status {
        case .Authorized:
            return self.createAddressBook()
        case .NotDetermined:
            var ok = false
            ABAddressBookRequestAccessWithCompletion(nil) {
                (granted:Bool, err:CFError!) in
                dispatch_async(dispatch_get_main_queue()) {
                    if granted {
                        ok = self.createAddressBook()
                        self.addAllFriendsAndReload()
                    }
                }
            }
            if ok == true {
                return true
            }
            self.adbk = nil
            return false
        case .Restricted:
            self.adbk = nil
            return false
        case .Denied:
            self.adbk = nil
            return false
        }
    }
    
    func createAddressBook() -> Bool {
        if self.adbk != nil {
            return true
        }
        var err: Unmanaged<CFError>? = nil
        let adbk: ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if adbk == nil {
            print(err)
            self.adbk = nil
            return false
        }
        self.adbk = adbk
        return true
    }
    
    func addContactsAsFriends()
    {
        let people = ABAddressBookCopyArrayOfAllPeople(adbk).takeRetainedValue() as NSArray as [ABRecord]
        for person: ABRecordRef in people {
            let firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
            let middleName = ABRecordCopyValue(person, kABPersonMiddleNameProperty)?.takeRetainedValue() as? String
            let lastName = ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeRetainedValue() as? String
            var fullName = ""
            if let firstName = firstName {
                fullName = firstName
            }
            if let middleName = middleName {
                fullName += " \(middleName)"
            }
            if let lastName = lastName {
                fullName += " \(lastName)"
            }
            let emailsRef: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue() as ABMultiValueRef
            if ABMultiValueGetCount(emailsRef) > 0 {
                let emails: NSArray = ABMultiValueCopyArrayOfAllValues(emailsRef).takeUnretainedValue() as NSArray
                for email in emails {
                    
                    if (email as! String).rangeOfString("@") != nil {
                        let searchText = self.searchController.searchBar.text
                        let nameContainsText = fullName.uppercaseString.containsString(searchText!.uppercaseString)
                        let emailContainsText = email.uppercaseString.containsString(searchText!.uppercaseString)
                        
                        let friend = Friend(fullName: fullName, lastName: lastName, email: email as! String, pfObject: nil)

                        if searchText == "" || (searchText != "" && (nameContainsText || emailContainsText)) {
                            self.allFriends.append(friend)
                        }
                        if self.preEmails.contains(email as! String) {
                            self.selectedFriends.append(friend)
                        }
                    }
                }
            }
        }
    }
    
    func addAllFriendsAndReload()
    {
        addContactsAsFriends()
        addExistingFriends()
        sortFriends()
        breakFriendsIntoGroups()
        self.tableView.reloadData()
    }
    
    private func sortFriends()
    {
        self.allFriends = self.allFriends.sort { $0.lastName < $1.lastName }
    }
    
    // MARK: - Other
    
    private func selectedFriendsContainsFriend(aFriend: Friend) -> Bool
    {
        for friend in self.selectedFriends {
            if friend.email == aFriend.email {
                return true
            }
        }
        return false
    }

    private func removeFriend(friend: Friend)
    {
        self.selectedFriends = self.selectedFriends.filter({$0.email != friend.email})
    }

    private func convertFriendsForSave()
    {
        // Email addresses from new friends
        if self.textViewText != "" {
            let components = self.textViewText.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) as NSArray
            let string = components.componentsJoinedByString("")
            self.eventEmails = string.componentsSeparatedByString(",")
        }
        
        // Email addresses and invitees from selected friends
        for friend in self.selectedFriends {
            if friend.pfObject != nil {
                // Invitee
                self.eventInvitees.append(friend.pfObject!)
            } else {
                // Email
                self.eventEmails.append(friend.email)
            }
        }
    }
    
    // MARK: - Notifications
    
    func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: tableView.contentInset.top, left: 0, bottom: keyboardSize.height, right: 0)
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        UIView.animateWithDuration(0.35, animations: {
            let contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, 0.0, 0.0)
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
        })
    }
}
