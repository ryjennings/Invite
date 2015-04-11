//
//  TitleViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 4/10/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

enum TitleSection: Int {
    case Title = 0
    case Description
    case Count
}

@objc(TitleViewController) class TitleViewController: UIViewController, InputCellDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    
    var inputText: [String]!
    
    override func viewDidLoad()
    {
        inputText = [String](count: TitleSection.Count.rawValue, repeatedValue: "")
        navigationItem.titleView = ProgressView(frame: CGRectMake(0, 0, 150, 15), step: 1, steps: 5)
        tableView.tableHeaderView = tableHeaderView()
        
        nextButton.layer.cornerRadius = CGFloat(kCornerRadius)
        nextButton.clipsToBounds = true
        nextButton.titleLabel!.font = UIFont.inviteButtonTitleFont()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func tableHeaderView() -> UIView
    {
        var view = UIView(frame: CGRectMake(0, 0, 0, 100))
        view.backgroundColor = UIColor.clearColor()
        
        var label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.inviteQuestionColor()
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.font = UIFont.inviteQuestionFont()
        label.text = "Let's create a new event!\nGive us some details."
        view.addSubview(label)
        
        let views = ["label": label]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[label]-15-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-34-[label]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        
        return view
    }

    // MARK: - UITableView
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        var headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel.textColor = UIColor.inviteTableHeaderColor()
        headerView.textLabel.font = UIFont.inviteTableHeaderFont()
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    {
        var footerView = view as! UITableViewHeaderFooterView
        footerView.textLabel.font = UIFont.inviteTableFooterFont()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch (section) {
        case TitleSection.Title.rawValue:
            return "Title"
        case TitleSection.Description.rawValue:
            return "Description"
        default:
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return TitleSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch (section) {
        case TitleSection.Title.rawValue:
            return 1
        case TitleSection.Description.rawValue:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
//        if (indexPath.section == TitleSection.Title.rawValue) {
        
            let text = inputText[indexPath.row] as String
            var cell = tableView.dequeueReusableCellWithIdentifier(INPUT_CELL_IDENTIFIER, forIndexPath: indexPath) as! InputCell
            cell.delegate = self
            cell.placeholderLabel.text = "Tap here to enter a title"
            cell.placeholderLabel.hidden = Bool(count(text))
            cell.textView.tag = indexPath.section
            cell.textView.text = text
            cell.textView.font = UIFont.inviteTableLabelFont()
            cell.textView.textContainer.lineFragmentPadding = 0
            cell.textView.textContainerInset = UIEdgeInsetsMake(1, 0, 0, 0)
            cell.selectionStyle = .None
            return cell
            
//        } else {
//            
//            var cell = tableView.dequeueReusableCellWithIdentifier(BASIC_CELL_IDENTIFIER, forIndexPath: indexPath) as! UITableViewCell
//            cell.accessoryType = indexPath.row == savedLocationsIndex ? .Checkmark : .None
//            if (indexPath.row == 0) {
//                cell.textLabel?.text = "Use current location"
//            } else {
//                let location = AppDelegate.locations()[indexPath.row - 1] as! PFObject
//                let address = location.objectForKey(LOCATION_ADDRESS_KEY) as? String
//                let nickname = location.objectForKey(LOCATION_NICKNAME_KEY) as? String
//                cell.textLabel?.text = nickname ?? address
//            }
//            return cell
//            
//        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let text = inputText[indexPath.section] as NSString
        let textViewWidth = self.view.frame.size.width - 30
        let frame = text.boundingRectWithSize(CGSizeMake(textViewWidth, CGFloat.max), options: (.UsesLineFragmentOrigin | .UsesFontLeading), attributes: [NSFontAttributeName: UIFont.inviteTableLabelFont()], context: nil)
        return frame.size.height + 25
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {

    }
    
    // MARK: - InputCellDelegate
    
    func textViewDidChange(textView: UITextView)
    {
        inputText[textView.tag] = textView.text
        tableView.beginUpdates()
        tableView.endUpdates()
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
