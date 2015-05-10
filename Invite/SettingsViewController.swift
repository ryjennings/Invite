//
//  SettingsViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 4/22/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

enum SettingsSection: Int {
    case SendMeEmail = 0
    case ShowAvailability
    case RemoveEventsAfterExpire
    case Count
}

@objc(SettingsViewController) class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func close(sender: UIBarButtonItem)
    {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
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
        var cell = tableView.dequeueReusableCellWithIdentifier(TOGGLE_CELL_IDENTIFIER, forIndexPath: indexPath) as! ToggleCell
        
        if let section = SettingsSection(rawValue: indexPath.section) {
            switch section {
            case .SendMeEmail:
                cell.key = kSendMeEmail
                cell.label.text = "Send me email for events I create"
            case .ShowAvailability:
                cell.key = kShowAvailability
                cell.label.text = "Show other people my availability"
            case .RemoveEventsAfterExpire:
                cell.key = kRemoveEventsAfterExpire
                cell.label.text = "Remove events after they expire"
            default:
                cell.key = ""
            }
        }
        
        return cell
    }
}
