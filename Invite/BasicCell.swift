//
//  BasicCell.swift
//  Invite
//
//  Created by Ryan Jennings on 4/10/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(BasicCell) class BasicCell: UITableViewCell
{
    override func awakeFromNib()
    {
        self.textLabel?.font = UIFont.inviteTableSmallFont()
        self.textLabel?.textColor = UIColor.inviteTableLabelColor()
        self.detailTextLabel?.font = UIFont.inviteTableSmallFont()

        self.accessoryType = UITableViewCellAccessoryType.None
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor.whiteColor()
    }
}
