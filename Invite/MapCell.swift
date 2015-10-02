//
//  MapCell.swift
//  Invite
//
//  Created by Ryan Jennings on 4/8/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit
import MapKit

@objc(MapCell) class MapCell: UITableViewCell, UITextViewDelegate, MKMapViewDelegate
{
    var delegate: MapCellDelegate?
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var guidance: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var addressLabel: UILabel!
    
    private var currentPlacemark: MKPlacemark?
    
    var location: Location! {
        didSet {
            configureForLocation()
        }
    }
    
    override func awakeFromNib()
    {
        self.leadingConstraint.constant = SDiPhoneVersion.deviceSize() == DeviceSize.iPhone55inch ? 20 : 15

        self.textView.textContainerInset = UIEdgeInsetsMake(3, 0, 0, 0)
        self.textView.textContainer.lineFragmentPadding = 0
        self.textView.font = UIFont.proximaNovaRegularFontOfSize(20)
        
        self.guidance.font = UIFont.proximaNovaRegularFontOfSize(20)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None

        self.accessoryView = UIView(frame: CGRectMake(0, 0, 10, 10))
        self.accessoryView?.backgroundColor = UIColor.inviteBackgroundSlateColor()
        self.accessoryView?.clipsToBounds = true
        self.accessoryView?.layer.cornerRadius = 5
    }
    
    private func configureForLocation()
    {
        self.guidance.backgroundColor = UIColor.clearColor()
        if let name = self.location.name {
            self.guidance.text = name
            self.guidance.hidden = false
            self.textView.hidden = true
        } else if let _ = self.location.pfObject {
            self.guidance.hidden = true
            self.textView.hidden = true
        } else {
            self.guidance.text = "Add a nickname"
            self.guidance.hidden = false
            self.textView.hidden = false
        }
        
        if let address = self.location.formattedAddress {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 1
            let att = NSMutableAttributedString(string: address, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(14), NSParagraphStyleAttributeName: style])
            self.addressLabel.attributedText = att
        }
    }

    func textViewDidChange(textView: UITextView)
    {
        guidance.hidden = Bool(textView.text.characters.count)
        self.delegate?.textViewDidChange(textView, cell: self)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        self.delegate?.textViewShouldBeginEditing(textView, cell: self)
        return true
    }
}

protocol MapCellDelegate
{
    func textViewDidChange(textView: UITextView, cell: MapCell)
    func textViewShouldBeginEditing(textView: UITextView, cell: MapCell)
}

