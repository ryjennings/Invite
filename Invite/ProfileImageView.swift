//
//  ProfileImageView.swift
//  Invite
//
//  Created by Ryan Jennings on 3/31/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView
{
    let label = UILabel()
    let responseCircle = UIView()
    let imageView = UIImageView()

    override func awakeFromNib()
    {
        setup()
    }
    
    func setup()
    {
        self.clipsToBounds = true
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.clipsToBounds = true
        addSubview(self.imageView)
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.textColor = UIColor.inviteBackgroundSlateColor()
        self.label.backgroundColor = UIColor.clearColor()
        self.label.textAlignment = .Center
        self.label.font = UIFont.proximaNovaRegularFontOfSize(14)
        self.label.layer.borderColor = UIColor.whiteColor().CGColor
        self.label.clipsToBounds = true
        addSubview(self.label)
        
        self.responseCircle.translatesAutoresizingMaskIntoConstraints = false
        self.responseCircle.backgroundColor = UIColor.clearColor()
        self.responseCircle.layer.borderWidth = 2
        self.responseCircle.clipsToBounds = true
        addSubview(self.responseCircle)
    }
    
    @objc func configureForPerson(person: AnyObject, responseValue: UInt, width: CGFloat, showResponse: Bool)
    {
        let views = ["imageView": self.imageView, "label": self.label, "response": self.responseCircle]
        let metrics = ["padding": showResponse ? 1 : 1]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-padding-[imageView]-padding-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-padding-[imageView]-padding-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-padding-[label]-padding-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-padding-[label]-padding-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[response]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[response]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))

        self.label.layer.borderWidth = showResponse ? 2 : 0

        let response = EventResponse(rawValue: responseValue)
        
        self.imageView.layer.cornerRadius = (width / 2) - (showResponse ? 1 : 1)
        self.label.layer.cornerRadius = (width / 2) - (showResponse ? 1 : 1)
        self.responseCircle.layer.cornerRadius = width / 2
        self.layer.cornerRadius = width / 2
        
        var facebookId: String?
        var text: String?
        
        if person is String {
            if let email = person as? String where (person as? String)?.characters.count > 0 {
                text = "\(email[email.startIndex])"
            }
            self.responseCircle.hidden = false
            self.label.hidden = false
            self.layer.borderWidth = 0
        } else if person is PFObject {
            if let parse = person as? PFObject {
                facebookId = parse[FACEBOOK_ID_KEY] as? String

//                for eventResponse in event?[EVENT_RESPONSES_KEY] as! [String] {
//                    let com = eventResponse.componentsSeparatedByString(":")
//                    if com[0] == person[EMAIL_KEY] as! String {
//                        response = EventResponse(rawValue: UInt(com[1])!)!
//                    }
//                }

                let fullText = parse[FIRST_NAME_KEY] as? String ?? parse[EMAIL_KEY] as? String
                if let fullText = fullText where fullText.characters.count > 0 {
                    text = "\(fullText[fullText.startIndex])"
                }
            }
            self.responseCircle.hidden = false
            self.label.hidden = false
            self.layer.borderWidth = 0
        } else {
            if let friend = person as? Friend {
                facebookId = friend.pfObject?[FACEBOOK_ID_KEY] as? String
                let fullText = friend.fullName ?? friend.email
                if fullText.characters.count > 0 {
                    text = "\(fullText[fullText.startIndex])"
                }
                if let pfObject = friend.pfObject {
                    self.layer.borderWidth = pfObject[FACEBOOK_ID_KEY] == nil ? 0 : 1
                } else {
                    self.layer.borderWidth = 0
                }
            }
            self.responseCircle.hidden = true
            self.label.hidden = true
        }
        
        if let facebookId = facebookId {
            self.imageView.sd_setImageWithURL(NSURL(string: "https://graph.facebook.com/\(facebookId)/picture?type=large&scrape=true"), placeholderImage: nil, completed: {
                (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                if showResponse && response == EventResponse.NoResponse {
                    self.imageView.image = self.imageView.image?.tintedImageWithColor(UIColor.inviteLightSlateColor(), blendMode: CGBlendMode.SoftLight) // SoftLight, Overlay, Screen work best
                }
            })
            self.label.text = ""
        } else {
            self.imageView.image = nil
            if let text = text {
                self.label.text = text.uppercaseString
            } else {
                self.label.text = ""
            }
        }
        
        if showResponse && response != nil {
            switch response! {
            case EventResponse.NoResponse:
                self.responseCircle.layer.borderColor = UIColor.inviteBackgroundSlateColor().CGColor
                self.imageView.alpha = 0.25
            case EventResponse.Going:
                self.responseCircle.layer.borderColor = UIColor.inviteGreenColor().CGColor
                self.imageView.alpha = 1
            case EventResponse.Sorry:
                self.responseCircle.layer.borderColor = UIColor.inviteRedColor().CGColor
                self.imageView.alpha = 1
            case EventResponse.Maybe:
                self.responseCircle.layer.borderColor = UIColor.inviteYellowColor().CGColor
                self.imageView.alpha = 1
            default:
                break
            }
        } else {
            self.responseCircle.layer.borderColor = UIColor.clearColor().CGColor
        }
    }
}
