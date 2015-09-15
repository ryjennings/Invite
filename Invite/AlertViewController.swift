//
//  AlertViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 5/15/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController
{
    var darkness = UIView()
    var blurView: UIVisualEffectView!
    var tap = UITapGestureRecognizer()
    
    var text: String!
    
    var alert: AlertViewController!
    weak var vc: UIViewController!
    
    class func alert(text: String, vc: UIViewController)
    {
        let alert = AlertViewController()
        alert.text = text
        alert.modalPresentationStyle = .Custom
        alert.modalTransitionStyle = .CrossDissolve
        alert.vc = vc
        alert.vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        alert = self
        
        prepareDarkness()
        prepareContainer()
        prepareLabel()
        prepareTap()

        // Do any additional setup after loading the view.
    }
    
    func prepareDarkness()
    {
        darkness.translatesAutoresizingMaskIntoConstraints = false
        darkness.backgroundColor = UIColor.blackColor()
        darkness.alpha = 0.5
        self.view.addSubview(darkness)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[darkness]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["darkness": darkness]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[darkness]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["darkness": darkness]))
    }
    
    func prepareContainer()
    {
        let blurEffect = UIBlurEffect(style: .Dark)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = CGFloat(kCornerRadius)
        blurView.clipsToBounds = true
        self.view.addSubview(blurView)
        self.view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 300))
        self.view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    func prepareLabel()
    {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let style = NSMutableParagraphStyle()
        style.alignment = .Center
        let att = NSMutableAttributedString()
        att.appendAttributedString(NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSParagraphStyleAttributeName: style, NSFontAttributeName: UIFont.proximaNovaLightFontOfSize(20)]))
        att.appendAttributedString(NSAttributedString(string: "\n\n"))
        att.appendAttributedString(NSAttributedString(string: "Okay", attributes: [NSForegroundColorAttributeName: UIColor.inviteBlueColor(), NSParagraphStyleAttributeName: style, NSFontAttributeName: UIFont.proximaNovaSemiboldFontOfSize(18)]))
        
        label.attributedText = att;
        label.backgroundColor = UIColor.clearColor()
        label.numberOfLines = 0
        blurView.addSubview(label)
        blurView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-25-[label]-25-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["label": label]))
        blurView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-50-[label]-50-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["label": label]))
    }

    func prepareTap()
    {
        tap.addTarget(self, action: "didTap:")
        blurView.addGestureRecognizer(tap)
    }
    
    func didTap(tap: UITapGestureRecognizer)
    {
        self.vc.dismissViewControllerAnimated(true, completion: {
            self.alert = nil
        })
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
