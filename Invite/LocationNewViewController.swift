//
//  LocationNewViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 3/28/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit
import MapKit

@objc public class LocationNewViewController: UIViewController, UISearchBarDelegate, GooglePlacesAutocompleteDelegate
{
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nicknameTextFieldHeightConstraint: NSLayoutConstraint!
    
    var searchController: UISearchController!
    var location = PFObject(className: CLASS_LOCATION_KEY)
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let gpaViewController = GooglePlacesAutocomplete(apiKey: "AIzaSyCscZK8r9gOJ9z0TMl7WbN6HH8JoeKyV5g", placeType: .Address)
//        var searchResultsController = storyboard?.instantiateViewControllerWithIdentifier("LocationResultsViewController") as LocationResultsViewController
        searchController = UISearchController(searchResultsController: gpaViewController)
        searchController.dimsBackgroundDuringPresentation = true
        // The search bar won't show up unless scopeButtonTitles is set.
        // The scope buttons won't show up unless two titles are set. 
        // So since we don't want any scope buttons, only set one title.
        searchController.searchBar.scopeButtonTitles = ["Invite"]
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a location"
        searchBarView.addSubview(searchController.searchBar)
        
        locationLabel.text = "Use the search bar above to set a location."
        nicknameTextFieldHeightConstraint.constant = 0
    }
    
    public override func viewDidLayoutSubviews()
    {
        searchController.searchBar.frame.size.width = searchBarView.bounds.size.width
        locationLabel.preferredMaxLayoutWidth = view.frame.size.width - 32
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "SegueToEvent") {
            if (!nicknameTextField.text.isEmpty) {
                location.setObject(nicknameTextField.text, forKey: LOCATION_NICKNAME_KEY)
            }
            AppDelegate.addLocationToProtoEvent(location)
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    public func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchBar.text, {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                
                // Set the annotation
                let annotation = MKPlacemark(placemark: placemark)
                self.mapView.addAnnotation(annotation)
                self.mapView.showAnnotations([annotation], animated: true)
                
                // Set the coordinate and address for use later
                self.location.setObject(searchBar.text, forKey: LOCATION_ADDRESS_KEY)
                self.location.setObject(placemark.location.coordinate.longitude, forKey: LOCATION_LONGITUDE_KEY)
                self.location.setObject(placemark.location.coordinate.latitude, forKey: LOCATION_LATITUDE_KEY)
                
                // Update the UI
                self.locationLabel.text = searchBar.text
                self.nicknameTextFieldHeightConstraint.constant = 30
                
                UIView.animateWithDuration(0.333, animations: {
                    self.view.layoutIfNeeded()
                })

                // Dismiss the search controller
                self.searchController.active = false
            }
        })
    }
}
