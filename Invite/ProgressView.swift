//
//  ProgressView.swift
//  Invite
//
//  Created by Ryan Jennings on 4/7/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc public class ProgressView: UIView
{
    var step: Int!
    var steps: Int!
    var stepWidth: CGFloat!
    var rect: CGRect!
    let strokeWidth = 1
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    convenience public init(frame: CGRect, step: Int, steps: Int)
    {
        self.init(frame: frame)
        self.step = step
        self.steps = steps
        self.rect = frame
        self.backgroundColor = UIColor.clearColor()
    }

    required public init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override public func drawRect(rect: CGRect)
    {
        stepWidth = rect.size.width / CGFloat(steps)
        let height = rect.size.height - 2
        for i in 0..<steps {
            let currentRect = CGRectMake(((CGFloat(i) * stepWidth) + (stepWidth / 2)) - (height / 2), 1, height, height)
            ellipseInRect(currentRect, thisStep: i)
            if (i + 1 == step) {
                animateCurrentStepInRect(CGRectInset(currentRect, 1.5, 1.5))
            }
        }
    }
    
    func ellipseInRect(rect: CGRect, thisStep: Int)
    {
        var ctx = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextSetLineWidth(ctx, CGFloat(strokeWidth))
        if (thisStep < step - 1) {
            CGContextFillEllipseInRect(ctx, CGRectInset(rect, 1.5, 1.5))
        }
        CGContextStrokeEllipseInRect(ctx, rect)
    }
    
    func animateCurrentStepInRect(rect: CGRect)
    {
        var currentStepView = UIView()
        currentStepView.setTranslatesAutoresizingMaskIntoConstraints(false)
        currentStepView.backgroundColor = UIColor.whiteColor()
        currentStepView.layer.cornerRadius = rect.size.height / 2
        currentStepView.clipsToBounds = true
        addSubview(currentStepView)
        addConstraint(NSLayoutConstraint(item: currentStepView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: currentStepView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: (CGFloat(step) - 3) * stepWidth))
        addConstraint(NSLayoutConstraint(item: currentStepView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: rect.size.width))
        addConstraint(NSLayoutConstraint(item: currentStepView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: rect.size.height))
        currentStepView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0)
        
        AppDelegate.delay(0) {
            UIView.animateWithDuration(0.2, delay: 1, options: .CurveEaseInOut, animations: {
                currentStepView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2)
                }, completion: { finished in
                    UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
                        currentStepView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)
                        }, completion: nil)
            })
        }
    }
}
