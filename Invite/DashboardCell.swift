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

@objc(DashboardCell) class DashboardCell: UICollectionViewCell, MKMapViewDelegate
{
    let titleFont = UIFont.proximaNovaLightFontOfSize(28)
    let timeframeFont = UIFont.proximaNovaSemiboldFontOfSize(14)
    let descriptionFont = UIFont.proximaNovaRegularFontOfSize(14)
    let newlineFont = UIFont.proximaNovaRegularFontOfSize(12)
    
    let kDashboardPadding: CGFloat = 35
    
    var event: PFObject! {
        didSet {
            configureEvent()
        }
    }
    
    var cardView = UIView()
    var mapView = MKMapView()
    var mapGradient = OBGradientView()
    var dateLabel = UILabel()
    var detailsLabel = UILabel()
    var detailsGradient = OBGradientView()
    
    var annotation: MKPlacemark?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        mapView.delegate = self
        prepareConstraints()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        mapView.delegate = self
        prepareConstraints()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("PinIdentifier") as? MKPinAnnotationView
        if (pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PinIdentifier")
            pinView?.animatesDrop = true
        }
        return pinView
    }
    
    func configureEvent()
    {
        // Setup label
        let eventDetails = NSMutableAttributedString()
        
        var eventTitle = ""
        if let title = event.objectForKey(EVENT_TITLE_KEY) as? String {
            eventTitle = title.characters.count > 0 ? title : "No title"
        } else {
            eventTitle = "No title"
        }
        
        eventDetails.appendAttributedString(NSAttributedString(string: eventTitle, attributes: [NSFontAttributeName: titleFont, NSForegroundColorAttributeName: UIColor.inviteBlueColor()]))
        eventDetails.appendAttributedString(NSAttributedString(string: "\n\n", attributes: [NSFontAttributeName: newlineFont]))
        eventDetails.appendAttributedString(NSAttributedString(string: AppDelegate.presentationTimeframeForStartDate(event.objectForKey(EVENT_START_DATE_KEY) as! NSDate, endDate: event.objectForKey(EVENT_END_DATE_KEY) as! NSDate) as String, attributes: [NSFontAttributeName: timeframeFont, NSForegroundColorAttributeName: UIColor.inviteSlateButtonColor()]))
        eventDetails.appendAttributedString(NSAttributedString(string: "\n\n", attributes: [NSFontAttributeName: newlineFont]))
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        
        detailsLabel.attributedText = eventDetails
        
        let startDate = event.objectForKey(EVENT_START_DATE_KEY) as! NSDate
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM"
        let month = (formatter.stringFromDate(startDate) as NSString).uppercaseString
        formatter.dateFormat = "dd"
        let day = formatter.stringFromDate(startDate)
        
        let att = NSMutableAttributedString()
        att.appendAttributedString(NSAttributedString(string: month, attributes: [NSFontAttributeName: UIFont.proximaNovaSemiboldFontOfSize(9), NSForegroundColorAttributeName: UIColor.whiteColor()]))
        att.appendAttributedString(NSAttributedString(string: "\n", attributes: [NSFontAttributeName: UIFont.proximaNovaLightFontOfSize(0)]))
        att.appendAttributedString(NSAttributedString(string: day, attributes: [NSFontAttributeName: UIFont.proximaNovaLightFontOfSize(22), NSForegroundColorAttributeName: UIColor.whiteColor()]))
        dateLabel.attributedText = att
        dateLabel.textAlignment = .Center
        dateLabel.numberOfLines = 0
        
        // Map View
        
        if ((event.objectForKey(EVENT_LOCATION_KEY)) != nil) {
            if ((annotation) != nil) {
                mapView.removeAnnotation(annotation!)
                annotation = nil
            }
            let location = event.objectForKey(EVENT_LOCATION_KEY) as! PFObject
            let longitude = location.objectForKey(LOCATION_LONGITUDE_KEY) as? Double
            let latitude = location.objectForKey(LOCATION_LATITUDE_KEY) as? Double
            let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            annotation = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            mapView.addAnnotation(annotation!)
            mapView.showAnnotations([annotation!], animated: false)
        } else {
            mapView.removeAnnotation(annotation!)
        }
    }
    
    func prepareConstraints()
    {
        let views = ["cardView": cardView, "mapView": mapView, "detailsLabel": detailsLabel]
        
        // Card view
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = CGFloat(kCornerRadius)
        cardView.clipsToBounds = true
        cardView.backgroundColor = UIColor.whiteColor()
        addSubview(cardView)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-padding-[cardView]-padding-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["padding": kDashboardPadding], views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-padding-[cardView]-padding-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["padding": kDashboardPadding], views: views))
        
        // Map view
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.userInteractionEnabled = false
        cardView.addSubview(mapView)
        cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[mapView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["mapView": mapView]))
        cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mapView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["mapView": mapView]))
        cardView.addConstraint(NSLayoutConstraint(item: mapView, attribute: .Height, relatedBy: .Equal, toItem: cardView, attribute: .Height, multiplier: 0.5, constant: 0))
        
        // Map gradient
        mapGradient.translatesAutoresizingMaskIntoConstraints = false
        mapGradient.colors = [UIColor.clearColor(), UIColor(white: 0, alpha: 0.1)]
        cardView.addSubview(mapGradient)
        cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[mapGradient]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["mapGradient": mapGradient]))
        cardView.addConstraint(NSLayoutConstraint(item: mapGradient, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30))
        cardView.addConstraint(NSLayoutConstraint(item: mapGradient, attribute: .Bottom, relatedBy: .Equal, toItem: mapView, attribute: .Bottom, multiplier: 1, constant: 0))
        
        // Details label
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.numberOfLines = 0
        cardView.addSubview(detailsLabel)
        cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[detailsLabel]-30-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[mapView]-15-[detailsLabel]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        // Details gradient
        detailsGradient.translatesAutoresizingMaskIntoConstraints = false
        detailsGradient.colors = [UIColor(white: 1, alpha: 0),  UIColor.whiteColor(), UIColor.whiteColor()]
        detailsGradient.locations = [0, 0.75, 1]
        cardView.addSubview(detailsGradient)
        cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[detailsGradient]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["detailsGradient": detailsGradient]))
        cardView.addConstraint(NSLayoutConstraint(item: detailsGradient, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 50))
        cardView.addConstraint(NSLayoutConstraint(item: detailsGradient, attribute: .Bottom, relatedBy: .Equal, toItem: cardView, attribute: .Bottom, multiplier: 1, constant: 0))

        // Date label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.backgroundColor = UIColor.inviteBlueColor()
        dateLabel.layer.cornerRadius = 40
        dateLabel.clipsToBounds = true
        self.addSubview(dateLabel)
        self.addConstraint(NSLayoutConstraint(item: dateLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 80))
        self.addConstraint(NSLayoutConstraint(item: dateLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 80))
        self.addConstraint(NSLayoutConstraint(item: dateLabel, attribute: .Bottom, relatedBy: .Equal, toItem: mapView, attribute: .Bottom, multiplier: 1, constant: -15))
        self.addConstraint(NSLayoutConstraint(item: dateLabel, attribute: .Trailing, relatedBy: .Equal, toItem: mapView, attribute: .Trailing, multiplier: 1, constant: -15))
        
}
    
    override func layoutSubviews()
    {
        detailsLabel.preferredMaxLayoutWidth = bounds.size.width - 66
    }
}

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
//        }
