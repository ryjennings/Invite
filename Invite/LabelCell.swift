//
//  LabelCell.swift
//  Invite
//
//  Created by Ryan Jennings on 5/14/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(LabelCell) class LabelCell: UITableViewCell
{
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellText: UILabel!
    @IBOutlet weak var labelLeadingConstraint: NSLayoutConstraint!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.cellLabel.font = UIFont.proximaNovaSemiboldFontOfSize(16)
        self.cellLabel.textColor = UIColor.lightGrayColor()
        
        self.cellText.font = UIFont.inviteTableSmallFont()
        self.cellText.textColor = UIColor.inviteTableHeaderColor()
        
        self.labelLeadingConstraint.constant = SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15
        self.selectionStyle = UITableViewCellSelectionStyle.Gray
        self.backgroundColor = UIColor.whiteColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
