//
//  DashboardNeedsResponseCell.swift
//  Invite
//
//  Created by Ryan Jennings on 11/2/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

class DashboardNeedsResponseCell: UITableViewCell
{
    @IBOutlet weak var upperLable: UILabel!
    @IBOutlet weak var lowerLable: UILabel!
    @IBOutlet weak var invitedLabel: UILabel!
    @IBOutlet weak var respondLabel: UILabel!
    @IBOutlet weak var mainProfile: ProfileImageView!
    @IBOutlet weak var profile1: ProfileImageView!
    @IBOutlet weak var profile2: ProfileImageView!
    @IBOutlet weak var profile3: ProfileImageView!
    @IBOutlet weak var profile4: ProfileImageView!
    @IBOutlet weak var topGradientView: OBGradientView!
    @IBOutlet weak var lowerGradientView: OBGradientView!
    @IBOutlet weak var backgroundSlateView: UIView!

    var responses = [String: UInt]()
    
    var event: PFObject! {
        didSet {
            configureForEvent()
        }
    }

    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.inviteLightYellowColor()
        
        self.invitedLabel.font = UIFont.proximaNovaRegularFontOfSize(12)
        self.invitedLabel.numberOfLines = 1
        self.invitedLabel.textColor = UIColor.inviteTableHeaderColor()
        
        self.respondLabel.font = UIFont.proximaNovaSemiboldFontOfSize(12)
        self.respondLabel.numberOfLines = 1
        self.respondLabel.text = "Respond now!"
        self.respondLabel.textColor = UIColor.inviteTableHeaderColor()

        self.lowerLable.font = UIFont.proximaNovaRegularFontOfSize(18)
        self.lowerLable.numberOfLines = 1
        self.lowerLable.textColor = UIColor.inviteOrangeColor()
        self.lowerLable.shadowColor = UIColor.whiteColor()
        self.lowerLable.shadowOffset = CGSizeMake(0, 1)
        
        self.backgroundSlateView.backgroundColor = UIColor.inviteBackgroundSlateColor()

        self.topGradientView.backgroundColor = UIColor.clearColor()
        self.topGradientView.colors = [UIColor.inviteBackgroundSlateColor(), UIColor.inviteBackgroundSlateColor(), UIColor.whiteColor(), UIColor.whiteColor(), UIColor.inviteLightYellowGradientColor(), UIColor.inviteLightYellowColor()]
        self.topGradientView.locations = [0, 0.25, 0.25, 0.26, 0.26, 1]
        
        self.lowerGradientView.backgroundColor = UIColor.clearColor()
        self.lowerGradientView.colors = [UIColor.inviteYellowColor(), UIColor.inviteYellowColor(), UIColor.darkGrayColor().colorWithAlphaComponent(0.33), UIColor.darkGrayColor().colorWithAlphaComponent(0.1), UIColor.darkGrayColor().colorWithAlphaComponent(0)]
        self.lowerGradientView.locations = [0, 0.15, 0.15, 0.5, 1]
    }
    
    private func configureForEvent()
    {
        let invitees = inviteesByEmail()
        
        self.mainProfile.setup()
        self.mainProfile.configureForPerson(AppDelegate.parseUser(), responseValue: 0, width: 80, showResponse: false)
        self.mainProfile.layer.borderColor = UIColor.whiteColor().CGColor
        self.mainProfile.layer.borderWidth = 2
        self.mainProfile.layer.cornerRadius = 40
        self.mainProfile.clipsToBounds = true
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        self.lowerLable.text = "Starts on \(dateFormatter.stringFromDate(self.event[EVENT_START_DATE_KEY] as! NSDate))"
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        
        let att = NSMutableAttributedString()
        
        att.appendAttributedString(NSAttributedString(string: "You've been invited to", attributes: [NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(17), NSForegroundColorAttributeName: UIColor.inviteOrangeColor(), NSParagraphStyleAttributeName: style]))
        att.appendAttributedString(NSAttributedString(string: "\n\(self.event[EVENT_TITLE_KEY] as! String)", attributes: [NSFontAttributeName: UIFont.proximaNovaSemiboldFontOfSize(24), NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSParagraphStyleAttributeName: style]))
        
        self.upperLable.backgroundColor = UIColor.clearColor()
        self.upperLable.numberOfLines = 2
        self.upperLable.attributedText = att
        self.upperLable.shadowColor = UIColor.whiteColor()
        self.upperLable.shadowOffset = CGSizeMake(0, 1)
        
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
        
//        unselectCell()
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
        self.profile1.hidden = true
        self.profile2.hidden = true
        self.profile3.hidden = true
        self.profile4.hidden = true
        
        var profiles = [self.profile1, self.profile2, self.profile3, self.profile4]
        
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
    
    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
