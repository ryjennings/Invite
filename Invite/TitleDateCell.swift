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
        super.awakeFromNib()

        dateLabel.backgroundColor = UIColor.inviteBlueColor()
        dateLabel.numberOfLines = 2
        dateLabel.layer.cornerRadius = 40
        dateLabel.clipsToBounds = true
        
        label.textColor = UIColor.inviteBlueColor()
        label.font = UIFont.inviteTitleFont()
        label.numberOfLines = 0

        self.dateLabelLeadingConstraint.constant = SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15
        self.selectionStyle = UITableViewCellSelectionStyle.Gray
    }

    override func setHighlighted(highlighted: Bool, animated: Bool)
    {
        super.setHighlighted(highlighted, animated: animated)
        dateLabel.backgroundColor = UIColor.inviteBlueColor()
    }
}
