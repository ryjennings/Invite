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
    
    var myResponse = EventMyResponse.NoResponse
    var responses = [String: UInt]()
    
    var indexPath: NSIndexPath!
    var needsResponse = false
    var isOld = false
    var isLast = false
    
    var event: PFObject! {
        didSet {
            configureForEvent()
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
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
        let patternImageName = self.isOld ? self.isLast ? "topbottomold" : "topold" : self.isLast ? "topbottom" : "top"
        self.backgroundColor = self.needsResponse ? UIColor.inviteLightYellowColor() : UIColor(patternImage: UIImage(named: patternImageName)!)
        if indexPath.section == 0 && indexPath.row == 0 && !self.needsResponse {
            self.backgroundColor = UIColor.whiteColor()
        }
        self.titleLable.textColor = self.needsResponse ? UIColor.inviteOrangeColor() : UIColor.inviteTableHeaderColor()
        self.endHourLabel.textColor = self.needsResponse ? UIColor.darkGrayColor() : UIColor.grayColor()
        self.endDayLabel.textColor = self.needsResponse ? UIColor.darkGrayColor() : UIColor.grayColor()
        self.invitedLabel.textColor = self.needsResponse ? UIColor.inviteTableHeaderColor() : UIColor.grayColor()

        switch self.myResponse {
        case EventMyResponse.Going:
            self.colorView.backgroundColor = UIColor.inviteGreenColor()
            self.startHourLabel.textColor = UIColor.inviteGreenColor()
            self.yourLabel.textColor = UIColor.inviteGreenColor()
        case EventMyResponse.Maybe:
            self.colorView.backgroundColor = UIColor.inviteYellowColor()
            self.startHourLabel.textColor = UIColor.inviteYellowColor()
            self.yourLabel.textColor = UIColor.inviteYellowColor()
        case EventMyResponse.NoResponse:
            self.colorView.backgroundColor = self.needsResponse ? UIColor.darkGrayColor() : UIColor.grayColor()
            self.startHourLabel.textColor = self.needsResponse ? UIColor.darkGrayColor() : UIColor.grayColor()
            self.yourLabel.textColor = self.needsResponse ? UIColor.inviteTableHeaderColor() : UIColor.grayColor()
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
        if self.needsResponse {
            self.colorView.hidden = true
            self.startHourLabel.hidden = true
            self.endDayLabel.hidden = true
            self.endHourLabel.hidden = true
        } else {
            self.colorView.hidden = false
            self.startHourLabel.hidden = false
            self.endDayLabel.hidden = false
            self.endHourLabel.hidden = false
        }
        
        let invitees = inviteesByEmail()

        configureDate()
        
        self.colorViewWidthConstraint.constant = 2
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        self.titleLable.text = self.needsResponse ? "Starts on \(dateFormatter.stringFromDate(self.event[EVENT_START_DATE_KEY] as! NSDate))" : self.event[EVENT_TITLE_KEY] as? String
        if self.needsResponse {
            self.titleLable.font = UIFont.proximaNovaRegularFontOfSize(18)
        } else {
            self.titleLable.font = UIFont.proximaNovaRegularFontOfSize(20)
        }

        // Build responseGroups
        var responseGroups = [EventResponse: [PFObject]]()
        responseGroups[EventResponse.Going] = [PFObject]()
        responseGroups[EventResponse.Maybe] = [PFObject]()
        responseGroups[EventResponse.Sorry] = [PFObject]()
        responseGroups[EventResponse.NoResponse] = [PFObject]()
        
        var going = 0
        
        for response in self.event[EVENT_RESPONSES_KEY] as! [String] {
            let com = response.componentsSeparatedByString(":")
            let eventResponse = EventResponse(rawValue: UInt(com[1])!)
            if eventResponse == EventResponse.Going {
                going++
            }
            responseGroups[eventResponse!]!.append(invitees[com[0]]!)
            self.responses[com[0]] = UInt(com[1])
        }

        self.invitedLabel.text = "\(going) going, \(self.event[EVENT_INVITEES_KEY].count) invited"

        configureProfiles(responseGroups)

        // My response
        self.myResponse = EventMyResponse(rawValue: AppDelegate.user().myResponses[self.event.objectId!] as! UInt)!
        switch self.myResponse {
        case EventMyResponse.Going:
            self.yourLabel.text = "Going"
        case EventMyResponse.Maybe:
            self.yourLabel.text = "Maybe"
        case EventMyResponse.Sorry:
            self.yourLabel.text = "Sorry"
        case EventMyResponse.NoResponse:
            self.yourLabel.text = "Respond now!"
        case EventMyResponse.Host:
            self.yourLabel.text = "Your event"
        }
        
        unselectCell()
    }
    
    private func inviteesByEmail() -> [String: PFObject]
    {
        var invitees = [String: PFObject]()
        for invitee in self.event[EVENT_INVITEES_KEY] as! [PFObject] {
            invitees[invitee[EMAIL_KEY] as! String] = invitee
        }
        return invitees
    }
    
    private func configureProfiles(groups: [EventResponse: [PFObject]])
    {
        self.profileImageView1.hidden = true
        self.profileImageView2.hidden = true
        self.profileImageView3.hidden = true
        self.profileImageView4.hidden = true

        var profiles = [self.profileImageView1, self.profileImageView2, self.profileImageView3, self.profileImageView4]
        
        var profileIndex = 0
        
        for invitee in groups[EventResponse.Going]! {
            if profileIndex < profiles.count {
                profiles[profileIndex].hidden = false
                profiles[profileIndex].configureForPerson(invitee, responseValue: self.responses[invitee[EMAIL_KEY] as! String]!, width: 24, showResponse: true)
                profileIndex++
            }
        }
        for invitee in groups[EventResponse.Maybe]! {
            if profileIndex < profiles.count {
                profiles[profileIndex].hidden = false
                profiles[profileIndex].configureForPerson(invitee, responseValue: self.responses[invitee[EMAIL_KEY] as! String]!, width: 24, showResponse: true)
                profileIndex++
            }
        }
        for invitee in groups[EventResponse.Sorry]! {
            if profileIndex < profiles.count {
                profiles[profileIndex].hidden = false
                profiles[profileIndex].configureForPerson(invitee, responseValue: self.responses[invitee[EMAIL_KEY] as! String]!, width: 24, showResponse: true)
                profileIndex++
            }
        }
        for invitee in groups[EventResponse.NoResponse]! {
            if profileIndex < profiles.count {
                profiles[profileIndex].hidden = false
                profiles[profileIndex].configureForPerson(invitee, responseValue: self.responses[invitee[EMAIL_KEY] as! String]!, width: 24, showResponse: true)
                profileIndex++
            }
        }
    }
    
    private func configureDate()
    {
        let startDate = self.event[EVENT_START_DATE_KEY] as! NSDate
        let endDate = self.event[EVENT_END_DATE_KEY] as! NSDate
        let dateFormatter = NSDateFormatter()
        
        // Start hour
        if self.isOld {
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
            let startDayText: NSString = dateFormatter.stringFromDate(startDate) as NSString
            self.startHourLabel.text = startDayText.componentsSeparatedByString(",")[0]

            dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            dateFormatter.AMSymbol = "am"
            dateFormatter.PMSymbol = "pm"
            let startHourText: NSString = dateFormatter.stringFromDate(startDate) as NSString
            let s = startHourText.stringByReplacingOccurrencesOfString(" ", withString: "")
            self.endHourLabel.text = "started \(s)"
        } else {
            dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
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
                let e = endHourText.stringByReplacingOccurrencesOfString(" ", withString: "")
                self.endHourLabel.text = "until \(e)"
            } else {
                self.endHourLabel.text = ""
            }
            if let endDayText = endDayText {
                self.endDayLabel.text = "on \(endDayText)"
            } else {
                self.endDayLabel.text = ""
            }
        }
    }

    override func setHighlighted(highlighted: Bool, animated: Bool)
    {
        super.setHighlighted(highlighted, animated: animated)

        if highlighted && !self.needsResponse {
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
