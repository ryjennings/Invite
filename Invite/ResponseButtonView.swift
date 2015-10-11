//
//  ResponseButtonView.swift
//  Invite
//
//  Created by Ryan Jennings on 10/10/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

class ResponseButtonView: UIView
{
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var outerCircle: UIView!
    @IBOutlet weak var innerCircle: UIView!
    
    override func awakeFromNib()
    {
        self.outerCircle.layer.cornerRadius = 40
        self.outerCircle.clipsToBounds = true
        self.outerCircle.layer.borderWidth = 4
        
        self.innerCircle.backgroundColor = UIColor.inviteBackgroundSlateColor()
        self.innerCircle.layer.cornerRadius = 34
        self.innerCircle.clipsToBounds = true
        
        self.label.textColor = UIColor.inviteTableHeaderColor()
        self.label.text = ""
        self.label.alpha = 0
        self.label.font = UIFont.inviteTitleFont()
        self.label.numberOfLines = 0
        
        self.button.setTitle("", forState: UIControlState.Normal)
    }
    
    func configureForResponse(response: EventResponse)
    {
        switch response {
        case EventResponse.Going:
            self.outerCircle.layer.borderColor = UIColor.inviteGreenColor().CGColor
        case EventResponse.Maybe:
            self.outerCircle.layer.borderColor = UIColor.inviteYellowColor().CGColor
        default:
            self.outerCircle.layer.borderColor = UIColor.inviteRedColor().CGColor
        }
    }
}
