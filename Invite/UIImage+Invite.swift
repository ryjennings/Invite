//
//  UIImage+Invite.swift
//  Invite
//
//  Created by Ryan Jennings on 10/8/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

extension UIImage
{
    func tintedImageWithColor(color: UIColor, blendMode: CGBlendMode) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        color.setFill()
        let bounds = CGRectMake(0, 0, self.size.width, self.size.height)
        UIRectFill(bounds)
        self.drawInRect(bounds, blendMode: blendMode, alpha: 1)
        if blendMode != CGBlendMode.DestinationIn {
            self.drawInRect(bounds, blendMode: CGBlendMode.DestinationIn, alpha: 1)
        }
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage
    }
}
