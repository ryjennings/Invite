//
//  LocationResultsViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 3/28/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc public class LocationResultsViewController: UIViewController
{
    public var locations: NSArray!
    
    required public init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: .Dark)
        var blurView = UIVisualEffectView(effect: blurEffect)
        blurView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(blurView)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[blurView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["blurView": blurView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[blurView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["blurView": blurView]))
    }
}