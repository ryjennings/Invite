//
//  InputCell.swift
//  Invite
//
//  Created by Ryan Jennings on 4/10/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(InputCell) class InputCell: UITableViewCell, UITextViewDelegate
{
    var delegate: InputCellDelegate?
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var labelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewLeadingConstraint: NSLayoutConstraint!
            
    // MARK: - UITextViewDelegate

    func textViewDidChange(textView: UITextView)
    {
        placeholderLabel.hidden = Bool(count(textView.text))
        if let d = delegate {
            d.textViewDidChange(textView)
        }
    }
}

@objc protocol InputCellDelegate
{
    func textViewDidChange(textView: UITextView)
}
