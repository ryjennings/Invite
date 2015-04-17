//
//  LocationViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 3/28/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit
import MapKit

enum LocationSection: Int {
    case ActiveLocation = 0
    case SavedLocations
    case Count
}

@objc(LocationViewController) class LocationViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, LocationResultsViewControllerDelegate, InputCellDelegate, MapCellDelegate
{
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController!
    var searchResultsController: LocationResultsViewController!
    
    var activePlacemark: CLPlacemark!
    var activeLocation: PFObject!
    
    var showCurrentLocation = true
    var savedLocationsIndex = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchResultsController = LocationResultsViewController()
        searchResultsController.delegate = self

        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search for a location"
        searchController.searchResultsUpdater = self
        
        nextButton.layer.cornerRadius = CGFloat(kCornerRadius)
        nextButton.clipsToBounds = true
        nextButton.titleLabel!.font = UIFont.inviteButtonTitleFont()
        
        navigationItem.titleView = ProgressView(frame: CGRectMake(0, 0, 150, 15), step: 4, steps: 5)

        tableView.tableHeaderView = tableHeaderView()
        definesPresentationContext = true

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func tableHeaderView() -> UIView
    {
        var view = UIView(frame: CGRectMake(0, 0, 0, 144))
        view.backgroundColor = UIColor.clearColor()
        
        var searchBarView = UIView()
        searchBarView.setTranslatesAutoresizingMaskIntoConstraints(false)
        searchBarView.addSubview(searchController.searchBar)
        view.addSubview(searchBarView)
        
        var label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.inviteQuestionColor()
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.font = UIFont.inviteQuestionFont()
        label.text = "Where are you having\nthis event?"
        view.addSubview(label)
        
        let views = ["bar": searchBarView, "label": label]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bar]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[label]-15-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bar(44)]-34-[label]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        
        return view
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "SegueToEvent") {
            AppDelegate.addToProtoEventLocation(activeLocation)
        }
    }

    // MARK: - UITableView
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        var headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel.textColor = UIColor.inviteTableHeaderColor()
        headerView.textLabel.font = UIFont.inviteTableHeaderFont()
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    {
        var footerView = view as! UITableViewHeaderFooterView
        footerView.textLabel.font = UIFont.inviteTableFooterFont()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch (section) {
        case LocationSection.ActiveLocation.rawValue:
            return "Active Location"
        case LocationSection.SavedLocations.rawValue:
            return "Saved Locations"
        default:
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return LocationSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch (section) {
        case LocationSection.ActiveLocation.rawValue:
            return 1
        case LocationSection.SavedLocations.rawValue:
            return AppDelegate.locations().count + 1 // for current location
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (indexPath.section == LocationSection.ActiveLocation.rawValue) {
            
            var cell = tableView.dequeueReusableCellWithIdentifier(MAP_CELL_IDENTIFIER, forIndexPath: indexPath) as! MapCell
            cell.delegate = self
            cell.mapViewLeadingConstraint.constant = cell.separatorInset.left
            if (showCurrentLocation) {
                cell.showCurrentLocation()
            } else {
                cell.placemark = activePlacemark
                cell.parseLocation = activeLocation
            }
            addDoneToolBarToKeyboard(cell.textField)
            return cell
            
        } else {
            
            var cell = tableView.dequeueReusableCellWithIdentifier(BASIC_CELL_IDENTIFIER, forIndexPath: indexPath) as! UITableViewCell
//            cell.accessoryType = indexPath.row == savedLocationsIndex ? .Checkmark : .None
            cell.accessoryView = indexPath.row == savedLocationsIndex ? UIImageView(image: UIImage(named: "list_selected")) : UIImageView(image: UIImage(named: "list_select"))
            if (indexPath.row == 0) {
                cell.textLabel?.text = "Use current location"
            } else {
                let location = AppDelegate.locations()[indexPath.row - 1] as! PFObject
                let address = location.objectForKey(LOCATION_ADDRESS_KEY) as? String
                let nickname = location.objectForKey(LOCATION_NICKNAME_KEY) as? String
                cell.textLabel?.text = nickname ?? address
            }
            return cell
            
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if (indexPath.section == LocationSection.ActiveLocation.rawValue) {
            
            return 130
            
        } else {
            
            return 44
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if (indexPath.section == LocationSection.SavedLocations.rawValue) {
            
            savedLocationsIndex = indexPath.row
            
            if (indexPath.row == 0) {
                showCurrentLocation = true
                tableView.reloadData()
                return
            }
            
            let parseLocation = AppDelegate.locations()[indexPath.row - 1] as! PFObject
            let parseLongitude = parseLocation.objectForKey(LOCATION_LONGITUDE_KEY) as? Double
            let parseLatitude = parseLocation.objectForKey(LOCATION_LATITUDE_KEY) as? Double
            
            var geocoder = CLGeocoder()
            let location = CLLocation(latitude: parseLatitude!, longitude: parseLongitude!)
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks: [AnyObject]!, error: NSError!) -> Void in
                self.activePlacemark = placemarks[0] as! CLPlacemark
                self.showCurrentLocation = false
                self.activeLocation = parseLocation
                tableView.reloadData()
            })
        }
    }

    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchController.searchBar.text, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            
            if let locations = placemarks {
                self.searchResultsController.locations = locations
            }
        })
    }
    
    // MARK: - LocationResultsViewControllerDelegate
    
    func didSelectPlacemark(placemark: CLPlacemark)
    {
        activePlacemark = placemark
        
        tableView.reloadData()
        
        // Dismiss the search controller
        self.searchController.active = false
    }
    
    // MARK: - InputCellDelegate
    
    func textViewDidChange(textView: UITextView)
    {

    }
    
    // MARK: - MapCellDelegate
    
    func didSetCurrentLocationToLocation(location: PFObject)
    {
        activeLocation = location
    }

    // MARK: - Notifications
    
    func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: tableView.contentInset.top, left: 0, bottom: keyboardSize.height, right: 0)
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        UIView.animateWithDuration(0.35, animations: {
            let contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, 0.0, 0.0)
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
        })
    }

    // MARK: - UITextView Dismiss Toolbar
    
    func addDoneToolBarToKeyboard(textField: UITextField)
    {
        var doneToolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 50))
        doneToolbar.barStyle = .BlackTranslucent
        doneToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Dismiss Keyboard", style: .Done, target: self, action: "doneButtonClickedDismissKeyboard"),
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        ]
        doneToolbar.sizeToFit()
        textField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonClickedDismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    @IBAction func cancel(sender: UIBarButtonItem)
    {
        AppDelegate.nilProtoEvent()
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
