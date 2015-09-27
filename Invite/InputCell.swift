//
//  InputCell.swift
//  Invite
//
//  Created by Ryan Jennings on 4/10/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(InputCell) class InputCell: UITableViewCell, UITextViewDelegate, NSLayoutManagerDelegate
{
    var delegate: InputCellDelegate?
    @IBOutlet weak var guidance: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var guidanceLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewLeadingConstraint: NSLayoutConstraint!

    override func awakeFromNib()
    {
        super.awakeFromNib()

        self.textView.textContainerInset = UIEdgeInsetsMake(4, 0, 0, 0)
        self.textView.textContainer.lineFragmentPadding = 0
        self.textView.layoutManager.delegate = self

        self.guidanceLeadingConstraint.constant = SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15
        self.textViewLeadingConstraint.constant = self.guidanceLeadingConstraint.constant
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    // MARK: - UITextViewDelegate

    func textViewDidChange(textView: UITextView)
    {
        guidance.hidden = Bool(textView.text.characters.count)
        self.delegate?.textViewDidChange(textView)
    }

    // MARK: - NSLayoutManagerDelegate
    
    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat
    {
        return 4 // UITextView line spacing - This value is SUPER sensitive
    }
}

@objc protocol InputCellDelegate
{
    func textViewDidChange(textView: UITextView)
}
