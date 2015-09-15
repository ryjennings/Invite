//
//  TimeframeHourCell.swift
//  Invite
//
//  Created by Ryan Jennings on 4/8/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

class TimeframeHourCell: UITableViewCell
{
    @IBOutlet weak var hourLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib()
    {
        hourLabel.font = UIFont.inviteTimeframeHourFont()
        hourLabel.textColor = UIColor.whiteColor()
    }
    
    var circleColor: UIColor = UIColor.inviteLightSlateColor()
    {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect)
    {
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(ctx, circleColor.CGColor)
        CGContextFillEllipseInRect(ctx, hourLabel.frame)
    }
}