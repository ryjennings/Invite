//
//  ToggleCell.swift
//  Invite
//
//  Created by Ryan Jennings on 5/9/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(ToggleCell) class ToggleCell: UITableViewCell
{
    @IBOutlet weak var toggle: UISwitch!
    @IBOutlet weak var label: UILabel!
    var key: String! {
        didSet {
            toggle.setOn(UserDefaults.boolForKey(key), animated: true)
        }
    }
    
    override func awakeFromNib()
    {
        label.font = UIFont.inviteTableSmallFont()
        label.textColor = UIColor.inviteTableLabelColor()
    }
    
    @IBAction func switched(toggle: UISwitch)
    {
        UserDefaults.setBool(toggle.on, key: key)
    }
}
