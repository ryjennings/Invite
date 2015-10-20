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
    
    var friend: Friend! {
        didSet {
            if self.friend.fullName == nil {
                self.leadingFlexLabelConstraint.constant = -30
                self.nameLabel.hidden = true
                self.flexLabel.text = self.friend.email
                self.separatorInset = UIEdgeInsetsMake(0, SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15, 0, 0)
            } else if self.friend.pfObject != nil {
                self.leadingFlexLabelConstraint.constant = 10
                self.nameLabel.hidden = true
                self.flexLabel.text = self.friend.fullName
                self.separatorInset = UIEdgeInsetsMake(0, SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 + 40 : 15 + 40, 0, 0)
            } else {
                self.leadingFlexLabelConstraint.constant = 120
                self.nameLabel.hidden = false
                self.nameLabel.text = self.friend.fullName
                self.flexLabel.text = self.friend.email
                self.separatorInset = UIEdgeInsetsMake(0, SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 + 40 : 15 + 40, 0, 0)
            }
            
            self.accessoryView = UIView(frame: CGRectMake(0, 0, 10, 10))
            self.accessoryView?.backgroundColor = UIColor.inviteBackgroundSlateColor()
            self.accessoryView?.clipsToBounds = true
            self.accessoryView?.layer.cornerRadius = 5
            
            if friend.pfObject?[FACEBOOK_ID_KEY] != nil {
                self.profileImageView.configureForPerson(self.friend, responseValue: 0, width: 30, showResponse: false)
                self.profileImageView.hidden = false
            } else {
                self.profileImageView.hidden = true
            }
        }
    }
    
    var location: Location! {
        didSet {
            if self.location.name == nil {
                self.leadingFlexLabelConstraint.constant = -30
                self.nameLabel.hidden = true
                self.flexLabel.text = self.location.formattedAddress
                self.separatorInset = UIEdgeInsetsMake(0, SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15, 0, 0)
            } else if self.location.pfObject != nil {
                self.leadingFlexLabelConstraint.constant = 120
                self.nameLabel.text = self.location.name
                self.nameLabel.textColor = UIColor.inviteTableHeaderColor()
                self.flexLabel.text = self.location.formattedAddress
                self.flexLabel.textColor = UIColor.inviteGrayColor()
                self.separatorInset = UIEdgeInsetsMake(0, SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15, 0, 0)
            } else {
                self.leadingFlexLabelConstraint.constant = 120
                self.nameLabel.hidden = false
                self.nameLabel.text = self.location.name
                self.flexLabel.text = self.location.formattedAddress
                self.separatorInset = UIEdgeInsetsMake(0, SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 + 40 : 15 + 40, 0, 0)
            }
            
            self.accessoryView = UIView(frame: CGRectMake(0, 0, 10, 10))
            self.accessoryView?.backgroundColor = UIColor.inviteBackgroundSlateColor()
            self.accessoryView?.clipsToBounds = true
            self.accessoryView?.layer.cornerRadius = 5
            
            self.profileImageView.hidden = true
        }
    }
    
    override func awakeFromNib()
    {
        self.leadingConstraint.constant = SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15
        self.nameLabel.font = UIFont.inviteTableSmallFont()
        self.flexLabel.font = UIFont.inviteTableSmallFont()
    }
}
