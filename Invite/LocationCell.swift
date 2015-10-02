//
//  LocationCell.swift
//  Invite
//
//  Created by Ryan Jennings on 9/30/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

@objc(LocationCell) class LocationCell: UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.nameLabel.textColor = UIColor.inviteTableHeaderColor()
        self.nameLabel.font = UIFont.proximaNovaRegularFontOfSize(16)
        self.leadingConstraint.constant = SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15
    }
}
