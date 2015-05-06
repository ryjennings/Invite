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
//    - (void)drawRect:(CGRect)rect
//    {
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextAddEllipseInRect(ctx, rect);
//    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor blueColor] CGColor]));
//    CGContextFillPath(ctx);
//    }
    
    override func awakeFromNib()
    {
        backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect)
    {
//        UIBezierPath *path = [UIBezierPath bezierPath];
//        CGPoint point = CGPointMake(0, 50);
//        CGFloat radius = 20.0;
//        CGFloat lineLength = 45.0;
//        
//        [path moveToPoint:point];
//        point.x += lineLength;
//        [path addLineToPoint:point];
//        point.x += radius;
//        [path addArcWithCenter:point radius:radius startAngle:M_PI endAngle:M_PI * 2.0 clockwise:YES];
//        point.x += radius * 2.0;
//        [path addArcWithCenter:point radius:radius startAngle:M_PI endAngle:M_PI * 2.0 clockwise:YES];
//        point.x += radius * 2.0;
//        [path addArcWithCenter:point radius:radius startAngle:M_PI endAngle:M_PI * 2.0 clockwise:YES];
//        point.x += radius * 2.0;
//        [path addArcWithCenter:point radius:radius startAngle:M_PI endAngle:M_PI * 2.0 clockwise:YES];
//        point.x += lineLength + radius;
//        [path addLineToPoint:point];
//        
//        path.lineWidth = 2.0;
//        [[UIColor blackColor] setStroke];
//        [[UIColor clearColor] setFill];
//        
//        [path stroke];
        
        var path = UIBezierPath()
        let radius: CGFloat = 10
        path.addArcWithCenter(CGPointMake(10, 10), radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(M_PI * 2), clockwise: true) // full circle
        UIColor.inviteGreenColor().setFill()
        path.fill()
        
    }
}
