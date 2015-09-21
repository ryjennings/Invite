//
//  NumberedInputCell.swift
//  Invite
//
//  Created by Ryan Jennings on 9/20/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

@objc(NumberedInputCell) class NumberedInputCell: UITableViewCell, UITextViewDelegate
{
    var delegate: NumberedInputCellDelegate?
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var guidance: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.textView.textContainerInset = UIEdgeInsetsMake(3, 0, 0, 0)
        self.textView.textContainer.lineFragmentPadding = 0
        
        self.leadingConstraint.constant = SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(textView: UITextView)
    {
        guidance.hidden = Bool(textView.text.characters.count)
        self.delegate?.numberedTextViewDidChange(textView)
    }
}

@objc protocol NumberedInputCellDelegate
{
    func numberedTextViewDidChange(textView: UITextView)
}
