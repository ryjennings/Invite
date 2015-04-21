//
//  ClockView.swift
//  Invite
//
//  Created by Ryan Jennings on 4/19/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(ClockView) class ClockView: UIView
{
    override func awakeFromNib()
    {
        clipsToBounds = true
        layer.cornerRadius = 20
    }
}
