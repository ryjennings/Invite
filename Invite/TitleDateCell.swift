//
//  TitleDateCell.swift
//  Invite
//
//  Created by Ryan Jennings on 5/11/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(TitleDateCell) class TitleDateCell: UITableViewCell
{
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateLabelLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib()
    {
        dateLabel.backgroundColor = UIColor.inviteBlueColor()
        dateLabel.numberOfLines = 2
        dateLabel.layer.cornerRadius = 25
        dateLabel.clipsToBounds = true
        
        label.textColor = UIColor.inviteBlueColor()
        label.font = UIFont.inviteTitleFont()
    }
}
