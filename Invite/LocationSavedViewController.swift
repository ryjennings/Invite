//
//  LocationSavedViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 3/28/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit
import MapKit

enum LocationSavedSection: Int {
    case NewLocation = 0
    case SavedLocations
    case Count
}

@objc public class LocationSavedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    // MARK: - UITableView
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return LocationSavedSection.Count.rawValue
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section {
        case LocationSavedSection.NewLocation.rawValue:
            return 1
        default:
            return AppDelegate.locations().count
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (indexPath.section == LocationSavedSection.NewLocation.rawValue) {
            var cell = tableView.dequeueReusableCellWithIdentifier(LOCATION_NEW_CELL_IDENTIFIER, forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = "Create new location"
            return cell
        } else {
            let location = AppDelegate.locations()[indexPath.row] as PFObject
            let address = location.objectForKey(LOCATION_ADDRESS_KEY) as? String
            let nickname = location.objectForKey(LOCATION_NICKNAME_KEY) as? String
            var cell = tableView.dequeueReusableCellWithIdentifier(LOCATION_SAVED_CELL_IDENTIFIER, forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = nickname ?? address
            return cell
        }
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.section == LocationSavedSection.NewLocation.rawValue) {
            performSegueWithIdentifier(SEGUE_TO_NEW_LOCATION, sender: self)
        } else {
            let location = AppDelegate.locations()[indexPath.row] as PFObject
            let longitude = location.objectForKey(LOCATION_LONGITUDE_KEY) as? Double
            let latitude = location.objectForKey(LOCATION_LATITUDE_KEY) as? Double
            let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            let annotation = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            mapView.addAnnotation(annotation)
            mapView.showAnnotations([annotation], animated: true)
        }
    }
}
