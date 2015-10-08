//
//  DashboardCell.swift
//  Invite
//
//  Created by Ryan Jennings on 10/5/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit
import MapKit

@objc(DashboardCell) class DashboardCell: UITableViewCell
{
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var endHourLabel: UILabel!
    @IBOutlet weak var endDayLabel: UILabel!
    @IBOutlet weak var invitedLabel: UILabel!
    @IBOutlet weak var yourLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var profileImageView1: ProfileImageView!
    @IBOutlet weak var profileImageView2: ProfileImageView!
    @IBOutlet weak var profileImageView3: ProfileImageView!
    @IBOutlet weak var profileImageView4: ProfileImageView!
    
    @IBOutlet weak var colorViewWidthConstraint: NSLayoutConstraint!
    
    var response = EventMyResponse.NoResponse
    
    private var profiles = [ProfileImageView]()
    
    var event: PFObject! {
        didSet {
            configureForEvent()
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.profiles = [self.profileImageView1, self.profileImageView2, self.profileImageView3, self.profileImageView4]
        
        self.titleLable.font = UIFont.proximaNovaRegularFontOfSize(20)
        self.titleLable.numberOfLines = 1
        
        self.startHourLabel.font = UIFont.proximaNovaRegularFontOfSize(20)
        self.startHourLabel.numberOfLines = 1
        
        self.endHourLabel.font = UIFont.proximaNovaRegularFontOfSize(12)
        self.endHourLabel.numberOfLines = 1
        
        self.endDayLabel.font = UIFont.proximaNovaRegularFontOfSize(12)
        self.endDayLabel.numberOfLines = 1
        
        self.invitedLabel.font = UIFont.proximaNovaRegularFontOfSize(12)
        self.invitedLabel.numberOfLines = 1
        
        self.yourLabel.font = UIFont.proximaNovaSemiboldFontOfSize(12)
        self.yourLabel.numberOfLines = 1
    }
    
    private func unselectCell()
    {
        self.backgroundColor = UIColor.whiteColor()
        self.titleLable.textColor = UIColor.inviteTableHeaderColor()
        self.endHourLabel.textColor = UIColor.grayColor()
        self.endDayLabel.textColor = UIColor.grayColor()
        self.invitedLabel.textColor = UIColor.grayColor()
        self.yourLabel.textColor = UIColor.grayColor()

        switch self.response {
        case EventMyResponse.Going:
            self.colorView.backgroundColor = UIColor.inviteGreenColor()
            self.startHourLabel.textColor = UIColor.inviteGreenColor()
            self.yourLabel.textColor = UIColor.inviteGreenColor()
        case EventMyResponse.Maybe:
            self.colorView.backgroundColor = UIColor.inviteYellowColor()
            self.startHourLabel.textColor = UIColor.inviteYellowColor()
            self.yourLabel.textColor = UIColor.inviteYellowColor()
        case EventMyResponse.NoResponse:
            self.colorView.backgroundColor = UIColor.grayColor()
            self.startHourLabel.textColor = UIColor.grayColor()
            self.yourLabel.textColor = UIColor.grayColor()
        case EventMyResponse.Sorry:
            self.colorView.backgroundColor = UIColor.inviteRedColor()
            self.startHourLabel.textColor = UIColor.inviteRedColor()
            self.yourLabel.textColor = UIColor.inviteRedColor()
        case EventMyResponse.Host:
            self.colorView.backgroundColor = UIColor.inviteBlueColor()
            self.startHourLabel.textColor = UIColor.inviteBlueColor()
            self.yourLabel.textColor = UIColor.inviteBlueColor()
        }
    }
    
    private func selectCell()
    {
        self.backgroundColor = UIColor.inviteLightSlateColor()
        self.titleLable.textColor = UIColor.whiteColor()
        self.startHourLabel.textColor = UIColor.whiteColor()
        self.endHourLabel.textColor = UIColor.whiteColor()
        self.endDayLabel.textColor = UIColor.whiteColor()
        self.invitedLabel.textColor = UIColor.whiteColor()
        self.yourLabel.textColor = UIColor.whiteColor()
        self.colorView.backgroundColor = UIColor.whiteColor()
    }
    
    private func configureForEvent()
    {
        configureDate()
        
        var going = 0
        for response in self.event[EVENT_RSVP_KEY] as! [String: UInt] {
            if EventResponse(rawValue: response.1) == EventResponse.Going {
                going++
            }
        }
        
        self.colorViewWidthConstraint.constant = 2
        self.titleLable.text = self.event[EVENT_TITLE_KEY] as? String
        
        self.invitedLabel.text = "\(going) going, \(self.event[EVENT_INVITEES_KEY].count) invited"
        
        self.response = EventMyResponse(rawValue: AppDelegate.user().myResponses[self.event.objectId!] as! UInt)!
        
        configureProfiles()
        
        if self.response == EventMyResponse.Host {
            self.yourLabel.hidden = false
            self.yourLabel.text = "Your event"
        } else {
            self.yourLabel.hidden = true
        }
        
        unselectCell()
    }
    
    private func configureProfiles()
    {
        self.profileImageView1.hidden = true
        self.profileImageView2.hidden = true
        self.profileImageView3.hidden = true
        self.profileImageView4.hidden = true

        for var i = 0; i < self.event[EVENT_INVITEES_KEY].count; i++ {
            let invitee = (self.event[EVENT_INVITEES_KEY] as! NSArray)[i] as! PFObject
            self.profiles[i].hidden = false
            self.profiles[i].configureForPerson(invitee, event: self.event, width: 24, showResponse: true)
        }
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

    override func setHighlighted(highlighted: Bool, animated: Bool)
    {
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            selectCell()
        } else {
            unselectCell()
        }
    }
    
    func flashColorView()
    {
        self.colorViewWidthConstraint.constant = 7
        UIView.animateWithDuration(0.33) { () -> Void in
            self.layoutIfNeeded()
        }
    }
}
