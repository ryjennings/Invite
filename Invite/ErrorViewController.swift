//
//  ErrorViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 4/26/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(ErrorViewController) class ErrorViewController: UIViewController
{
    var message: String!
    var tapGesture: UITapGestureRecognizer!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.view.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        prepareView()
        
        tapGesture = UITapGestureRecognizer(target: self, action: "didTap:")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func prepareView()
    {
        configureBlurBackground()
        configureMessage()
    }

    func configureBlurBackground()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        var blurView = UIVisualEffectView(effect: blurEffect)
        blurView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(blurView)
        
        let views = ["blurView": blurView]
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[blurView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[blurView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    }
    
    func configureMessage()
    {
        var vibrancyEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark))
        var vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(vibrancyView)
        
        var label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textAlignment = .Center
        label.backgroundColor = UIColor.clearColor()
        vibrancyView.contentView.addSubview(label)
        
        var att = NSMutableAttributedString()
        att.appendAttributedString(NSAttributedString(string: message, attributes: [NSFontAttributeName: UIFont.inviteQuestionFont()]))
        att.appendAttributedString(NSAttributedString(string: "\n\nTap to dismiss", attributes: [NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(14)]))
        label.attributedText = att
        
        let views = ["vibrancy": vibrancyView, "label": label]
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[vibrancy]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[vibrancy]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        vibrancyView.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[label]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        vibrancyView.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    }
    
    func didTap(tapGesture: UITapGestureRecognizer)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
