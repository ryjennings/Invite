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
    var event: PFObject! {
        didSet {
            configureEvent()
        }
    }
    
    var eventView = UIView()
    var mapView = MKMapView()
    var label = UILabel()
    var annotation: MKPlacemark?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        prepareConstraints()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        prepareConstraints()
    }
    
    func configureEvent()
    {
        // Setup label
        let labelString = NSMutableAttributedString()
        
        var t = ""
        if let title = event.objectForKey(EVENT_TITLE_KEY) as? String {
            t = count(title) > 0 ? title : "No title"
        } else {
            t = "No title"
        }
        labelString.appendAttributedString(NSAttributedString(string: t, attributes: [NSFontAttributeName: UIFont.proximaNovaSemiboldFontOfSize(30), NSForegroundColorAttributeName: UIColor.inviteBlueColor()]))
        labelString.appendAttributedString(NSAttributedString(string: "\n\n"))
        
        labelString.appendAttributedString(NSAttributedString(string: AppDelegate.presentationTimeframeFromStartDate(event.objectForKey(EVENT_START_DATE_KEY) as! NSDate, endDate: event.objectForKey(EVENT_END_DATE_KEY) as! NSDate) as String, attributes: [NSFontAttributeName: UIFont.proximaNovaSemiboldFontOfSize(14), NSForegroundColorAttributeName: UIColor.lightGrayColor()]))
        labelString.appendAttributedString(NSAttributedString(string: "\n\n"))
        
        var d = ""
        if let description = event.objectForKey(EVENT_DESCRIPTION_KEY) as? String {
            d = count(description) > 0 ? description : "No description"
        } else {
            d = "No description"
        }
        labelString.appendAttributedString(NSAttributedString(string: d, attributes: [NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(20), NSForegroundColorAttributeName: UIColor.inviteTableLabelColor()]))
        
        label.attributedText = labelString
//        if ((event.objectForKey(EVENT_COVER_IMAGE_KEY)) != nil) {
//            
//            // Setup image view
//            var coverImageView = PFImageView()
//            coverImageView.file = event.objectForKey(EVENT_COVER_IMAGE_KEY) as! PFFile
//            coverImageView.loadInBackground({ (image: UIImage!, error: NSError!) -> Void in
//                self.eventImageView.image = image
//            })
//            eventView.bringSubviewToFront(eventImageView)
//            
//        } else {
        
            // Setup map view
            // Map View
            
            if ((event.objectForKey(EVENT_LOCATION_KEY)) != nil) {
                if ((annotation) != nil) {
                    mapView.removeAnnotation(annotation)
                    annotation = nil
                }
                let location = event.objectForKey(EVENT_LOCATION_KEY) as! PFObject
                let longitude = location.objectForKey(LOCATION_LONGITUDE_KEY) as? Double
                let latitude = location.objectForKey(LOCATION_LATITUDE_KEY) as? Double
                let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                annotation = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                mapView.addAnnotation(annotation)
                mapView.showAnnotations([annotation!], animated: true)
            } else {
                mapView.removeAnnotation(annotation)
        }
            
//        }
    }
    
    func prepareConstraints()
    {
        let views = ["eventView": eventView, "label": label, "mapView": mapView]
        
        // Event View
        eventView.setTranslatesAutoresizingMaskIntoConstraints(false)
        eventView.layer.cornerRadius = CGFloat(kCornerRadius)
        eventView.clipsToBounds = true
        eventView.backgroundColor = UIColor.whiteColor()
        addSubview(eventView)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-padding-[eventView]-padding-|", options: NSLayoutFormatOptions(0), metrics: ["padding": kDashboardPadding], views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-padding-[eventView]-padding-|", options: NSLayoutFormatOptions(0), metrics: ["padding": kDashboardPadding], views: views))
        
        // Map View
        mapView.setTranslatesAutoresizingMaskIntoConstraints(false)
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.userInteractionEnabled = false
        eventView.addSubview(mapView)
        eventView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[mapView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["mapView": mapView]))
        eventView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mapView]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["mapView": mapView]))
        eventView.addConstraint(NSLayoutConstraint(item: mapView, attribute: .Height, relatedBy: .Equal, toItem: eventView, attribute: .Height, multiplier: 0.5, constant: 0))

        // Label
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.numberOfLines = 10
        eventView.addSubview(label)
        eventView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[label]-30-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        eventView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[mapView]-12-[label]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    }
    
    override func layoutSubviews()
    {
        label.preferredMaxLayoutWidth = bounds.size.width - 66
    }
}
