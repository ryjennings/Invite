//
//  ButtonCell.swift
//  Invite
//
//  Created by Ryan Jennings on 9/22/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

@objc(ButtonCell) class ButtonCell: UITableViewCell
{
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib()
    {
        self.button.layer.cornerRadius = 6
        self.button.clipsToBounds = true
        self.button.titleLabel?.font = UIFont.proximaNovaRegularFontOfSize(18)
        self.button.backgroundColor = UIColor.inviteButtonBackgroundColor()
    }
}
