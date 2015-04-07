//
//  UIColor+Invite.swift
//  Invite
//
//  Created by Ryan Jennings on 4/2/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

extension UIColor
{
    // MARK: - Invite Colors
    
    public class func inviteSlateColor() -> UIColor
    {
        return UIColor(red: 56/255, green: 68/255, blue: 79/255, alpha: 1)
    }
    
    public class func inviteOverlayColor() -> UIColor
    {
        return UIColor(red: 56/255, green: 68/255, blue: 79/255, alpha: 0.75)
    }
    
    public class func inviteLightSlateColor() -> UIColor
    {
        return UIColor(red: 152/255, green: 184/255, blue: 204/255, alpha: 1)
    }
    
    public class func inviteGrayColor() -> UIColor
    {
        return UIColor(red: 194/255, green: 200/255, blue: 207/255, alpha: 1)
    }
    
    public class func inviteAccentLineGrayColor() -> UIColor
    {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    }
    
    public class func inviteBackgroundSlateColor() -> UIColor
    {
        return UIColor(red: 233/255, green: 240/255, blue: 245/255, alpha: 1)
    }
    
    public class func inviteGreenColor() -> UIColor
    {
        return UIColor(red: 0, green: 217/255, blue: 116/255, alpha: 1)
    }
    
    public class func inviteRedColor() -> UIColor
    {
        return UIColor(red: 255/255, green: 54/255, blue: 51/255, alpha: 1)
    }
    
    public class func inviteBlueColor() -> UIColor
    {
        return UIColor(red: 44/255, green: 152/255, blue: 222/255, alpha: 1)
    }
    
    public class func inviteDarkBlueColor() -> UIColor
    {
        return UIColor(red: 64/255, green: 102/255, blue: 128/255, alpha: 1)
    }
    
    // MARK: - App Styles
    
    public class func inviteNavigationSubviewColor() -> UIColor
    {
        return UIColor.whiteColor()
    }
    
    public class func inviteOnboardingColor() -> UIColor
    {
        return UIColor.whiteColor()
    }
    
    public class func inviteQuestionColor() -> UIColor
    {
        return UIColor.inviteDarkBlueColor()
    }
    
    public class func inviteTableHeaderColor() -> UIColor
    {
        return UIColor.inviteDarkBlueColor()
    }
    
    public class func inviteTableLabelColor() -> UIColor
    {
        return UIColor.inviteLightSlateColor()
    }
    
    public class func inviteBlueLinkColor() -> UIColor
    {
        return UIColor.inviteBlueColor()
    }
    
    public class func inviteButtonTitleColor() -> UIColor
    {
        return UIColor.whiteColor()
    }
    
    public class func inviteButtonBackgroundColor() -> UIColor
    {
        return UIColor.inviteBlueColor()
    }
    
    public class func inviteOnboardingButtonBackgroundColor() -> UIColor
    {
        return UIColor(red: 0.29, green: 0.89, blue: 0.60, alpha: 1.0)
    }
}
