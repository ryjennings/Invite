//
//  MapCell.swift
//  Invite
//
//  Created by Ryan Jennings on 4/8/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit
import MapKit

@objc(MapCell) class MapCell: UITableViewCell, CLLocationManagerDelegate, UITextFieldDelegate
{
    var delegate: MapCellDelegate?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var locationManager: CLLocationManager!
    
    var location = PFObject(className: CLASS_LOCATION_KEY)

    var placemark: CLPlacemark!
    {
        didSet {
            locationManager.stopUpdatingLocation()
            showPlacemark(MKPlacemark(placemark: placemark))
        }
    }
    
    var parseLocation: PFObject!
    {
        didSet {
            if let nickname = parseLocation.objectForKey(LOCATION_NICKNAME_KEY) as? String {
                textField.text = nickname
            }
        }
    }
    
    func configureCell()
    {
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.userInteractionEnabled = false
        mapView.layer.cornerRadius = 50
        
        label.textColor = UIColor.inviteTableLabelColor()
        label.font = UIFont.inviteTableSmallFont()
        label.text = "Retrieving location..."
        
        textField.placeholder = "Give this location a nickname"
        textField.font = UIFont.inviteTableSmallFont()
        textField.textColor = UIColor.inviteTableLabelColor()
        textField.delegate = self
    }
    
    func showPlacemark(placemark: MKPlacemark)
    {
        mapView.addAnnotation(placemark)
        mapView.showAnnotations([placemark], animated: true)
        label.text = placemark.addressDictionary["FormattedAddressLines"]!.componentsJoinedByString(", ")
    }
    
    override func awakeFromNib()
    {
        configureCell()
    }
    
    func showCurrentLocation()
    {
        setupLocationManager()
        locationManager.startUpdatingLocation()
        mapView.setUserTrackingMode(.Follow, animated: true)
    }
    
    func setupLocationManager()
    {
        if (locationManager == nil) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    }

    // MARK: CLLocationManager
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!)
    {
        var geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks: [AnyObject]!, error: NSError!) -> Void in
            let address = (placemarks[0] as! CLPlacemark).addressDictionary["FormattedAddressLines"]!.componentsJoinedByString(", ")
            self.label.text = address
            if let d = self.delegate {
                self.location.setObject(newLocation.coordinate.latitude, forKey: LOCATION_LATITUDE_KEY)
                self.location.setObject(newLocation.coordinate.longitude, forKey: LOCATION_LONGITUDE_KEY)
                self.location.setObject(address, forKey: LOCATION_ADDRESS_KEY)
                d.didSetCurrentLocationToLocation(self.location)
            }
        })
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        self.location.setObject(textField.text, forKey: LOCATION_NICKNAME_KEY)
    }
}

protocol MapCellDelegate
{
    func didSetCurrentLocationToLocation(location: PFObject)
}

