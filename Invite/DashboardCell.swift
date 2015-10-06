//
//  DashboardCell.swift
//  Invite
//
//  Created by Ryan Jennings on 10/5/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

@objc(DashboardCell) class DashboardCell: UITableViewCell
{
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var endHourLabel: UILabel!
    @IBOutlet weak var endDayLabel: UILabel!
    @IBOutlet weak var invitedLabel: UILabel!
    @IBOutlet weak var profileImageView1: ProfileImageView!
    @IBOutlet weak var profileImageView2: ProfileImageView!
    @IBOutlet weak var profileImageView3: ProfileImageView!
    @IBOutlet weak var profileImageView4: ProfileImageView!
    
    var event: PFObject! {
        didSet {
            configureForEvent()
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.titleLable.textColor = UIColor.inviteTableHeaderColor()
        self.titleLable.font = UIFont.proximaNovaRegularFontOfSize(20)
        self.titleLable.numberOfLines = 1
        
        self.startHourLabel.textColor = UIColor.inviteTableHeaderColor()
        self.startHourLabel.font = UIFont.proximaNovaRegularFontOfSize(20)
        self.startHourLabel.numberOfLines = 1
        
        self.endHourLabel.textColor = UIColor.grayColor()
        self.endHourLabel.font = UIFont.proximaNovaRegularFontOfSize(12)
        self.endHourLabel.numberOfLines = 1
        
        self.endDayLabel.textColor = UIColor.grayColor()
        self.endDayLabel.font = UIFont.proximaNovaRegularFontOfSize(12)
        self.endDayLabel.numberOfLines = 1
        
        self.invitedLabel.textColor = UIColor.grayColor()
        self.invitedLabel.font = UIFont.proximaNovaRegularFontOfSize(12)
        self.invitedLabel.numberOfLines = 1
    }
    
    private func configureForEvent()
    {
        configureDate()
        
        self.titleLable.text = self.event[EVENT_TITLE_KEY] as? String
        
        self.invitedLabel.text = "\(self.event[EVENT_INVITEES_KEY].count) invited"
        
//        switch EventMyResponse(rawValue: AppDelegate.user().myResponses[self.event.objectId!] as! UInt)! {
//        case EventMyResponse.Going:
//            self.rsvpLabel.textColor = UIColor.inviteGreenColor()
//            self.rsvpLabel.text = "Going"
//        case EventMyResponse.Maybe:
//            self.rsvpLabel.textColor = UIColor.inviteGrayColor()
//            self.rsvpLabel.text = "Maybe"
//        case EventMyResponse.Sorry:
//            self.rsvpLabel.textColor = UIColor.inviteRedColor()
//            self.rsvpLabel.text = "Sorry"
//        case EventMyResponse.Host:
//            self.rsvpLabel.textColor = UIColor.inviteBlueColor()
//            self.rsvpLabel.text = "My event"
//        default:
//            break
//        }

        self.profileImageView1.layer.cornerRadius = 12
        self.profileImageView2.layer.cornerRadius = 12
        self.profileImageView3.layer.cornerRadius = 12
        self.profileImageView4.layer.cornerRadius = 12
    }
    
    private func configureDate()
    {
        let startDate = self.event[EVENT_START_DATE_KEY] as! NSDate
        let endDate = self.event[EVENT_END_DATE_KEY] as! NSDate
        let dateFormatter = NSDateFormatter()
        
        // Start hour
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.AMSymbol = "am"
        dateFormatter.PMSymbol = "pm"
        let startHourText: NSString = dateFormatter.stringFromDate(startDate) as NSString
        self.startHourLabel.text = startHourText.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        // Date label
        let calendar = NSCalendar.currentCalendar()
        let components: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
        let s = calendar.components(components, fromDate: startDate)
        let e = calendar.components(components, fromDate: endDate)
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        
        var endDayText: String?
        var endHourText: String?
        
        if (!(s.day  == e.day &&
            s.month  == e.month &&
            s.year   == e.year))
        {
            endDayText = dateFormatter.stringFromDate(endDate)
        }
        
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        
        if (!(s.day  == e.day &&
            s.month  == e.month &&
            s.year   == e.year &&
            s.hour   == e.hour &&
            s.minute == e.minute))
        {
            endHourText = dateFormatter.stringFromDate(endDate)
        }
        
        if let endHourText = endHourText {
            self.endHourLabel.text = "until \(endHourText)"
        } else {
            self.endHourLabel.text = ""
        }
        if let endDayText = endDayText {
            self.endDayLabel.text = "on \(endDayText)"
        } else {
            self.endDayLabel.text = ""
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
