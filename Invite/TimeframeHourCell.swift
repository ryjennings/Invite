//
//  TimeframeHourCell.swift
//  Invite
//
//  Created by Ryan Jennings on 4/8/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

public class TimeframeHourCell: UITableViewCell
{
    @IBOutlet weak var hourLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    
    public override func awakeFromNib()
    {
        hourLabel.font = UIFont.inviteTimeframeHourFont()
        hourLabel.textColor = UIColor.whiteColor()
    }
    
    public var circleColor: UIColor = UIColor.inviteLightSlateColor()
    {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public override func drawRect(rect: CGRect)
    {
        var ctx = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(ctx, circleColor.CGColor)
        CGContextFillEllipseInRect(ctx, hourLabel.frame)
    }
}