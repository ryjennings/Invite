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
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var profileImageViewLeadingConstraint: NSLayoutConstraint!
}
