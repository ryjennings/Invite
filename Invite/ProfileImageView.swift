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
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.clipsToBounds = true
        addSubview(self.imageView)

        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.textColor = UIColor.inviteBackgroundSlateColor()
        self.label.backgroundColor = UIColor.clearColor()
        self.label.textAlignment = .Center
        self.label.font = UIFont.proximaNovaRegularFontOfSize(14)
        self.label.layer.borderWidth = 2
        self.label.layer.borderColor = UIColor.whiteColor().CGColor
        self.label.clipsToBounds = true
        addSubview(self.label)
        
        self.responseCircle.translatesAutoresizingMaskIntoConstraints = false
        self.responseCircle.backgroundColor = UIColor.clearColor()
        self.responseCircle.layer.borderWidth = 2
        self.responseCircle.clipsToBounds = true
        addSubview(self.responseCircle)
        
        let views = ["imageView": self.imageView, "label": self.label, "response": self.responseCircle]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-1-[imageView]-1-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-1-[imageView]-1-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-1-[label]-1-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-1-[label]-1-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[response]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[response]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    func configureForPerson(person: AnyObject, event: PFObject?, width: CGFloat, showResponse: Bool)
    {
        self.imageView.layer.cornerRadius = event == nil ? 0 : (width / 2) - 1
        self.label.layer.cornerRadius = (width / 2) - 1
        self.responseCircle.layer.cornerRadius = width / 2
        
        let allResponses = event?[EVENT_RSVP_KEY] as? [String: UInt]

        var response = EventResponse.NoResponse
        var facebookId: String?
        var text: String?
        
        if person is String {
            if let email = person as? String where (person as? String)?.characters.count > 0 {
                text = "\(email[email.startIndex])"
            }
            self.responseCircle.hidden = false
            self.label.hidden = false
            self.layer.cornerRadius = 0
            self.layer.borderWidth = 0
        } else if person is PFObject {
            if let parse = person as? PFObject {
                facebookId = parse[FACEBOOK_ID_KEY] as? String
                if let r = allResponses?[AppDelegate.keyFromEmail(parse[EMAIL_KEY] as? String)], rr = EventResponse(rawValue: r) {
                    response = rr
                }
                let fullText = parse[FIRST_NAME_KEY] as? String ?? parse[EMAIL_KEY] as? String
                if let fullText = fullText where fullText.characters.count > 0 {
                    text = "\(fullText[fullText.startIndex])"
                }
            }
            self.responseCircle.hidden = false
            self.label.hidden = false
            self.layer.cornerRadius = 0
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
            self.layer.cornerRadius = width / 2
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
        
        if showResponse {
            switch response {
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
            self.responseCircle.layer.borderColor = UIColor.inviteBackgroundSlateColor().CGColor
        }
    }
}
