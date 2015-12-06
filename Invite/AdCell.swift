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
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.leadingConstraint.constant = SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15

        self.titleLabel.textColor = UIColor.inviteTableHeaderColor()
        self.titleLabel.font = UIFont.proximaNovaRegularFontOfSize(20)
        
        self.copyLabel.textColor = UIColor.grayColor()
        self.copyLabel.font = UIFont.proximaNovaRegularFontOfSize(12)
        
        self.iconStrokeView.layer.cornerRadius = 12
        self.iconStrokeView.clipsToBounds = true
        self.iconStrokeView.layer.borderWidth = 2
        self.iconStrokeView.layer.borderColor = UIColor.inviteBlueColor().CGColor
        
        self.iconImageView.layer.cornerRadius = 9
        self.iconImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    func nativeMainTextLabel() -> UILabel!
    {
        return self.copyLabel
    }
    
    func nativeIconImageView() -> UIImageView!
    {
        return self.iconImageView
    }
    
    func nativeMainImageView() -> UIImageView!
    {
        return self.mainImageView
    }
    
    func nativeTitleTextLabel() -> UILabel!
    {
        return self.titleLabel
    }

    class func nibForAd() -> UINib!
    {
        return UINib(nibName: "AdCell", bundle: nil)
    }
}
