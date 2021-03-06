//
//  InviteesCollectionCell.swift
//  Invite
//
//  Created by Ryan Jennings on 4/16/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(InviteesCollectionCell) class InviteesCollectionCell: UICollectionViewCell
{
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib()
    {
        label.font = UIFont.proximaNovaRegularFontOfSize(10)
        label.textColor = UIColor.inviteTableLabelColor()
    }
}
