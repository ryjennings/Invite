//
//  UIView+Invite.swift
//  Invite
//
//  Created by Ryan Jennings on 10/10/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

extension UIView
{
    func roundCorners(corners:UIRectCorner, radius: CGFloat)
    {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
}
