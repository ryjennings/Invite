//
//  ProfileImageView.swift
//  Invite
//
//  Created by Ryan Jennings on 3/31/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

public class ProfileImageView: UIImageView
{
    public func configureWith(person: PFObject)
    {
        let firstName = person.objectForKey(FIRST_NAME_KEY) as String
        let lastName = person.objectForKey(LAST_NAME_KEY) as String

        var initialsLabel = UILabel()
        initialsLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        initialsLabel.text = "\(firstName[firstName.startIndex])\(lastName[lastName.startIndex])"
        initialsLabel.textColor = UIColor.lightGrayColor()
        initialsLabel.textAlignment = .Center
        initialsLabel.font = UIFont.proximaNovaRegularFontOfSize(30)
        initialsLabel.minimumScaleFactor = 10/30 // minimum/maximum
        initialsLabel.adjustsFontSizeToFitWidth = true
        addSubview(initialsLabel)
        
        let views = ["label": initialsLabel]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[label]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        
        //_profileURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square&width=300&height=300", [object objectForKey:ID_KEY]];
        
    }
}
