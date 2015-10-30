//
//  AdCell.swift
//  Invite
//
//  Created by Ryan Jennings on 10/28/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit
import MoPub

class AdCell: UITableViewCell, MPNativeAdRendering
{
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var iconStrokeView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var copyLabel: UILabel!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.titleLabel.textColor = UIColor.inviteTableHeaderColor()
        self.titleLabel.font = UIFont.proximaNovaRegularFontOfSize(20)
        
        self.leadingConstraint.constant = SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15
        
        self.iconStrokeView.layer.cornerRadius = 12
        self.iconStrokeView.clipsToBounds = true
        self.iconStrokeView.layer.borderWidth = 2
        self.iconStrokeView.layer.borderColor = UIColor.inviteBlueColor().CGColor
        
        self.iconImageView.layer.cornerRadius = 9
        self.iconImageView.clipsToBounds = true
        
        self.selectionStyle = UITableViewCellSelectionStyle.None        
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

    func layoutAdAssets(adObject: MPNativeAd!)
    {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        let copyLabel = UILabel()
        let ctaLabel = UILabel()
        adObject.loadTitleIntoLabel(self.titleLabel)
        adObject.loadTextIntoLabel(copyLabel)
        adObject.loadCallToActionTextIntoLabel(ctaLabel)
        adObject.loadIconIntoImageView(self.iconImageView)
        adObject.loadImageIntoImageView(self.mainImageView)
        let att = NSMutableAttributedString()
        att.appendAttributedString(NSAttributedString(string: copyLabel.text!, attributes: [NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(12), NSForegroundColorAttributeName: UIColor.grayColor(), NSParagraphStyleAttributeName: style]))
        att.appendAttributedString(NSAttributedString(string: " \(ctaLabel.text!)", attributes: [NSFontAttributeName: UIFont.proximaNovaSemiboldFontOfSize(12), NSForegroundColorAttributeName: UIColor.inviteBlueColor(), NSParagraphStyleAttributeName: style]))
        self.copyLabel.attributedText = att
    }
    
    static func sizeWithMaximumWidth(maximumWidth: CGFloat) -> CGSize
    {
        return CGSizeMake(maximumWidth, 190)
    }
    
    class func nibForAd() -> UINib!
    {
        return UINib(nibName: "AdCell", bundle: nil)
    }
}
