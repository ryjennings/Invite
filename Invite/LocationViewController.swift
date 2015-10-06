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
    case SelectedLocation = 0
    case SavedLocations
    case Count
}

@objc class Location: NSObject
{
    let foursquareId: String?
    var name: String?
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    let formattedAddress: String?
    let pfObject: PFObject?
    
    init(foursquareId: String?, name: String?, latitude: CLLocationDegrees, longitude: CLLocationDegrees, formattedAddress: String?, pfObject: PFObject?)
    {
        self.foursquareId = foursquareId
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.formattedAddress = formattedAddress
        self.pfObject = pfObject
    }
}

@objc(LocationViewController) class LocationViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, LocationResultsViewControllerDelegate, MapCellDelegate, CLLocationManagerDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController!
    var searchResultsController: LocationResultsViewController!
    
    // DO NOT DELETE: CLLocationManager gets lat/long for Foursquare API
    var locationManager: CLLocationManager!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    var displayLocation = false
    var displayedLocation: Location? {
        didSet {
            self.displayLocation = self.displayedLocation != nil
        }
    }
    var selectedLocation: Location?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = "Event Location"
        
        self.searchResultsController = self.storyboard?.instantiateViewControllerWithIdentifier(LOCATION_RESULTS_VIEW_CONTROLLER) as? LocationResultsViewController
        self.searchResultsController.delegate = self
        
        self.searchController = UISearchController(searchResultsController: searchResultsController)
        self.searchController.delegate = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.placeholder = "Search Foursquare for a location"
        self.searchController.searchResultsUpdater = self
        
        self.tableView.tableHeaderView = tableHeaderView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44

        self.definesPresentationContext = true
        
        let location = AppDelegate.user().protoEvent.protoLocation;
        if location != nil {
            if location.pfObject == nil {
                self.displayedLocation = location
            }
            self.selectedLocation = location
        }
        
        setupLocationManager()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func setupLocationManager()
    {
        if (self.locationManager == nil) {
            self.locationManager = CLLocationManager()
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            self.locationManager.delegate = self
        }
    }

    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation)
    {
        self.latitude = newLocation.coordinate.latitude
        self.longitude = newLocation.coordinate.longitude
        self.locationManager.delegate = nil
    }

    func tableHeaderView() -> UIView
    {
        let view = UIView(frame: CGRectMake(0, 0, 0, 144))
        view.backgroundColor = UIColor.clearColor()
        
        let searchBarView = UIView()
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        searchBarView.addSubview(searchController.searchBar)
        view.addSubview(searchBarView)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.inviteQuestionColor()
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.font = UIFont.inviteQuestionFont()
        label.text = "Where are you having this event?"
        view.addSubview(label)
        
        let views = ["bar": searchBarView, "label": label]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bar]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-50-[label]-50-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bar(44)]-34-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        return view
    }
    
    // MARK: - UITableView
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor.inviteTableHeaderColor()
        headerView.textLabel!.font = UIFont.inviteTableHeaderFont()
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    {
        let footerView = view as! UITableViewHeaderFooterView
        footerView.textLabel!.font = UIFont.inviteTableFooterFont()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if !self.displayLocation {
            if AppDelegate.user().locations.count > 0 {
                return "Saved Locations"
            } else {
                return nil
            }
        }
        switch (section) {
        case LocationSection.SelectedLocation.rawValue:
            return "New Location"
        case LocationSection.SavedLocations.rawValue:
            return "Saved Locations"
        default:
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.displayLocation ? LocationSection.Count.rawValue : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.displayLocation {
            switch (section) {
            case LocationSection.SelectedLocation.rawValue:
                return 1
            case LocationSection.SavedLocations.rawValue:
                if (AppDelegate.user().locations == nil) {
                    return 1
                } else {
                    return AppDelegate.user().locations.count
                }
            default:
                return 0
            }
        } else {
            return AppDelegate.user().locations.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (self.displayLocation && indexPath.section == LocationSection.SelectedLocation.rawValue) {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(MAP_CELL_IDENTIFIER, forIndexPath: indexPath) as! MapCell
            let location = self.displayedLocation
            let selected = self.displayedLocation?.foursquareId == self.selectedLocation?.foursquareId
            cell.delegate = self
            cell.location = location
            addAccessoryViewToKeyboardForTextView(cell.textView)
            
            if let name = location?.name {
                cell.guidance.text = name
                cell.textView.hidden = true
            } else {
                cell.guidance.text = "Add a nickname"
                cell.textView.hidden = false
            }
            
            if selected {
                selectMapCell(cell)
            } else {
                unselectMapCell(cell)
            }
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(PROFILE_CELL_IDENTIFIER, forIndexPath: indexPath) as! ProfileCell
            let location = savedLocationForRow(indexPath.row)
            cell.location = location
            
            if let selectedLocation = self.selectedLocation {
                if selectedLocation.pfObject == location.pfObject {
                    selectProfileCell(cell)
                } else {
                    unselectProfileCell(cell)
                }
            } else {
                unselectProfileCell(cell)
            }
            
            return cell

        }
    }
    
    func savedLocationForRow(row: Int) -> Location
    {
        let savedLocation = AppDelegate.user().locations[row] as! PFObject
        return Location(foursquareId: nil,
            name: savedLocation[LOCATION_NAME_KEY] as? String,
            latitude: (savedLocation[LOCATION_LATITUDE_KEY] as! NSNumber).doubleValue,
            longitude: (savedLocation[LOCATION_LONGITUDE_KEY] as! NSNumber).doubleValue,
            formattedAddress: savedLocation[LOCATION_ADDRESS_KEY] as? String,
            pfObject: savedLocation)
    }
    
    func selectProfileCell(cell: ProfileCell)
    {
        unselectAllVisibleCells()
        self.view.endEditing(true)
        cell.backgroundColor = UIColor.inviteLightSlateColor()
        cell.accessoryView?.backgroundColor = UIColor.whiteColor()
        cell.nameLabel.textColor = UIColor.whiteColor()
        cell.flexLabel.textColor = UIColor.whiteColor()
        cell.profileImageView.layer.borderWidth = 1
    }
    
    func unselectProfileCell(cell: ProfileCell)
    {
        cell.backgroundColor = UIColor.whiteColor()
        cell.accessoryView?.backgroundColor = UIColor.inviteBackgroundSlateColor()
        cell.nameLabel.textColor = UIColor.inviteTableLabelColor()
        cell.flexLabel.textColor = UIColor.inviteGrayColor()
        cell.profileImageView.layer.borderWidth = 0
    }
    
    private func selectMapCell(cell: MapCell)
    {
        unselectAllVisibleCells()
        cell.accessoryView?.backgroundColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.inviteLightSlateColor()
        cell.guidance.textColor = UIColor.whiteColor()
        cell.textView.textColor = UIColor.whiteColor()
        cell.addressLabel.textColor = UIColor.whiteColor()
        cell.guidance.backgroundColor = self.displayedLocation?.name == nil ? UIColor.whiteColor().colorWithAlphaComponent(0.1) : UIColor.clearColor()
    }
    
    private func unselectMapCell(cell: MapCell)
    {
        cell.backgroundColor = UIColor.whiteColor()
        cell.accessoryView?.backgroundColor = UIColor.inviteBackgroundSlateColor()
        cell.guidance.textColor = self.displayedLocation?.name == nil ? UIColor.inviteBlueColor() : UIColor.inviteTableHeaderColor()
        cell.textView.textColor = UIColor.inviteTableHeaderColor()
        cell.addressLabel.textColor = UIColor.inviteGrayColor()
        cell.guidance.backgroundColor = self.displayedLocation?.name == nil ? UIColor.blackColor().colorWithAlphaComponent(0.025) : UIColor.clearColor()
    }
    
    func unselectAllVisibleCells()
    {
        for visibleCell in tableView.visibleCells {
            if visibleCell is ProfileCell {
                unselectProfileCell(visibleCell as! ProfileCell)
            } else {
                unselectMapCell(visibleCell as! MapCell)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if self.displayLocation && indexPath.section == LocationSection.SelectedLocation.rawValue
        {
            selectMapCell(cell as! MapCell)
            self.selectedLocation = self.displayedLocation
        }
        else if (!self.displayLocation || (self.displayLocation && indexPath.section == LocationSection.SavedLocations.rawValue))
        {
            selectProfileCell(cell as! ProfileCell)
            self.selectedLocation = savedLocationForRow(indexPath.row)
        }
    }

    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        if self.searchController.searchBar.text! == "" {
            return
        }
        self.tableView.scrollsToTop = false
        let session = NSURLSession.sharedSession()
        
        let client_id = "W5AXZDIUZ3TFJTALSSNSBZDL2WKY02K0BI2T1KODP2C4JHAT"
        let client_secret = "AFQJWN44SGDW4QTXDAURBKUQT1DQWVSRNY1I4H5K5Y5Z3O3D"
        let v = "20151001"
        let m = "foursquare"
        let intent = "browse"
        let radius = "100000"
        let query = self.searchController.searchBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        session.dataTaskWithURL(NSURL(string: "https://api.foursquare.com/v2/venues/search?client_id=\(client_id)&client_secret=\(client_secret)&v=\(v)&m=\(m)&ll=\(self.latitude),\(self.longitude)&intent=\(intent)&radius=\(radius)&query=\(query)")!) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in

            let urlResponse = response as? NSHTTPURLResponse
            if urlResponse?.statusCode == 200 {
                
                if let data = data {
                    let json = JSON(data: data)
                    var locations = [Location]()
                    
                    locations.append(Location(
                        foursquareId: nil,
                        name: nil,
                        latitude: 0,
                        longitude: 0,
                        formattedAddress: self.searchController.searchBar.text!,
                        pfObject: nil))

                    for var i = 0; i < json["response"]["venues"].count; i++ {
                        let addressArray: [JSON] = json["response"]["venues"][i]["location"]["formattedAddress"].arrayValue
                        var formattedAddress = ""
                        for var j = 0; j < addressArray.count; j++ {
                            formattedAddress += "\(addressArray[j].stringValue)"+(j != addressArray.count - 1 ? "\n" : "")
                        }
                        locations.append(Location(
                            foursquareId: json["response"]["venues"][i]["id"].string,
                            name: json["response"]["venues"][i]["name"].string,
                            latitude: json["response"]["venues"][i]["location"]["lat"].doubleValue,
                            longitude: json["response"]["venues"][i]["location"]["lng"].doubleValue,
                            formattedAddress: formattedAddress,
                            pfObject: nil))
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.searchResultsController.locations = locations
                        self.searchResultsController.tableView.reloadData()
                    })
                }
            }
            
        }.resume()
    }
    
    // MARK: UISearchControllerDelegate
    
    func didDismissSearchController(searchController: UISearchController)
    {
        self.tableView.scrollsToTop = true
    }

    // MARK: - LocationResultsViewControllerDelegate
    
    func didSelectLocation(location: Location)
    {
        self.selectedLocation = location
        self.displayedLocation = location
        self.searchController.active = false
        self.tableView.reloadData()
        let geocoder = CLGeocoder()
        let addressString = (location.formattedAddress! as NSString).stringByReplacingOccurrencesOfString("\n", withString: ",")
        geocoder.geocodeAddressString(addressString) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if (placemarks?.count > 0) {
                location.latitude = (placemarks?[0].location?.coordinate.latitude)!
                location.longitude = (placemarks?[0].location?.coordinate.longitude)!
            }
        }
    }
    
    // MARK: - MapCellDelegate
    
    func textViewDidChange(textView: UITextView, cell: MapCell)
    {
        self.displayedLocation?.name = textView.text == "" ? nil : textView.text
    }
    
    func textViewShouldBeginEditing(textView: UITextView, cell: MapCell)
    {
        selectMapCell(cell)
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

    // MARK: - Actions
    
    @IBAction func cancel(sender: UIBarButtonItem)
    {
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func save(sender: UIBarButtonItem)
    {
        if let location = self.selectedLocation {
            AppDelegate.user().protoEvent.protoLocation = location
        }
        navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - UITextView
    
    func addAccessoryViewToKeyboardForTextView(textView: UITextView)
    {
        let doneToolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 50))
        doneToolbar.barStyle = .BlackTranslucent
        doneToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Dismiss Keyboard", style: .Done, target: self, action: "dismissKeyboard"),
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        ]
        doneToolbar.sizeToFit()
        textView.inputAccessoryView = doneToolbar
    }
    
    func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
}
