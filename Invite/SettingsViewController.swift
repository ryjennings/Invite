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
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        var headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel.textColor = UIColor.inviteTableHeaderColor()
        headerView.textLabel.font = UIFont.inviteTableHeaderFont()
    }
    
//    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
//    {
//        var footerView = view as! UITableViewHeaderFooterView
//        footerView.textLabel.font = UIFont.inviteTableFooterFont()
//    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch (section) {
        case SettingsSection.SendMeEmail.rawValue:
            return "Settings"
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        return titleForSection(section)
    }
    
//    - (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
//    {
//    UITableViewHeaderFooterView *footerView = (UITableViewHeaderFooterView *)view;
//    
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    style.lineSpacing = 4;
//    
//    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"invitees_newfriends_footer", nil) attributes:@{NSFontAttributeName: [UIFont inviteTableFooterFont], NSParagraphStyleAttributeName: style}];
//    
//    footerView.textLabel.attributedText = att;
//    }

    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    {
        var footerView = view as! UITableViewHeaderFooterView
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        let att = NSMutableAttributedString(string: titleForSection(section), attributes: [NSFontAttributeName: UIFont.inviteTableFooterFont(), NSParagraphStyleAttributeName: style])
        footerView.textLabel.attributedText = att
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        let size = CGSizeMake(self.view.frame.size.width - (tableView.separatorInset.left * 2), CGFloat.max)
        let options: NSStringDrawingOptions = .UsesLineFragmentOrigin | .UsesFontLeading
        return (titleForSection(section) as NSString).boundingRectWithSize(size, options: options, attributes: [NSFontAttributeName: UIFont.inviteTableFooterFont(), NSParagraphStyleAttributeName: style], context: nil).size.height + CGFloat(kFooterPadding)
    }
    
    func titleForSection(section: Int) -> String
    {
        switch section {
        case SettingsSection.SendMeEmail.rawValue:
            return "Turn this on if you want to receive the event email that's created when you send a new event."
        case SettingsSection.ShowAvailability.rawValue:
            return "If someone tries to invite you to an event that conflicts with an event you're already scheduled to attend, your name will show up as a conflict. Turn this on to also list the event name and event time within the conflict."
        case SettingsSection.RemoveEventsAfterExpire.rawValue:
            return "Old events will automatically be deleted 30 days after an event ends. Turn this on to delete them the day after the event ends."
        default:
            return ""
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
