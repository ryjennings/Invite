//
//  ProfileCell.swift
//  Invite
//
//  Created by Ryan Jennings on 4/26/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(ProfileCell) class ProfileCell: UITableViewCell
{
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var flexLabel: UILabel!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingFlexLabelConstraint: NSLayoutConstraint!
    
    override func awakeFromNib()
    {
        self.profileImageView.layer.cornerRadius = 15
        self.profileImageView.clipsToBounds = true
        self.leadingConstraint.constant = SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15
        self.nameLabel.font = UIFont.inviteTableSmallFont()
        self.flexLabel.font = UIFont.inviteTableSmallFont()
    }
}
