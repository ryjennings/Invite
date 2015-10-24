//
//  InviteTheme.swift
//  Invite
//
//  Created by Ryan Jennings on 3/31/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc class InviteTheme: NSObject
{
    class func customizeAppAppearance()
    {
        UIView.appearanceObjC()
        
        // MARK: - UINavigationBar
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "navbar_gradient"), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.inviteNavigationTitleFont()]
        UINavigationBar.appearance().translucent = true
        
        UISearchBar.appearance().backgroundImage = UIImage()
        UISearchBar.appearance().barTintColor = UIColor.inviteDarkBlueColor()
        UISearchBar.appearance().tintColor = UIColor.whiteColor()
        
        // MARK: - UIBarButtonItem
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.inviteNavigationButtonFont(), NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.inviteNavigationButtonFont(), NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.5)], forState: .Disabled)
    }
}
