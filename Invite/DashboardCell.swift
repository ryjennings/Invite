//
//  DashboardCell.swift
//  Invite
//
//  Created by Ryan Jennings on 3/31/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit
import MapKit
import ParseUI

@objc(DashboardCell) class DashboardCell: UICollectionViewCell
{
    let eventTitleFont = UIFont.systemFontOfSize(20)
    let eventTimeframeFont = UIFont.boldSystemFontOfSize(10)
    let eventDescriptionFont = UIFont.systemFontOfSize(16)
    let eventNewlineFont = UIFont.systemFontOfSize(8)
    
    var event: PFObject! {
        didSet {
            prepareCell()
        }
    }
    
    var eventView = UIView()
    var eventImageView = UIImageView()
    var mapView: MKMapView!
    var label = UILabel()
    
    var showMapView = false
    var prepared = false
    
    func prepareCell()
    {
        if (!prepared) {
            prepareConstraints()
        }
        
        self.eventImageView.image = nil
        if ((event.objectForKey(EVENT_COVER_IMAGE_KEY)) != nil) {
            
            // Setup image view
            var coverImageView = PFImageView()
            coverImageView.file = event.objectForKey(EVENT_COVER_IMAGE_KEY) as! PFFile
            coverImageView.loadInBackground({ (image: UIImage!, error: NSError!) -> Void in
                self.eventImageView.image = image
            })
            eventView.bringSubviewToFront(eventImageView)
            
        } else {
            
            // Setup map view
            if ((event.objectForKey(EVENT_LOCATION_KEY)) != nil) {
                // Map View
                mapView = MKMapView()
                mapView.setTranslatesAutoresizingMaskIntoConstraints(false)
                mapView.zoomEnabled = false
                mapView.scrollEnabled = false
                mapView.userInteractionEnabled = false
                eventView.addSubview(mapView)
                eventView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[mapView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["mapView": mapView]))
                eventView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mapView]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["mapView": mapView]))
                eventView.addConstraint(NSLayoutConstraint(item: mapView, attribute: .Height, relatedBy: .Equal, toItem: eventView, attribute: .Height, multiplier: 0.5, constant: 0))
                
                let location = event.objectForKey(EVENT_LOCATION_KEY) as! PFObject
                let longitude = location.objectForKey(LOCATION_LONGITUDE_KEY) as? Double
                let latitude = location.objectForKey(LOCATION_LATITUDE_KEY) as? Double
                let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                let annotation = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                mapView.addAnnotation(annotation)
                mapView.showAnnotations([annotation], animated: true)
            } else {
                eventImageView.backgroundColor = UIColor.darkGrayColor()
                eventView.bringSubviewToFront(eventImageView)
            }
            
        }
        
        // Setup label
        let labelString = NSMutableAttributedString()
        
        var t = ""
        if let title = event.objectForKey(EVENT_TITLE_KEY) as? String {
            t = count(title) > 0 ? title : "No title"
        } else {
            t = "No title"
        }
        labelString.appendAttributedString(NSAttributedString(string: t, attributes: [NSFontAttributeName: eventTitleFont, NSForegroundColorAttributeName: UIColor.lightGrayColor()]))
        labelString.appendAttributedString(NSAttributedString(string: "\n", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(10)]))
        
        labelString.appendAttributedString(NSAttributedString(string: AppDelegate.presentationTimeframeFromStartDate(event.objectForKey(EVENT_START_DATE_KEY) as! NSDate, endDate: event.objectForKey(EVENT_END_DATE_KEY) as! NSDate) as String, attributes: [NSFontAttributeName: eventTimeframeFont, NSForegroundColorAttributeName: UIColor.darkGrayColor()]))
        labelString.appendAttributedString(NSAttributedString(string: "\n\n", attributes: [NSFontAttributeName: eventNewlineFont]))
        
        var d = ""
        if let description = event.objectForKey(EVENT_DESCRIPTION_KEY) as? String {
            d = count(description) > 0 ? description : "No description"
        } else {
            d = "No description"
        }
        labelString.appendAttributedString(NSAttributedString(string: d, attributes: [NSFontAttributeName: eventDescriptionFont, NSForegroundColorAttributeName: UIColor.lightGrayColor()]))
        
        label.attributedText = labelString
        
    }
    
    func prepareConstraints()
    {
        let views = ["eventView": eventView, "eventImageView": eventImageView, "label": label]
        
        // Event View
        eventView.setTranslatesAutoresizingMaskIntoConstraints(false)
        eventView.layer.cornerRadius = CGFloat(kCornerRadius)
        eventView.clipsToBounds = true
        eventView.backgroundColor = UIColor.whiteColor()
        addSubview(eventView)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-padding-[eventView]-padding-|", options: NSLayoutFormatOptions(0), metrics: ["padding": kDashboardPadding], views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-padding-[eventView]-padding-|", options: NSLayoutFormatOptions(0), metrics: ["padding": kDashboardPadding], views: views))
        
        // Event Image View
        eventImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        eventView.addSubview(eventImageView)
        eventView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[eventImageView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        eventView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[eventImageView]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        eventView.addConstraint(NSLayoutConstraint(item: eventImageView, attribute: .Height, relatedBy: .Equal, toItem: eventView, attribute: .Height, multiplier: 0.5, constant: 0))
        
        // Label
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.numberOfLines = 0
        eventView.addSubview(label)
        eventView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[label]-8-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        eventView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[eventImageView]-12-[label]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        
        prepared = true
    }
    
    override func layoutSubviews()
    {
        label.preferredMaxLayoutWidth = bounds.size.width - 66
    }
}
