//
//  ConflictView.swift
//  Invite
//
//  Created by Ryan Jennings on 5/6/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(ConflictView) class ConflictView: UIView
{
//    var type = BusyDetailsCircle.Green {
//        didSet {
//            self.setNeedsDisplay()
//        }
//    }

    override func awakeFromNib()
    {
        backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect)
    {
//        let path = UIBezierPath()
//        let radius: CGFloat = 5
//        
//        switch type {
//        case .Green:
//            path.addArcWithCenter(CGPointMake(radius, radius), radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(M_PI * 2), clockwise: true) // full circle
//            UIColor.inviteGreenColor().setFill()
//            path.fill()
//        case .GreenRed:
//            path.addArcWithCenter(CGPointMake(radius, radius), radius: radius, startAngle: CGFloat(M_PI / 2), endAngle: CGFloat((3 * M_PI) / 2), clockwise: true) // first half
//            UIColor.inviteBlueAlphaColor().setFill()
//            path.fill()
//            
//            path.removeAllPoints()
//            
//            path.addArcWithCenter(CGPointMake(radius, radius), radius: radius, startAngle: CGFloat((3 * M_PI) / 2), endAngle: CGFloat(M_PI / 2), clockwise: true) // second half
//            UIColor.inviteBlueColor().setFill()
//            path.fill()
//        case .Red:
//            path.addArcWithCenter(CGPointMake(radius, radius), radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(M_PI * 2), clockwise: true) // full circle
//            UIColor.inviteRedColor().setFill()
//            path.fill()
//        case .RedGreen:
//            path.addArcWithCenter(CGPointMake(radius, radius), radius: radius, startAngle: CGFloat(M_PI / 2), endAngle: CGFloat((3 * M_PI) / 2), clockwise: true) // first half
//            UIColor.inviteBlueColor().setFill()
//            path.fill()
//            
//            path.removeAllPoints()
//            
//            path.addArcWithCenter(CGPointMake(radius, radius), radius: radius, startAngle: CGFloat((3 * M_PI) / 2), endAngle: CGFloat(M_PI / 2), clockwise: true) // second half
//            UIColor.inviteBlueAlphaColor().setFill()
//            path.fill()
//        }
    }
}
