//
//  LocationSavedViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 3/28/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit
import MapKit

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
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return AppDelegate.locations().count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let location = AppDelegate.locations()[indexPath.row] as PFObject
        let address = location.objectForKey(LOCATION_ADDRESS_KEY) as? String
        let nickname = location.objectForKey(LOCATION_NICKNAME_KEY) as? String
        var cell = tableView.dequeueReusableCellWithIdentifier(LOCATION_SAVED_CELL_IDENTIFIER, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = nickname ?? address
        return cell
    }
}
