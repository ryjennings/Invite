//
//  ConflictCell.swift
//  Invite
//
//  Created by Ryan Jennings on 5/6/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(ConflictCell) class ConflictCell: UITableViewCell
{
    @IBOutlet weak var conflictView: ConflictView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var conflictViewLeadingConstraint: NSLayoutConstraint!
        
    var reservation: Reservation!
    
    override func awakeFromNib()
    {
        label.textColor = UIColor.inviteTableLabelColor()
        label.font = UIFont.inviteTableSmallFont()
    }
}
