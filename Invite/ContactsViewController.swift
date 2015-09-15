//
//  ContactsViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 5/2/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit
import AddressBook

class Contact {
    let name: String?
    let lastName: String?
    var emails = [String]()
    init(name: String?, lastName: String?) {
        if let name = name {
            self.name = name
        } else {
            self.name = ""
        }
        if let lastName = lastName {
            self.lastName = lastName
        } else {
            self.lastName = ""
        }
    }
}

@objc(ContactsViewController) class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: ContactsViewControllerDelegate?

    var adbk: ABAddressBook!
    
    var tableData = [Contact]()
    
    var selectedEmails = [String]()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        if !self.determineStatus() {
            print("not authorized")
            return
        } else {
            createTableDataFromContacts()
        }

    }
    
    func createTableDataFromContacts()
    {
        let people = ABAddressBookCopyArrayOfAllPeople(adbk).takeRetainedValue() as NSArray as [ABRecord]
        for person: ABRecordRef in people {
            let name = ABRecordCopyCompositeName(person)?.takeRetainedValue() as? String
            let lastName = ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeRetainedValue() as? String
            let emailsRef: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue() as ABMultiValueRef
            if ABMultiValueGetCount(emailsRef) > 0 {
                let emails: NSArray = ABMultiValueCopyArrayOfAllValues(emailsRef).takeUnretainedValue() as NSArray
                var contactEmails = [String]()
                let contact = Contact(name: name, lastName: lastName)
                for email in emails {
                    if (email as! String).rangeOfString("@") != nil {
                        contactEmails.append(email as! String)
                    }
                }
                contact.emails = contactEmails
                tableData.append(contact)
            }
        }
        
        tableData = tableData.sort { $0.lastName < $1.lastName }
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews()
    {
        tableHeaderView()
    }
  
    func tableHeaderView()
    {
        let header = UIView(frame: CGRectMake(0, 0, view.bounds.size.width, 1000))
        header.backgroundColor = UIColor.clearColor()

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.inviteQuestionColor()
        label.textAlignment = .Left
        label.numberOfLines = 0
        
        let att = NSMutableAttributedString()
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6
        att.appendAttributedString(NSAttributedString(string: "These are the email addresses that we were able to pull from your Contacts app. If you invite one of these friends, they will show up under Previously Invited Friends the next time you create an event.", attributes: [NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(16), NSParagraphStyleAttributeName: style]))
        
        label.attributedText = att
        header.addSubview(label)

        var leading: CGFloat = 15
        if (SDiPhoneVersion.deviceSize() == DeviceSize.iPhone47inch || SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch) {
            leading = 20
        }
        
        let views = ["label": label]
        let metrics = ["leading": leading]
        
        header.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-leading-[label]-leading-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        header.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-34-[label]-14-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        
        let headerWidthConstraint = NSLayoutConstraint(item: header, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: view.bounds.size.width)
        header.addConstraint(headerWidthConstraint)
        header.setNeedsLayout()
        header.layoutIfNeeded()
        let height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        header.removeConstraint(headerWidthConstraint)
        header.frame = CGRectMake(0, 0, view.bounds.size.width, height)
        header.translatesAutoresizingMaskIntoConstraints = true
        tableView.tableHeaderView = header
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
                        self.createTableDataFromContacts()
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
    
    // MARK: - UITableView
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor.inviteTableHeaderColor()
        headerView.textLabel!.font = UIFont.inviteTableHeaderFont()
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    {
        let footerView = view as! UITableViewHeaderFooterView
        footerView.textLabel!.font = UIFont.inviteTableFooterFont()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return tableData[section].name
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (tableData[section] as Contact).emails.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(BASIC_CELL_IDENTIFIER, forIndexPath: indexPath) as! BasicCell
        let name = tableData[indexPath.section].name
        cell.textLabel?.text = tableData[indexPath.section].emails[indexPath.row]
        cell.accessoryView = UIImageView(image: UIImage(named: selectedEmails.contains((name!)) ? "list_selected" : "list_select"))
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selected = UIImageView(image: UIImage(named: "list_selected"))
        let select = UIImageView(image: UIImage(named: "list_select"))
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! BasicCell
        let email = tableData[indexPath.section].emails[indexPath.row]
        if (selectedEmails.contains(email)) {
            selectedEmails.removeObject(email)
            cell.accessoryView = select
        } else {
            selectedEmails.append(email)
            cell.accessoryView = selected
        }
        print(selectedEmails)
    }
    
    @IBAction func selectEmails(sender: AnyObject?) {
        if let delegate = delegate {
            delegate.contactsViewController(self, didSelectEmailAddresses: selectedEmails)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}

@objc protocol ContactsViewControllerDelegate {
    
    func contactsViewController(vc: ContactsViewController, didSelectEmailAddresses emails: [String])
    
}

extension Array {
    mutating func removeObject<U: Equatable>(object: U) -> Bool {
        for (idx, objectToCompare) in self.enumerate() {
            if let to = objectToCompare as? U {
                if object == to {
                    self.removeAtIndex(idx)
                    return true
                }
            }
        }
        return false
    }
}
