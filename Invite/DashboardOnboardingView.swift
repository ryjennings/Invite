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
    var subtitleLabel = UILabel()
    var lineView = UIView()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        prepareView()
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        prepareView()
    }
    
    func prepareView()
    {
        configureTitle()
        configureSubtitle()
        configureLine()
        configureSteps()
    }
    
    func configureTitle()
    {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont.inviteQuestionFont()
        titleLabel.textColor = UIColor.inviteTableHeaderColor()
        titleLabel.text = "Let's get started"
        self.addSubview(titleLabel)
        
        let views = ["title": titleLabel]

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[title]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    func configureSubtitle()
    {
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.backgroundColor = UIColor.clearColor()
        subtitleLabel.textAlignment = .Center
        subtitleLabel.font = UIFont.proximaNovaRegularFontOfSize(16)
        subtitleLabel.textColor = UIColor.inviteTableHeaderColor()
        subtitleLabel.text = "To create an event, follow these steps:"
        self.addSubview(subtitleLabel)
        
        let views = ["subtitle": subtitleLabel, "title": titleLabel]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subtitle]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[title]-10-[subtitle]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    func configureLine()
    {
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        self.addSubview(lineView)
        
        let views = ["line": lineView, "subtitle": subtitleLabel]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[line]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[subtitle]-10-[line(1)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    func configureSteps()
    {
        var titles = ["Enter a title", "Choose guests", "Set a date and time", "Select a location", "Review and send!"]
        var texts = [
            "What will you be calling your event? Is it a birthday? New Years party? Meetup? Give you're guests a reason to attend!",
            "Who are you inviting to the event? Guests should have a Facebook account, so keep that in mind.",
            "When is the event starting and ending? Are you scheduling an overnight study group, you hooligan? Events can span multiple days!",
            "Where will you be having the event? School? Work? Aunt Edna's spooky cabin in the woods? We've made it easy for you to choose!",
            "If something changes later, you can always come back and make changes. No worries."
        ]
        var steps = [DashboardStepView]()
        for i in 0...4 {
            
            var lastView: UIView
            
            if steps.count == 0 {
                lastView = lineView
            } else {
                lastView = steps.last!
            }
            
            let step = DashboardStepView(step: i + 1, title: titles[i], text: texts[i])
            step.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(step)
            steps.append(step)
            
            let views = ["last": lastView, "step": step]
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[step]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            
            if (i == 4) {
                self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[last]-25-[step]-30-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            } else {
                self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[last]-25-[step]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            }
        }
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
    
    required init?(coder aDecoder: NSCoder)
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
        let number = UILabel()
        number.translatesAutoresizingMaskIntoConstraints = false
        number.textAlignment = .Center
        number.layer.cornerRadius = 20
        number.layer.borderWidth = 2
        number.layer.borderColor = UIColor.inviteBlueColor().CGColor
        number.clipsToBounds = true
        number.font = UIFont.proximaNovaRegularFontOfSize(16)
        number.backgroundColor = UIColor.whiteColor()
        number.textColor = UIColor.inviteBlueColor()
        number.text = "\(step)"
        self.addSubview(number)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.proximaNovaSemiboldFontOfSize(14)
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.inviteBlueColor()
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        self.addSubview(titleLabel)
        
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.backgroundColor = UIColor.clearColor()
        textLabel.preferredMaxLayoutWidth = (SDiPhoneVersion.deviceSize() == DeviceSize.iPhone35inch || SDiPhoneVersion.deviceSize() == DeviceSize.iPhone4inch) ? 230 : 250
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        let att = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(12), NSForegroundColorAttributeName: UIColor.grayColor(), NSParagraphStyleAttributeName: style])
        
        textLabel.attributedText = att
        textLabel.numberOfLines = 0
        self.addSubview(textLabel)
        
        let views = ["number": number, "title": titleLabel, "text": textLabel]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[number(40)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[number(40)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[number]-10-[title]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[number]-10-[text]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[title]-10-[text]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
}
