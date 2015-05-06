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
        textLabel?.font = UIFont.inviteTableSmallFont()
        textLabel?.textColor = UIColor.inviteTableLabelColor()
    }
}
