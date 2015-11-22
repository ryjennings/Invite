//
//  SettingsViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 4/22/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

enum RemindMe: Int {
    case UseDefault = 0
    case AtTimeOfEvent
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
    
    override func viewDidLoad()
    {
        if UserDefaults.objectForKey("DefaultRemindMe") == nil {
            UserDefaults.setInteger(RemindMe.FifteenMinutesBefore.rawValue, key: "DefaultRemindMe")
        }
    }
    
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
            if nextValue > RemindMe.TwoHoursBefore.rawValue {
                nextValue = RemindMe.AtTimeOfEvent.rawValue
            }
            UserDefaults.setInteger(nextValue, key: "DefaultRemindMe")
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! BasicCell
            cell.detailTextLabel?.text = textForCurrentRemindMe()
        }
    }
    
    func textForCurrentRemindMe() -> String
    {
        switch RemindMe(rawValue: UserDefaults.integerForKey("DefaultRemindMe"))! {
        case .UseDefault: return ""
        case .AtTimeOfEvent: return "At time of event"
        case .FiveMinutesBefore: return "5 minutes before"
        case .FifteenMinutesBefore: return "15 minutes before"
        case .ThirtyMinutesBefore: return "30 minutes before"
        case .OneHourBefore: return "1 hour before"
        case .TwoHoursBefore: return "2 hours before"
        }
    }
    
    @IBAction func logout(button: UIBarButtonItem)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(USER_LOGGED_OUT_NOTIFICATION, object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
