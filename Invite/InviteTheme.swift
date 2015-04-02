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
        InviteTheme.themeNavigationBar()
    }
    
    class func themeNavigationBar()
    {
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.13, green: 0.84, blue: 0.47, alpha: 1.0)
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(16)]
        
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14)], forState: .Normal)
    }
}
