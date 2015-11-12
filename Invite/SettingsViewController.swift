//
//  SettingsViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 4/22/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

enum RemindMe: Int {
    case AtTimeOfEvent = 0
    case FiveMinutesBefore
    case FifteenMinutesBefore
    case ThirtyMinutesBefore
    case OneHourBefore
    case TwoHoursBefore
}

enum SettingsSection: Int {
    case DefaultRemindMe = 0
    case Count
}

@objc(SettingsViewController) class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func close(sender: UIBarButtonItem)
    {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor.inviteTableHeaderColor()
        headerView.textLabel!.font = UIFont.inviteTableHeaderFont()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch (section) {
        case SettingsSection.DefaultRemindMe.rawValue:
            return "Remind Me"
        default:
            return nil
        }
    }
    
//    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String?
//    {
//        return titleForSection(section)
//    }
    
//    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
//    {
//        let footerView = view as! UITableViewHeaderFooterView
//        let style = NSMutableParagraphStyle()
//        style.lineSpacing = 4
//        let att = NSMutableAttributedString(string: titleForSection(section), attributes: [NSFontAttributeName: UIFont.inviteTableFooterFont(), NSParagraphStyleAttributeName: style])
//        footerView.textLabel!.attributedText = att
//    }

//    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
//    {
//        let style = NSMutableParagraphStyle()
//        style.lineSpacing = 4
//        let size = CGSizeMake(self.view.frame.size.width - (tableView.separatorInset.left * 2), CGFloat.max)
//        let options: NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
//        return (titleForSection(section) as NSString).boundingRectWithSize(size, options: options, attributes: [NSFontAttributeName: UIFont.inviteTableFooterFont(), NSParagraphStyleAttributeName: style], context: nil).size.height + CGFloat(kFooterPadding)
//    }
    
//    func titleForSection(section: Int) -> String
//    {
//        switch section {
//        case SettingsSection.SendMeEmail.rawValue:
//            return "Turn this on if you want to receive the event email that's created when you send a new event."
////        case SettingsSection.ShowAvailability.rawValue:
////            return "If someone tries to invite you to an event that conflicts with an event you're already scheduled to attend, your name will show up as a conflict. Turn this on to also list the event name and event time within the conflict."
////        case SettingsSection.RemoveEventsAfterExpire.rawValue:
////            return "Old events will automatically be deleted 30 days after an event ends. Turn this on to delete them the day after the event ends."
//        default:
//            return ""
//        }
//    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return SettingsSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
//        let cell = tableView.dequeueReusableCellWithIdentifier(TOGGLE_CELL_IDENTIFIER, forIndexPath: indexPath) as! ToggleCell
//        
//        if let section = SettingsSection(rawValue: indexPath.section) {
//            switch section {
//            case .SendMeEmail:
//                cell.key = kSendMeEmail
//                cell.label.text = "Send me email for events I create"
////            case .ShowAvailability:
////                cell.key = kShowAvailability
////                cell.label.text = "Show other people my availability"
////            case .RemoveEventsAfterExpire:
////                cell.key = kRemoveEventsAfterExpire
////                cell.label.text = "Remove events after they expire"
//            default:
//                cell.key = ""
//            }
//        }
//        
//        return cell
        
        if UserDefaults.objectForKey("DefaultRemindMe") == nil {
            UserDefaults.setInteger(RemindMe.FifteenMinutesBefore.rawValue, key: "DefaultRemindMe")
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(BASIC_RIGHT_CELL_IDENTIFIER, forIndexPath: indexPath) as! BasicCell
        cell.textLabel?.font = UIFont.inviteTableSmallFont()
        cell.textLabel?.textColor = UIColor.inviteTableHeaderColor()
        
        cell.textLabel?.text = "Default remind me"
        cell.detailTextLabel?.font = UIFont.inviteTableSmallFont()
        cell.detailTextLabel?.textColor = UIColor.inviteGrayColor()
        cell.detailTextLabel?.text = textForCurrentRemindMe()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == SettingsSection.DefaultRemindMe.rawValue {
            var nextValue = UserDefaults.integerForKey("DefaultRemindMe")
            nextValue++
            if nextValue == 6 {
                nextValue = 0
            }
            UserDefaults.setInteger(nextValue, key: "DefaultRemindMe")
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! BasicCell
            cell.detailTextLabel?.text = textForCurrentRemindMe()
        }
    }
    
    func textForCurrentRemindMe() -> String
    {
        switch UserDefaults.integerForKey("DefaultRemindMe") {
        case 0: return "At time of event"
        case 1: return "5 minutes before"
        case 2: return "15 minutes before"
        case 3: return "30 minutes before"
        case 4: return "1 hour before"
        case 5: return "2 hours before"
        default: return ""
        }
    }
    
    @IBAction func logout(button: UIBarButtonItem)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(USER_LOGGED_OUT_NOTIFICATION, object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
