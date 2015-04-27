//
//  ACAlertView.swift
//  Ancestry
//
//  Created by Ryan Jennings on 3/2/15.
//  Copyright (c) 2015 Ancestry.com. All rights reserved.
//

import UIKit
import Foundation

@objc public class ACAlertView : UIView, UITextFieldDelegate {
    
    let kDefaultFontSize: CGFloat = 16.0
    
    var container: UIView!
    var title: String!
    var message: String!
    var placeholder: String!
    var cancelButtonTitle: String!
    var actionButtonTitle: String!
    var actionHandler: ((secureText: String) -> Void)!

    var cancelButton = UIButton()
    var actionButton = UIButton()

    public var titleFont: UIFont?
    public var messageFont: UIFont?
    public var buttonFont: UIFont?
    
    public var titleTextColor: UIColor?
    public var messageTextColor: UIColor?
    public var cancelButtonTextColor: UIColor?
    public var actionButtonTextColor: UIColor?
    
    var secureField: UITextField!
    var alertViewCenterYConstraint: NSLayoutConstraint!
    var showSecureField: Bool! = false
    var defaultDisabledButtonTextColor: UIColor = UIColor.blackColor()
    var defaultEnabledButtonTextColor: UIColor = UIColor.blackColor()
    var borderColor: UIColor = UIColor.blackColor()
    
    // Storing a reference to itself so we can nil out the reference when the alert is dismissed. This means the user is not responsible for the nil
    var alert: ACAlertView!

    // MARK: ACAlertView

    class func passwordAlertView(#title: String?, message: String?, placeholder: String?, cancelButtonTitle: String?, actionButtonTitle: String?, actionHandler: (secureText: String) -> Void) -> ACAlertView
    {
        var alert = ACAlertView()
        alert.title = title
        alert.message = message
        alert.placeholder = placeholder
        if (count(alert.placeholder) > 0) {
            alert.showSecureField = true
        } else {
            alert.showSecureField = false
        }
        alert.cancelButtonTitle = cancelButtonTitle
        alert.actionButtonTitle = actionButtonTitle
        alert.actionHandler = actionHandler

        return alert
    }
    
    public func close()
    {
        fadeOutAlert()
    }
    
    func show()
    {
        alert = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRotate:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        let window = UIApplication.sharedApplication().keyWindow
        
        if window == nil {
            return
        }
        
        // View to block input
        container = UIView(frame: CGRectMake(0, 0, 2000, 2000))
        container.center = window!.center
        container.alpha = 0
        container.autoresizingMask = .FlexibleTopMargin | .FlexibleBottomMargin | .FlexibleLeftMargin | .FlexibleRightMargin
        container.setTranslatesAutoresizingMaskIntoConstraints(true)
        window!.addSubview(container)
        
        var background = UIView()
        background.setTranslatesAutoresizingMaskIntoConstraints(false)
        background.backgroundColor = UIColor.blackColor()
        background.alpha = 0.4
        container.addSubview(background)
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[background]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["background": background]))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[background]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["background": background]))
        
        var alertView = UIView()
        alertView.setTranslatesAutoresizingMaskIntoConstraints(false)
        alertView.clipsToBounds = true
        alertView.layer.cornerRadius = 5
        alertView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        container.addSubview(alertView)
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[alertView(270)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["alertView": alertView]))
        
        alertViewCenterYConstraint = NSLayoutConstraint(item: alertView, attribute: .CenterY, relatedBy: .Equal, toItem: container, attribute: .CenterY, multiplier: 1, constant: 0)
        container.addConstraint(alertViewCenterYConstraint)
        
        container.addConstraint(NSLayoutConstraint(item: alertView, attribute: .CenterX, relatedBy: .Equal, toItem: container, attribute: .CenterX, multiplier: 1, constant: 0))
        
        var titleLabel = UILabel()
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.numberOfLines = 0
        titleLabel.text = title ?? "No title set"
        titleLabel.textAlignment = .Center
        titleLabel.textColor = titleTextColor ?? UIColor.blackColor()
        titleLabel.font = titleFont ?? UIFont.boldSystemFontOfSize(kDefaultFontSize)
        alertView.addSubview(titleLabel)
        
        var messageLabel = UILabel()
        messageLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        messageLabel.backgroundColor = UIColor.clearColor()
        messageLabel.numberOfLines = 0
        messageLabel.text = message ?? "No message set"
        messageLabel.textAlignment = .Center
        messageLabel.textColor = messageTextColor ?? UIColor.blackColor()
        messageLabel.font = messageFont ?? UIFont.systemFontOfSize(kDefaultFontSize)
        alertView.addSubview(messageLabel)
        
        cancelButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        cancelButton.setTitle(cancelButtonTitle ?? "No title set", forState: .Normal)
        cancelButton.setTitleColor(cancelButtonTextColor ?? defaultEnabledButtonTextColor, forState: .Normal)
        cancelButton.titleLabel?.font = buttonFont ?? UIFont.systemFontOfSize(kDefaultFontSize)
        cancelButton.addTarget(self, action: "cancelButtonTapped:", forControlEvents: .TouchUpInside)
        alertView.addSubview(cancelButton)
        
        actionButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        actionButton.setTitle(actionButtonTitle ?? "No title set", forState: .Normal)
        actionButton.titleLabel?.font = buttonFont ?? UIFont.systemFontOfSize(kDefaultFontSize)
        actionButton.addTarget(self, action: "actionButtonTapped:", forControlEvents: .TouchUpInside)
        if (showSecureField == true) {
            actionButton.enabled = false
            actionButton.setTitleColor(defaultDisabledButtonTextColor, forState: .Normal)
        } else {
            actionButton.setTitleColor(actionButtonTextColor ?? defaultEnabledButtonTextColor, forState: .Normal)
        }
        alertView.addSubview(actionButton)

        var vertLine = UIView()
        vertLine.setTranslatesAutoresizingMaskIntoConstraints(false)
        vertLine.backgroundColor = borderColor
        alertView.addSubview(vertLine)

        var horzLine = UIView()
        horzLine.setTranslatesAutoresizingMaskIntoConstraints(false)
        horzLine.backgroundColor = borderColor
        alertView.addSubview(horzLine)

        var views = ["titleLabel": titleLabel, "messageLabel": messageLabel, "cancelButton": cancelButton, "actionButton": actionButton, "vertLine": vertLine, "horzLine": horzLine]

        if (showSecureField == true) {
            secureField = UITextField()
            let paddingView = UIView(frame: CGRectMake(0, 0, 10, self.secureField.frame.height))
            secureField.leftView = paddingView
            secureField.leftViewMode = UITextFieldViewMode.Always
            secureField.setTranslatesAutoresizingMaskIntoConstraints(false)
            secureField.delegate = self
            secureField.secureTextEntry = true
            secureField.placeholder = placeholder ?? "No placeholder set"
            secureField.font = messageFont ?? UIFont.systemFontOfSize(kDefaultFontSize)
            secureField.layer.borderColor = borderColor.CGColor
            secureField.layer.borderWidth = 1
            secureField.textAlignment = .Left
            secureField.addTarget(self, action: "secureFieldEditingChanged:", forControlEvents: .EditingChanged)
            alertView.addSubview(secureField)
            views["secureField"] = secureField
        }

        alertView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[titleLabel]-15-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        alertView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[messageLabel]-15-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        alertView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[horzLine]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        alertView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[cancelButton][vertLine(1)][actionButton]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        alertView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[titleLabel]-12-[messageLabel]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        alertView.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .Width, relatedBy: .Equal, toItem: actionButton, attribute: .Width, multiplier: 1, constant: 0))
        
        if (showSecureField == true) {
            alertView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[secureField]-30-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
            alertView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[messageLabel]-20-[secureField(26)]-25-[horzLine(1)]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        } else {
            alertView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[messageLabel]-20-[horzLine(1)]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        }

        alertView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[horzLine(1)][cancelButton(40)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        alertView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[actionButton(40)]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        alertView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[horzLine(1)][vertLine]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        alertView.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .Top, relatedBy: .Equal, toItem: actionButton, attribute: .Top, multiplier: 1, constant: 0))
        
        UIView.animateWithDuration(0.5, animations: {
            self.container.alpha = 1
        })
    }

    // MARK: Buttons

    func cancelButtonTapped(sender: UIButton!)
    {
        fadeOutAlert()
    }

    func actionButtonTapped(sender: UIButton!)
    {
        actionHandler(secureText: showSecureField == true ? secureField.text : "")
    }
    
    func fadeOutAlert()
    {
        if (showSecureField == true) {
            secureField.resignFirstResponder()
        }
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions(0), animations: {
            self.container.alpha = 0
            }, completion: { finished in
                if (self.showSecureField == true) {
                    self.secureField.delegate = nil
                }
                NSNotificationCenter.defaultCenter().removeObserver(self)
                self.alert = nil
        })
    }

    // MARK: UITextField

    func secureFieldEditingChanged(textField: UITextField!)
    {
        if (count(secureField.text) > 0) {
            actionButton.enabled = true
            actionButton.setTitleColor(actionButtonTextColor ?? defaultEnabledButtonTextColor, forState: .Normal)
        } else {
            actionButton.enabled = false
            actionButton.setTitleColor(defaultDisabledButtonTextColor, forState: .Normal)
        }
    }

    public func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        secureField.resignFirstResponder()
        return true
    }
    
    // MARK: Keyboard Notifications
    
    func keyboardWillShow(notification: NSNotification)
    {
        let userInfo = notification.userInfo!
        let rect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let keyboardOffset = rect.size.height / 2
        alertViewCenterYConstraint.constant = -keyboardOffset
        UIView.animateWithDuration(duration, animations: {
            self.container.layoutIfNeeded()
        })
    }

    func keyboardWillHide(notification: NSNotification)
    {
        let userInfo = notification.userInfo!
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        alertViewCenterYConstraint.constant = 0
        UIView.animateWithDuration(duration, animations: {
            self.container.layoutIfNeeded()
        })
    }
    
    func didRotate(notification: NSNotification)
    {
        let window = UIApplication.sharedApplication().keyWindow
        container.center = window!.center
    }
}
