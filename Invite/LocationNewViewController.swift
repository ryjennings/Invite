//
//  LocationNewViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 3/28/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit
import MapKit

public class LocationNewViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate
{
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var searchController: UISearchController!
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        var searchResultsController = storyboard?.instantiateViewControllerWithIdentifier("LocationResultsTableViewController") as LocationResultsTableViewController
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self

        searchBarView.addSubview(searchController.searchBar)
        
        
        
        
        
        
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.scopeButtonTitles = ["Country", "Capital"]
        searchController.searchBar.delegate = self
        
    }
    
    public override func viewDidLayoutSubviews()
    {
        searchController.searchBar.frame.size.width = searchBarView.bounds.size.width
    }
    
    public func updateSearchResultsForSearchController(searchController: UISearchController) {

    }
}
