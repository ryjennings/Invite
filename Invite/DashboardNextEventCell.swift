//
//  DashboardNextEventCell.swift
//  Invite
//
//  Created by Ryan Jennings on 11/2/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

class DashboardNextEventCell: UITableViewCell
{
    @IBOutlet weak var mainProfile: ProfileImageView!
    @IBOutlet weak var nextLabel: UILabel!
    
    var nextEventString: String! {
        didSet {
            configureNextLabel()
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clearColor()
        
        self.mainProfile.setup()
        self.mainProfile.configureForPerson(AppDelegate.parseUser(), responseValue: 0, width: 80, showResponse: false)
        self.mainProfile.layer.borderColor = UIColor.whiteColor().CGColor
        self.mainProfile.layer.borderWidth = 2
        self.mainProfile.layer.cornerRadius = 40
        self.mainProfile.clipsToBounds = true
    }
    
    private func configureNextLabel()
    {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        let att = NSMutableAttributedString()
        att.appendAttributedString(NSAttributedString(string: "Your next event\n", attributes: [NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(20), NSForegroundColorAttributeName: UIColor.inviteQuestionColor(), NSParagraphStyleAttributeName: style]))
        att.appendAttributedString(NSAttributedString(string: self.nextEventString, attributes: [NSFontAttributeName: UIFont.proximaNovaSemiboldFontOfSize(24), NSForegroundColorAttributeName: UIColor.inviteQuestionColor(), NSParagraphStyleAttributeName: style]))
        self.nextLabel.attributedText = att
        self.nextLabel.shadowColor = UIColor.whiteColor()
        self.nextLabel.shadowOffset = CGSizeMake(0, 1)
    }
}
