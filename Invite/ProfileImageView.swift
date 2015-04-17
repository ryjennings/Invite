//
//  ProfileImageView.swift
//  Invite
//
//  Created by Ryan Jennings on 3/31/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView
{
    override func awakeFromNib()
    {
        layer.cornerRadius = 22
        clipsToBounds = true
    }
    
    func prepareLabelForEmail(email: String)
    {
        let displayText = "\(email[email.startIndex])"
        prepareLabelWithText(displayText)
    }
    
    func prepareLabelForPerson(person: PFObject)
    {
        var displayText = ""
        if let firstName = person.objectForKey(FIRST_NAME_KEY) as? String {
            displayText += "\(firstName[firstName.startIndex])"
        }
        if let lastName = person.objectForKey(LAST_NAME_KEY) as? String {
            displayText += "\(lastName[lastName.startIndex])"
        }
        if (displayText.isEmpty) {
            let email = person.objectForKey(EMAIL_KEY) as! String
            displayText = "\(email[email.startIndex])"
        }
        prepareLabelWithText(displayText)
    }
    
    func prepareLabelWithText(displayText: String)
    {
        var initialsLabel = UILabel()
        initialsLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        initialsLabel.textColor = UIColor.whiteColor()
        initialsLabel.text = displayText.uppercaseString
        initialsLabel.backgroundColor = UIColor.clearColor()
        backgroundColor = UIColor.inviteLightSlateColor()
        initialsLabel.textAlignment = .Center
        initialsLabel.font = UIFont.proximaNovaRegularFontOfSize(22)
        initialsLabel.minimumScaleFactor = 10/22 // minimum/maximum
        initialsLabel.adjustsFontSizeToFitWidth = true
        addSubview(initialsLabel)
        
        let views = ["label": initialsLabel]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[label]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    }
}
