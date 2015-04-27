//
//  TimeCell.swift
//  Invite
//
//  Created by Ryan Jennings on 4/19/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(TimeCell) class TimeCell: UITableViewCell
{
    @IBOutlet weak var clockView: ClockView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var clockViewLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib()
    {
        clockView.backgroundColor = UIColor.inviteLightSlateColor()
        label.textColor = UIColor.inviteTableLabelColor()
        label.font = UIFont.inviteTableLabelFont()
    }
    
    func prepareCell()
    {
        clockViewLeadingConstraint.constant = separatorInset.left
    }
}
