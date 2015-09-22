//
//  PaddingCell.swift
//  Invite
//
//  Created by Ryan Jennings on 9/21/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

@objc(PaddingCell) class PaddingCell: UITableViewCell
{
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
