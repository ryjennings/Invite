//
//  TitleDateCell.swift
//  Invite
//
//  Created by Ryan Jennings on 5/11/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(TitleDateCell) class TitleDateCell: UITableViewCell
{
    var attributedDate: NSAttributedString!
    var delegate: TitleDateCellDelegate?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateInsideCircle: UIView!
    
    @IBOutlet weak var goingButtonView: ResponseButtonView!
    @IBOutlet weak var maybeButtonView: ResponseButtonView!
    @IBOutlet weak var sorryButtonView: ResponseButtonView!
    
    @IBOutlet weak var dateLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var goingButtonViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var maybeButtonViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var sorryButtonViewLeadingConstraint: NSLayoutConstraint!
    
    var safe = true
    
    let leadingConstraintConstant: CGFloat = SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15
    let spacingBetweenButtons: CGFloat = 20
    let buttonWidth: CGFloat = 80
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        dateLabel.numberOfLines = 2
        dateLabel.layer.cornerRadius = 40
        dateLabel.clipsToBounds = true
        
        self.dateInsideCircle.backgroundColor = UIColor.inviteBackgroundSlateColor()
        self.dateInsideCircle.layer.cornerRadius = 34
        self.dateInsideCircle.clipsToBounds = true
        
        label.textColor = UIColor.inviteTableHeaderColor()
        label.font = UIFont.inviteTitleFont()
        label.numberOfLines = 0

        self.dateLabelLeadingConstraint.constant = leadingConstraintConstant
        self.selectionStyle = UITableViewCellSelectionStyle.Gray
        
        self.goingButtonView.configureForResponse(EventResponse.Going)
        self.maybeButtonView.configureForResponse(EventResponse.Maybe)
        self.sorryButtonView.configureForResponse(EventResponse.Sorry)
        
        self.goingButtonViewLeadingConstraint.constant = -80
        self.maybeButtonViewLeadingConstraint.constant = -80
        self.sorryButtonViewLeadingConstraint.constant = -80
    }
    
    func finalPositionForResponse(response: EventResponse) -> CGFloat
    {
        let buttonStartingPosition = (self.frame.size.width / 2) - (((buttonWidth * 3) + (spacingBetweenButtons * 2)) / 2)
        switch response {
        case EventResponse.Going:
            return buttonStartingPosition
        case EventResponse.Maybe:
            return buttonStartingPosition + buttonWidth + spacingBetweenButtons
        default:
            return buttonStartingPosition + (buttonWidth * 2) + (spacingBetweenButtons * 2)
        }
    }
    
    func showResponseButtons(response: EventResponse)
    {
        if !safe {
            return
        }
        self.safe = false
        
        self.dateLabel.hidden = true
        self.dateInsideCircle.hidden = true
        
        self.goingButtonView.button.alpha = 0
        self.maybeButtonView.button.alpha = 0
        self.sorryButtonView.button.alpha = 0
        
        self.goingButtonView.button.setTitle("Going", forState: UIControlState.Normal)
        self.goingButtonView.button.titleLabel?.font = UIFont.inviteTableSmallFont()
        self.goingButtonView.button.setTitleColor(UIColor.inviteTableHeaderColor(), forState: UIControlState.Normal)
        
        self.maybeButtonView.button.setTitle("Maybe", forState: UIControlState.Normal)
        self.maybeButtonView.button.titleLabel?.font = UIFont.inviteTableSmallFont()
        self.maybeButtonView.button.setTitleColor(UIColor.inviteTableHeaderColor(), forState: UIControlState.Normal)

        self.sorryButtonView.button.setTitle("Sorry", forState: UIControlState.Normal)
        self.sorryButtonView.button.titleLabel?.font = UIFont.inviteTableSmallFont()
        self.sorryButtonView.button.setTitleColor(UIColor.inviteTableHeaderColor(), forState: UIControlState.Normal)
        
        switch response {
        case EventResponse.Going:
            self.goingButtonView.label.attributedText = self.dateLabel.attributedText
            self.goingButtonViewLeadingConstraint.constant = leadingConstraintConstant
            self.maybeButtonViewLeadingConstraint.constant = self.frame.size.width + self.buttonWidth;
            self.sorryButtonViewLeadingConstraint.constant = self.frame.size.width + self.buttonWidth;
            self.layoutIfNeeded()
            
            self.goingButtonView.alpha = 1
            self.maybeButtonView.alpha = 1
            self.sorryButtonView.alpha = 1

            self.goingButtonViewLeadingConstraint.constant = self.finalPositionForResponse(EventResponse.Going)
            self.goingButtonView.label.alpha = 0
            self.label.alpha = 0
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            self.maybeButtonViewLeadingConstraint.constant = self.finalPositionForResponse(EventResponse.Maybe)
            UIView.animateWithDuration(0.5, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            self.sorryButtonViewLeadingConstraint.constant = self.finalPositionForResponse(EventResponse.Sorry)
            UIView.animateWithDuration(0.5, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.goingButtonView.button.alpha = 1
                self.maybeButtonView.button.alpha = 1
                self.sorryButtonView.button.alpha = 1
                self.safe = true
                }, completion: nil)
        case EventResponse.Maybe:
            self.maybeButtonView.label.attributedText = self.dateLabel.attributedText
            self.maybeButtonViewLeadingConstraint.constant = leadingConstraintConstant
            self.goingButtonViewLeadingConstraint.constant = -(self.buttonWidth);
            self.sorryButtonViewLeadingConstraint.constant = self.frame.size.width + self.buttonWidth;
            self.layoutIfNeeded()
            
            self.goingButtonView.alpha = 1
            self.maybeButtonView.alpha = 1
            self.sorryButtonView.alpha = 1
            
            self.maybeButtonViewLeadingConstraint.constant = self.finalPositionForResponse(EventResponse.Maybe)
            self.maybeButtonView.label.alpha = 0
            self.label.alpha = 0
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            self.goingButtonViewLeadingConstraint.constant = self.finalPositionForResponse(EventResponse.Going)
            UIView.animateWithDuration(0.5, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            self.sorryButtonViewLeadingConstraint.constant = self.finalPositionForResponse(EventResponse.Sorry)
            UIView.animateWithDuration(0.5, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.goingButtonView.button.alpha = 1
                self.maybeButtonView.button.alpha = 1
                self.sorryButtonView.button.alpha = 1
                self.safe = true
                }, completion: nil)
        case EventResponse.Sorry:
            self.sorryButtonView.label.attributedText = self.dateLabel.attributedText
            self.sorryButtonViewLeadingConstraint.constant = leadingConstraintConstant
            self.goingButtonViewLeadingConstraint.constant = -(self.buttonWidth);
            self.maybeButtonViewLeadingConstraint.constant = -(self.buttonWidth);
            self.layoutIfNeeded()
            
            self.goingButtonView.alpha = 1
            self.maybeButtonView.alpha = 1
            self.sorryButtonView.alpha = 1
            
            self.sorryButtonViewLeadingConstraint.constant = self.finalPositionForResponse(EventResponse.Sorry)
            self.sorryButtonView.label.alpha = 0
            self.label.alpha = 0
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            self.maybeButtonViewLeadingConstraint.constant = self.finalPositionForResponse(EventResponse.Maybe)
            UIView.animateWithDuration(0.5, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            self.goingButtonViewLeadingConstraint.constant = self.finalPositionForResponse(EventResponse.Going)
            UIView.animateWithDuration(0.5, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.goingButtonView.button.alpha = 1
                self.maybeButtonView.button.alpha = 1
                self.sorryButtonView.button.alpha = 1
                self.safe = true
                }, completion: nil)
        default:
            self.goingButtonViewLeadingConstraint.constant = -(self.buttonWidth);
            self.maybeButtonViewLeadingConstraint.constant = -(self.buttonWidth);
            self.sorryButtonViewLeadingConstraint.constant = -(self.buttonWidth);
            self.layoutIfNeeded()
            
            self.goingButtonView.alpha = 1
            self.maybeButtonView.alpha = 1
            self.sorryButtonView.alpha = 1
            self.label.alpha = 0
            
            self.sorryButtonViewLeadingConstraint.constant = self.finalPositionForResponse(EventResponse.Sorry)
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            self.maybeButtonViewLeadingConstraint.constant = self.finalPositionForResponse(EventResponse.Maybe)
            UIView.animateWithDuration(0.5, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            self.goingButtonViewLeadingConstraint.constant = self.finalPositionForResponse(EventResponse.Going)
            UIView.animateWithDuration(0.5, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.goingButtonView.button.alpha = 1
                self.maybeButtonView.button.alpha = 1
                self.sorryButtonView.button.alpha = 1
                self.safe = true
                }, completion: nil)
        }
    }
    
    func hideResponseButtons(response: EventResponse)
    {
        if !safe {
            return
        }
        self.safe = false
        
        switch response {
        case EventResponse.Going:
            self.goingButtonViewLeadingConstraint.constant = leadingConstraintConstant
            self.goingButtonView.label.attributedText = self.attributedDate
            UIView.animateWithDuration(0.1) { () -> Void in
                self.goingButtonView.button.alpha = 0
                self.maybeButtonView.alpha = 0
                self.sorryButtonView.alpha = 0
            }
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            UIView.animateWithDuration(0.4, delay: 0.1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.label.alpha = 1
                self.goingButtonView.label.alpha = 1
                }, completion: { (finished: Bool) -> Void in
                    self.goingButtonView.alpha = 0
                    self.dateLabel.layer.borderColor = UIColor.inviteGreenColor().CGColor
                    self.dateLabel.hidden = false
                    self.dateInsideCircle.hidden = false
                    self.safe = true
                    self.delegate?.titleDateCellFinishedHideAnimation(self)
            })
        case EventResponse.Maybe:
            self.maybeButtonViewLeadingConstraint.constant = leadingConstraintConstant
            self.maybeButtonView.label.attributedText = self.attributedDate
            UIView.animateWithDuration(0.1) { () -> Void in
                self.maybeButtonView.button.alpha = 0
                self.goingButtonView.alpha = 0
                self.sorryButtonView.alpha = 0
            }
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            UIView.animateWithDuration(0.4, delay: 0.1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.label.alpha = 1
                self.maybeButtonView.label.alpha = 1
                }, completion: { (finished: Bool) -> Void in
                    self.maybeButtonView.alpha = 0
                    self.dateLabel.layer.borderColor = UIColor.inviteYellowColor().CGColor
                    self.dateLabel.hidden = false
                    self.dateInsideCircle.hidden = false
                    self.safe = true
                    self.delegate?.titleDateCellFinishedHideAnimation(self)
            })
        default:
            self.sorryButtonViewLeadingConstraint.constant = leadingConstraintConstant
            self.sorryButtonView.label.attributedText = self.attributedDate
            UIView.animateWithDuration(0.1) { () -> Void in
                self.sorryButtonView.button.alpha = 0
                self.goingButtonView.alpha = 0
                self.maybeButtonView.alpha = 0
            }
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
            UIView.animateWithDuration(0.4, delay: 0.1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.label.alpha = 1
                self.sorryButtonView.label.alpha = 1
                }, completion: { (finished: Bool) -> Void in
                    self.sorryButtonView.alpha = 0
                    self.dateLabel.layer.borderColor = UIColor.inviteRedColor().CGColor
                    self.dateLabel.hidden = false
                    self.dateInsideCircle.hidden = false
                    self.safe = true
                    self.delegate?.titleDateCellFinishedHideAnimation(self)
            })
        }
    }
    
    @IBAction func going()
    {
        self.delegate?.titleDateCell(self, selectedResponse: EventResponse.Going)
    }
    
    @IBAction func maybe()
    {
        self.delegate?.titleDateCell(self, selectedResponse: EventResponse.Maybe)
    }
    
    @IBAction func sorry()
    {
        self.delegate?.titleDateCell(self, selectedResponse: EventResponse.Sorry)
    }
}

@objc protocol TitleDateCellDelegate
{
    func titleDateCell(cell: TitleDateCell, selectedResponse response: EventResponse)
    func titleDateCellFinishedHideAnimation(cell: TitleDateCell)
}
