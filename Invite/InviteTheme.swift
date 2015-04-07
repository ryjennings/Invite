//
//  InviteTheme.swift
//  Invite
//
//  Created by Ryan Jennings on 3/31/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc public class InviteTheme: NSObject
{
    class func customizeAppAppearance()
    {
        UIView.appearanceObjC()
        
        // MARK: - UINavigationBar
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = UIColor.inviteGreenColor()
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.inviteNavigationTitleFont()]
        
        // MARK: - UIBarButtonItem
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.inviteNavigationButtonFont()], forState: .Normal)
        
        // MARK: - UIButton
        
        UIButton.appearance().setTitleColor(UIColor.inviteButtonTitleColor(), forState: .Normal)
        UIButton.appearance().backgroundColor = UIColor.inviteButtonBackgroundColor()
    }
}
