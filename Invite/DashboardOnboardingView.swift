//
//  DashboardOnboardingView.swift
//  Invite
//
//  Created by Ryan Jennings on 4/20/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(DashboardOnboardingView) class DashboardOnboardingView: UIView
{
    var titleLabel = UILabel()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        prepareView()
    }

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        prepareView()
    }
    
    func prepareView()
    {
        configureTitle()
        configureSteps()
    }
    
    func configureTitle()
    {
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont.inviteOnboardingBulletHeaderFont()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "Let's get started"
        self.addSubview(titleLabel)
        
        let views = ["title": titleLabel]

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[title]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[title]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    }
    
    func configureSteps()
    {
        let step1 = DashboardStepView(step: 1, title: "Lorem Ipsum", text: "Lorem ipsum")
        step1.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(step1)
        
        let views = ["title": titleLabel, "step1": step1]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[step1]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[title][step1]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    }
}

class DashboardStepView: UIView
{
    var step = 0
    var title = ""
    var text = ""
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    convenience init(step: Int, title: String, text: String)
    {
        self.init(frame: CGRectZero)
        self.step = step
        self.title = title
        self.text = text
        prepareView()
    }
    
    func prepareView()
    {
        configureNumber()
    }
    
    func configureNumber()
    {
        var number = UILabel()
        number.setTranslatesAutoresizingMaskIntoConstraints(false)
        number.textAlignment = .Center
        number.layer.cornerRadius = 20
        number.layer.borderWidth = 2
        number.layer.borderColor = UIColor.whiteColor().CGColor
        number.font = UIFont.proximaNovaSemiboldFontOfSize(14)
        number.backgroundColor = UIColor.clearColor()
        number.textColor = UIColor.whiteColor()
        number.text = "\(step)"
        self.addSubview(number)
        
        let views = ["number": number]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[number(40)]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[number(40)]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    }
}
