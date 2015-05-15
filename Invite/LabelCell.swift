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
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cellText: UILabel!
    @IBOutlet weak var labelLeadingConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.font = UIFont.proximaNovaSemiboldFontOfSize(16)
        label.textColor = UIColor.lightGrayColor()
        
        cellText.font = UIFont.inviteTableSmallFont()
        cellText.textColor = UIColor.inviteTableLabelColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
