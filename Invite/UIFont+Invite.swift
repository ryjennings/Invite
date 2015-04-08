
//
//  UIFont+Invite.swift
//  Invite
//
//  Created by Ryan Jennings on 4/6/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

extension UIFont
{
    // MARK: - Proxima Nova
    
    public class func proximaNovaSemiboldFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNova-Semibold", size: size)!
    }
    
    public class func proximaNovaBlackFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNova-Black", size: size)!
    }
    
    public class func proximaNovaRegularFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNova-Regular", size: size)!
    }
    
    public class func proximaNovaLightItalicFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNova-LightIt", size: size)!
    }
    
    public class func proximaNovaSemiboldItalicFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNova-SemiboldIt", size: size)!
    }
    
    public class func proximaNovaExtraboldFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNova-Extrabld", size: size)!
    }
    
    public class func proximaNovaRegularItalicFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNova-RegularIt", size: size)!
    }
    
    public class func proximaNovaLightFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNova-Light", size: size)!
    }
    
    public class func proximaNovaBoldFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNova-Bold", size: size)!
    }
    
    public class func proximaNovaBoldItalicFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNova-BoldIt", size: size)!
    }
    
    // MARK: - Proxima Nova Cond

    public class func proximaNovaCondSemiboldItalicFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNovaCond-SemiboldIt", size: size)!
    }
    
    public class func proximaNovaCondSemiboldFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNovaCond-Semibold", size: size)!
    }
    
    public class func proximaNovaCondRegularFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNovaCond-Regular", size: size)!
    }
    
    public class func proximaNovaCondLightFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNovaCond-Light", size: size)!
    }
    
    public class func proximaNovaCondRegularItalicFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNovaCond-RegularIt", size: size)!
    }
    
    public class func proximaNovaCondLightItalicFontOfSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "ProximaNovaCond-LightIt", size: size)!
    }
    
    // MARK: - App Styles
    
    public class func inviteNavigationTitleFont() -> UIFont
    {
        return UIFont.proximaNovaRegularFontOfSize(16)
    }
    
    public class func inviteNavigationButtonFont() -> UIFont
    {
        return UIFont.proximaNovaRegularFontOfSize(14)
    }
    
    public class func inviteTableHeaderFont() -> UIFont
    {
        return UIFont.proximaNovaSemiboldFontOfSize(14)
    }
    
    public class func inviteTableLabelFont() -> UIFont
    {
        return UIFont.proximaNovaRegularFontOfSize(14)
    }
    
    public class func inviteTitleFont() -> UIFont
    {
        return UIFont.proximaNovaLightFontOfSize(36)
    }
    
    public class func inviteOnboardingBulletHeaderFont() -> UIFont
    {
        return UIFont.proximaNovaBoldFontOfSize(16)
    }
    
    public class func inviteOnboardingBulletTextFont() -> UIFont
    {
        return UIFont.proximaNovaRegularFontOfSize(14)
    }
    
    public class func inviteOnboardingContinueFont() -> UIFont
    {
        return UIFont.proximaNovaRegularFontOfSize(16)
    }
    
    public class func inviteDialogButtonFont() -> UIFont
    {
        return UIFont.proximaNovaSemiboldFontOfSize(12)
    }
    
    public class func inviteDialogTableLabelFont() -> UIFont
    {
        return UIFont.proximaNovaRegularFontOfSize(15)
    }
    
    public class func inviteWelcomeMessageFont() -> UIFont
    {
        return UIFont.proximaNovaRegularFontOfSize(16)
    }
    
    public class func inviteWelcomeContinueFont() -> UIFont
    {
        return UIFont.proximaNovaRegularFontOfSize(19)
    }
    
    public class func inviteAnnotationFont() -> UIFont
    {
        return UIFont.proximaNovaSemiboldFontOfSize(20)
    }
    
    public class func inviteTimeframeHourFont() -> UIFont
    {
        return UIFont.proximaNovaRegularFontOfSize(14)
    }
    
    public class func inviteTimeframeDayFont() -> UIFont
    {
        return UIFont.proximaNovaSemiboldFontOfSize(20)
    }

    public class func inviteTimeframeMonthFont() -> UIFont
    {
        return UIFont.proximaNovaSemiboldFontOfSize(10)
    }
    
    public class func inviteTimeframeTableLabelFont() -> UIFont
    {
        return UIFont.proximaNovaSemiboldFontOfSize(12)
    }
    
    public class func inviteTimeframeTableButtonFont() -> UIFont
    {
        return UIFont.proximaNovaSemiboldFontOfSize(10)
    }
    
    public class func inviteSearchFont() -> UIFont
    {
        return UIFont.proximaNovaRegularFontOfSize(15)
    }
    
    public class func inviteQuestionFont() -> UIFont
    {
        return UIFont.proximaNovaLightFontOfSize(26)
    }
    
    public class func inviteTableFooterFont() -> UIFont
    {
        return UIFont.proximaNovaRegularFontOfSize(13)
    }
    
    public class func inviteButtonTitleFont() -> UIFont
    {

//        let fontFeatureSettings: [[String: AnyObject]] = [[UIFontFeatureTypeIdentifierKey: 37], [UIFontFeatureSelectorIdentifierKey: 1]]
//        let fontAttributes = [UIFontDescriptorFeatureSettingsAttribute: fontFeatureSettings, UIFontDescriptorNameAttribute: "ProximaNova-Semibold"]
//        let fontDescriptor = UIFontDescriptor(fontAttributes: fontAttributes)
//        
//        
//        return [UIFont fontWithDescriptor:fontDescriptor size:size];
        
        return UIFont.proximaNovaSemiboldFontOfSize(14)
    }
}
