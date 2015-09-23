//
//  NumberedInputCell.swift
//  Invite
//
//  Created by Ryan Jennings on 9/20/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

@objc(NumberedInputCell) class NumberedInputCell: UITableViewCell, UITextViewDelegate, NSLayoutManagerDelegate
{
    var delegate: NumberedInputCellDelegate?
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var guidance: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var check: UIImageView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    private var isShowingCheckmark = false
    var indexPath: NSIndexPath! {
        didSet {
            if !self.isShowingCheckmark {
                self.number.text = "\(indexPath.row)"
            }
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.isShowingCheckmark = false
        
        self.textView.textContainerInset = UIEdgeInsetsMake(3, 0, 0, 0)
        self.textView.textContainer.lineFragmentPadding = 0
        self.textView.textColor = UIColor.inviteTableHeaderColor()
        self.textView.font = UIFont.proximaNovaRegularFontOfSize(20)
        self.textView.layoutManager.delegate = self
        
        self.guidance.font = UIFont.proximaNovaRegularFontOfSize(20)
        self.guidance.textColor = UIColor.inviteBlueColor()
        
        self.number.clipsToBounds = true
        self.number.layer.cornerRadius = 15
        self.number.layer.borderWidth = 2
        self.number.layer.borderColor = UIColor.inviteBlueColor().CGColor
        self.number.font = UIFont.inviteTableSmallFont()
        self.number.textColor = UIColor.inviteBlueColor()

        self.check.image = UIImage(named: "check")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.check.tintColor = UIColor.inviteGreenColor()
        self.check.alpha = 0

        self.leadingConstraint.constant = SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    func showCheckmark()
    {
        self.isShowingCheckmark = true
        self.number.layer.borderColor = UIColor.inviteGreenColor().CGColor
        self.check.alpha = 1
        self.number.text = ""
    }
    
    func hideCheckmark()
    {
        self.isShowingCheckmark = false
        self.number.layer.borderColor = UIColor.inviteBlueColor().CGColor
        self.check.alpha = 0
    }
    
    // MARK: - NSLayoutManagerDelegate
    
    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat
    {
        return 4 // UITextView line spacing - This value is SUPER sensitive
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(textView: UITextView)
    {
        if textView.text != "" {
            showCheckmark()
        } else {
            hideCheckmark()
        }
        guidance.hidden = Bool(textView.text.characters.count)
        self.delegate?.numberedTextViewDidChange(textView)
    }
}

@objc protocol NumberedInputCellDelegate
{
    func numberedTextViewDidChange(textView: UITextView)
}
