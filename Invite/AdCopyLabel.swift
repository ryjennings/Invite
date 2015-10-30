//
//  AdCopyLabel.swift
//  Invite
//
//  Created by Ryan Jennings on 10/29/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

class AdCopyLabel: UILabel
{
    override func drawTextInRect(rect: CGRect)
    {
        let insets = UIEdgeInsetsMake(0, 0.5, 0, 0)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
}
