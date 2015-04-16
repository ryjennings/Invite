//
//  RadioCell.swift
//  Invite
//
//  Created by Ryan Jennings on 4/10/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(RadioCell) class RadioCell: UITableViewCell
{
    @IBOutlet weak var segments: UISegmentedControl!
    @IBOutlet weak var segmentsLeadingConstraint: NSLayoutConstraint!
}
