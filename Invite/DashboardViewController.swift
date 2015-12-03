//
//  DashboardViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 10/5/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit
import Crashlytics
import MoPub
import CoreLocation

@objc(DashboardViewController) class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchBarDelegate, UIScrollViewDelegate, CLLocationManagerDelegate
{
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pullView: UIView!
    @IBOutlet weak var pullViewHeightConstraint: NSLayoutConstraint!
    
    var searchController: UISearchController!

    var onboardingScrollView: UIScrollView!
    var onboarding: DashboardOnboardingView!
    
    var groups = [String: [PFObject]]()
    var groupKeys = [String]()
    var groupIndexTitles = [String]()
    var groupIndexTitleSections = [Int]()
    
    var nextEvent: String?
    var createdEvent: PFObject?
    var createdEventIndexPath: NSIndexPath?
    
    var selectedKey: String?
    var selectedRow: Int?
    
    var removeIndexPath: NSIndexPath?
    var removeEntireSection = false
    
    var refreshControl: UIRefreshControl!

    var placer: MPTableViewAdPlacer!
    
    var isSearching = false
    
    var adIndexSets = [NSIndexSet]()
    
    var adFree = false
    
    var locationManager: CLLocationManager!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if AppDelegate.user().events != nil && AppDelegate.user().events.count > 0 {
            setupLocationManager()
            configureToDisplayEvents()
        } else {
            configureOnboarding()
        }
        
        configurePullView()

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.view.backgroundColor = UIColor.inviteSlateColor()

        self.tableView.sectionIndexColor = UIColor.inviteBlueColor()
        self.tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        self.tableView.reloadSectionIndexTitles()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.backgroundColor = UIColor.clearColor()
        
        self.view.backgroundColor = UIColor.inviteBackgroundSlateColor()
        
        self.definesPresentationContext = true
        
        self.navigationItem.title = "Invite"

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventCreated:", name: EVENT_CREATED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventUpdated:", name: EVENT_UPDATED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissEventController:", name: DISMISS_EVENT_CONTROLLER_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventClosed:", name: EVENT_CLOSED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLoggedOut:", name: USER_LOGGED_OUT_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishedRefreshingEvents:", name: FINISHED_REFRESHING_EVENTS_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removedEvent:", name: FINISHED_REMOVING_EVENT_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deeplink:", name: DEEPLINK_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "returnedFromSettings", name: CLOSING_SETTINGS_NOTIFICATION, object: nil)
        
        if (AppDelegate.app().deeplinkObjectId != nil) {
            deeplink(nil)
        }
        
//        delay(10) {
//            Crashlytics.sharedInstance().crash()
//        }
        
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
        separateEventsIntoGroups()
        self.tableView.reloadData()
    }

    func returnedFromSettings()
    {
        separateEventsIntoGroups()
        self.tableView.reloadData()
    }
    
    func addRefreshControl()
    {
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl.tintColor = UIColor.whiteColor()
            self.refreshControl.attributedTitle = nil
            self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
            self.tableView.insertSubview(refreshControl, atIndex: 0)
        }
    }
    
    func removeRefreshControl()
    {
        if self.refreshControl != nil {
            self.refreshControl.removeFromSuperview()
            self.refreshControl = nil
        }
    }
    
    func refresh(sender: AnyObject)
    {
        self.placer = nil
        self.tableView.delegate = self
        self.tableView.dataSource = self
        AppDelegate.user().refreshEvents()
    }
    
    func finishedRefreshingEvents(note: NSNotification)
    {
        self.refreshControl.endRefreshing()
        AppDelegate.user().createMyReponses()
        self.placer = nil
        self.tableView.delegate = self
        self.tableView.dataSource = self
        separateEventsIntoGroups()
        self.tableView.reloadData()
    }
    
    func removedEvent(note: NSNotification)
    {
        if AppDelegate.user().events.count > 0 {
            self.tableView.mp_beginUpdates()
            separateEventsIntoGroups()
            if self.removeEntireSection {
                self.tableView.mp_deleteSections(NSIndexSet(index: self.removeIndexPath!.section), withRowAnimation: UITableViewRowAnimation.Fade)
            } else {
                self.tableView.mp_deleteRowsAtIndexPaths([self.removeIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            self.tableView.mp_endUpdates()
        } else {
            self.tableView.reloadData()
            revertToOnboarding()
        }
    }
    
    private func revertToOnboarding()
    {
        self.tableView.tableHeaderView = nil
        configureOnboarding()
    }
    
    func configureToDisplayEvents()
    {
        dismissOnboarding()
        configureSearchController()
        separateEventsIntoGroups()
        self.tableView.tableHeaderView = tableHeaderView()
    }
    
    func configureSearchController()
    {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.backgroundColor = UIColor.inviteDarkBlueColor()
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.scopeButtonTitles = ["All", "My", "Going", "Sorry", "Respond"]
        self.searchController.searchBar.selectedScopeButtonIndex = 0
        self.searchController.searchBar.placeholder = "Search for an event"
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
        self.searchController.searchBar.autocapitalizationType = UITextAutocapitalizationType.None
        self.searchController.searchBar.autocorrectionType = UITextAutocorrectionType.No
        self.searchController.searchBar.spellCheckingType = UITextSpellCheckingType.No
    }

    private func separateEventsIntoGroups()
    {
        if UserDefaults.boolForKey("adFree") {
            self.adFree = true
        }

        let targeting = MPNativeAdRequestTargeting()
        let positioning = MPClientAdPositioning()
        var latitude = 37.7793
        var longitude = -122.4175
        if !self.adFree {
            if let lat = self.latitude, long = self.longitude {
                latitude = lat
                longitude = long
            }
            targeting.location = CLLocation(latitude: latitude, longitude: longitude)
            targeting.desiredAssets = Set([kAdIconImageKey, kAdMainImageKey, kAdCTATextKey, kAdTextKey, kAdTitleKey])
        }

        self.groups.removeAll()
        self.groupKeys.removeAll()
        self.groupIndexTitles.removeAll()
        self.groupIndexTitleSections.removeAll()
        
        if self.searchController.searchBar.selectedScopeButtonIndex == 0 && !self.isSearching {
            self.adIndexSets.removeAll()
        }
        
        self.nextEvent = nil
        
        var oldEvents: [PFObject]?
        let now = NSDate()
        var lastEventStartDate = NSDate()
        
        let calendar = NSCalendar.currentCalendar()
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        let components: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
        
        var lastMonth = "-"
        
        var section = -1
        var row = -1
        var adRowCount = 0
        
        let searchText = self.searchController.searchBar.text
        var eventsRefinedBySearch = [PFObject]()
        var eventsToDisplay = [PFObject]()
        
        if self.isSearching {
            removeRefreshControl()
        } else {
            addRefreshControl()
        }
        
        if searchText != "" {
            for event in AppDelegate.user().events as! [PFObject] {
                if ((event["creator"] as! PFObject)["full_name"] as! String).lowercaseString.containsString(searchText!.lowercaseString) {
                    eventsRefinedBySearch.append(event)
                } else if (event[EVENT_TITLE_KEY] as! String).lowercaseString.containsString(searchText!.lowercaseString) {
                    eventsRefinedBySearch.append(event)
                } else if ((event[EVENT_LOCATION_KEY] as! PFObject)[LOCATION_ADDRESS_KEY] as! String).lowercaseString.containsString(searchText!.lowercaseString) ||
                    ((event[EVENT_LOCATION_KEY] as! PFObject)[LOCATION_NAME_KEY] as! String).lowercaseString.containsString(searchText!.lowercaseString) {
                        eventsRefinedBySearch.append(event)
                }
            }
        } else {
            eventsRefinedBySearch = AppDelegate.user().events as! [PFObject]
        }

        if self.searchController.searchBar.selectedScopeButtonIndex == 0 {
            eventsToDisplay = eventsRefinedBySearch
        } else {
            for event in eventsRefinedBySearch {
                switch self.searchController.searchBar.selectedScopeButtonIndex {
                case 1:
                    if (event[EVENT_CREATOR_KEY] as! PFObject)[FACEBOOK_ID_KEY] as! String == AppDelegate.parseUser()[FACEBOOK_ID_KEY] as! String {
                        eventsToDisplay.append(event)
                    }
                case 2:
                    let response = EventMyResponse(rawValue: AppDelegate.user().myResponses[event.objectId!] as! UInt)!
                    if response == EventMyResponse.Going || response == EventMyResponse.Maybe {
                        eventsToDisplay.append(event)
                    }
                case 3:
                    if EventMyResponse(rawValue: AppDelegate.user().myResponses[event.objectId!] as! UInt)! == EventMyResponse.Sorry {
                        eventsToDisplay.append(event)
                    }
                case 4:
                    if EventMyResponse(rawValue: AppDelegate.user().myResponses[event.objectId!] as! UInt)! == EventMyResponse.NoResponse {
                        eventsToDisplay.append(event)
                    }
                default:
                    break
                }
            }
        }
        
        if !self.isSearching && self.searchController.searchBar.selectedScopeButtonIndex == 0 {
            let new = "New"
            self.groupKeys.append(new)
            
            section++
            
            self.groups[new] = [PFObject]()

            if AppDelegate.user().needsResponse != nil {
                self.nextEvent = AppDelegate.user().needsResponse[EVENT_TITLE_KEY] as? String
                self.groups[new]?.append(AppDelegate.user().needsResponse)
            } else {
                self.groups[new]?.append(PFObject(className: CLASS_EVENT_KEY))
            }
            adRowCount++
        }
        
        for event in eventsToDisplay {
            
            let startDate = event[EVENT_START_DATE_KEY] as! NSDate
            let endDate = event[EVENT_END_DATE_KEY] as! NSDate
            let s = calendar.components(components, fromDate: startDate)
            let l = calendar.components(components, fromDate: lastEventStartDate)
            let n = calendar.components(components, fromDate: now)

            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
            let startDateString = dateFormatter.stringFromDate(startDate)

            if now.earlierDate(endDate).isEqualToDate(endDate) {
                if oldEvents == nil {
                    oldEvents = [PFObject]()
                }
                
                oldEvents!.append(event)
                // Old event!
                continue
            }
            
            if s.day == n.day && s.month == n.month && s.year == n.year {
                // Today's events
                let today = "Today"
                if self.groups[today] == nil {
                    
                    if self.nextEvent == nil {
                        dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
                        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
                        let startTime = dateFormatter.stringFromDate(startDate)
                        self.nextEvent = "Today at \(startTime)"
                    }
                    self.groupKeys.append(today)
                    
                    section++
                    row = -1
                    
                    self.groups[today] = [PFObject]()
                }
                row++
                if self.createdEvent?.objectId == event.objectId {
                    self.createdEventIndexPath = NSIndexPath(forRow: row, inSection: section)
                }
                self.groups[today]?.append(event)
                adRowCount++
                lastEventStartDate = startDate
                continue
            }
            
            if !(s.day == l.day && s.month == l.month && s.year == l.year) {

                if !self.isSearching && adRowCount > 2 && !self.adFree {
                    adRowCount = 0
                    
                    // Ad
                    section++
                    if !self.adFree {
                        positioning.addFixedIndexPath(NSIndexPath(forRow: 0, inSection: section))
                    }
                    if self.searchController.searchBar.selectedScopeButtonIndex == 0 && !self.isSearching {
                        self.adIndexSets.append(NSIndexSet(index: section))
                    }

                    let ad = "Ad\(section)"
                    self.groupKeys.append(ad)
                    self.groups[ad] = [PFObject]()
                    self.groups[ad]?.append(PFObject(className: CLASS_EVENT_KEY))
                }

                dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
                let string = dateFormatter.stringFromDate(startDate)
                let components = string.componentsSeparatedByString("/")
                if components[0] != lastMonth {
                    self.groupIndexTitleSections.append(self.groups.count - 1)
                    self.groupIndexTitles.append(components[0])
                    lastMonth = components[0]
                }
                
                if self.nextEvent == nil {
                    dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
                    self.nextEvent = dateFormatter.stringFromDate(startDate)
                }
                self.groupKeys.append(startDateString)
                
                section++
                row = -1

                self.groups[startDateString] = [PFObject]()
            }
            
            row++
            if self.createdEvent?.objectId == event.objectId {
                self.createdEventIndexPath = NSIndexPath(forRow: row, inSection: section)
            }
            self.groups[startDateString]?.append(event)
            adRowCount++
            
            lastEventStartDate = startDate
        }
        
        if !self.isSearching && adRowCount > 2 && !self.adFree {
            adRowCount = 0
            
            // Ad
            section++
            if !self.adFree {
                positioning.addFixedIndexPath(NSIndexPath(forRow: 0, inSection: section))
            }
            if self.searchController.searchBar.selectedScopeButtonIndex == 0 && !self.isSearching {
                self.adIndexSets.append(NSIndexSet(index: section))
            }
            
            let ad = "Ad\(section)"
            self.groupKeys.append(ad)
            self.groups[ad] = [PFObject]()
            self.groups[ad]?.append(PFObject(className: CLASS_EVENT_KEY))
        }

        if let oldEvents = oldEvents {
            let old = "Old Events"
            if self.groups[old] == nil {

                if self.nextEvent == nil {
                    let event = oldEvents[0]
                    let startDate = event[EVENT_START_DATE_KEY] as! NSDate
                    dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
                    self.nextEvent = dateFormatter.stringFromDate(startDate)
                }

                self.groupKeys.append(old)

                section++

                self.groups[old] = oldEvents
            }
        }

        // Ad placer
        if !self.isSearching && self.placer == nil && !self.adFree {
            self.placer = MPTableViewAdPlacer(tableView: self.tableView, viewController: self, adPositioning: positioning, defaultAdRenderingClass: AdCell.self)
            self.placer.loadAdsForAdUnitID("d5566993d01246f3a67b01378bf829ee", targeting: targeting)
        }
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func configurePullView()
    {
        self.pullView.backgroundColor = UIColor(red: 0.17, green: 0.85, blue: 0.51, alpha: 1)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func configureOnboarding()
    {
        if self.onboarding == nil {
            self.onboarding = DashboardOnboardingView()
            self.onboarding.translatesAutoresizingMaskIntoConstraints = false
            self.onboarding.backgroundColor = UIColor.clearColor()
            
            if SDiPhoneVersion.deviceSize() == DeviceSize.iPhone35inch || SDiPhoneVersion.deviceSize() == DeviceSize.iPhone4inch {
                
                self.onboardingScrollView = UIScrollView()
                self.onboardingScrollView.translatesAutoresizingMaskIntoConstraints = false
                self.onboardingScrollView.backgroundColor = UIColor.clearColor()
                self.onboardingScrollView.indicatorStyle = UIScrollViewIndicatorStyle.White
                self.view.addSubview(self.onboardingScrollView)
                self.onboardingScrollView.addSubview(self.onboarding)
                
                self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scrollView": self.onboardingScrollView]))
                self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-64-[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scrollView": self.onboardingScrollView]))
                
                self.onboardingScrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[onboarding(280)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["onboarding": self.onboarding]))
                self.onboardingScrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[onboarding]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["onboarding": self.onboarding]))
                self.onboardingScrollView.addConstraint(NSLayoutConstraint(item: self.onboarding, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.onboardingScrollView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
                
            } else {
                
                self.view.addSubview(self.onboarding)
                self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[onboarding(300)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["onboarding": self.onboarding]))
                self.view.addConstraint(NSLayoutConstraint(item: self.onboarding, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
                self.view.addConstraint(NSLayoutConstraint(item: self.onboarding, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 30))
                
            }
        } else {
            self.onboardingScrollView?.hidden = false
            self.onboarding?.hidden = false
        }
    }
    
    // MARK: UITableView
    
    func tableHeaderView() -> UIView?
    {
        let view = UIView(frame: CGRectMake(0, 0, 0, 44))
        view.backgroundColor = UIColor.clearColor()
        
        let searchBarView = UIView()
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        searchBarView.addSubview(searchController.searchBar)
        view.addSubview(searchBarView)
        
        let views = ["bar": searchBarView]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bar]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bar(44)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        return view
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]?
    {
        return self.groupIndexTitles
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        let event = self.groups[self.groupKeys[indexPath.section]]![indexPath.row]
        if event[EVENT_TITLE_KEY] == nil {
            return false
        }
        
        var isCancelled = false
        if let cancelled = event[EVENT_CANCELLED_KEY] {
            isCancelled = (cancelled as! NSNumber).boolValue
        }

        return self.groupKeys[indexPath.section] == "Old Events" || EventResponse(rawValue: AppDelegate.user().myResponses[event.objectId!] as! UInt)! == EventResponse.Sorry || isCancelled
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let deleteButton = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            
            self.removeEntireSection = self.tableView.numberOfRowsInSection(indexPath.section) > 1 ? false : true
            self.removeIndexPath = indexPath
            let event = self.groups[self.groupKeys[indexPath.section]]![indexPath.row] 
            AppDelegate.user().removeEvent(event)
            Notification.cancelLocalNotification(event.objectId!)
            UserDefaults.removeObjectForKey(event.objectId!)
            
        }
        deleteButton.backgroundColor = UIColor.inviteRedColor()
        return [deleteButton]
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
    {
        return self.groupIndexTitleSections[index]
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        if section > 0 {
            let headerView = view as! UITableViewHeaderFooterView
            headerView.textLabel!.textColor = UIColor.inviteTableHeaderColor()
            headerView.textLabel!.font = UIFont.proximaNovaSemiboldFontOfSize(13)
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if !(self.isSearching || self.searchController.searchBar.selectedScopeButtonIndex > 0) && section == 0 {
            return nil
        }
        if (self.groupKeys[section] as NSString).containsString("Ad") {
            return "Ad"
        }
        return self.groupKeys[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return AppDelegate.user().events.count > 0 ? self.groups.count : 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.groups[self.groupKeys[section]]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let event = self.groups[self.groupKeys[indexPath.section]]![indexPath.row]
        
        if !self.isSearching && self.searchController.searchBar.selectedScopeButtonIndex == 0 && indexPath.section == 0 && indexPath.row == 0 {
            if AppDelegate.user().needsResponse != nil {
                
                let cell = tableView.dequeueReusableCellWithIdentifier(DASHBOARD_NEEDS_RESPONSE_CELL_IDENTIFIER, forIndexPath: indexPath) as! DashboardNeedsResponseCell
                cell.event = event
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCellWithIdentifier(DASHBOARD_NEXT_EVENT_CELL_IDENTIFIER, forIndexPath: indexPath) as! DashboardNextEventCell
                if let nextEvent = self.nextEvent {
                    cell.nextEventString = nextEvent
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                return cell
                
            }
        }
        
        if event[EVENT_TITLE_KEY] == nil {
            let cell = tableView.dequeueReusableCellWithIdentifier(PADDING_CELL_IDENTIFIER, forIndexPath: indexPath) as! PaddingCell
            cell.heightConstraint.constant = 10
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.contentView.backgroundColor = UIColor.clearColor()
            cell.backgroundColor = UIColor(patternImage: UIImage(named: "adbottom")!)
            return cell
        }
        
        let now = NSDate()
        let end = event[EVENT_END_DATE_KEY] as! NSDate
        let cell = tableView.dequeueReusableCellWithIdentifier(DASHBOARD_CELL_IDENTIFIER, forIndexPath: indexPath) as! DashboardCell
        cell.indexPath = indexPath
        cell.needsResponse = !self.isSearching && self.searchController.searchBar.selectedScopeButtonIndex == 0 && AppDelegate.user().needsResponse != nil && indexPath.section == 0
        cell.isOld = now.earlierDate(end).isEqualToDate(end)
        cell.isLast = indexPath.row == self.groups[self.groupKeys[indexPath.section]]!.count - 1
        if let cancelled = event[EVENT_CANCELLED_KEY] {
            cell.isCancelled = (cancelled as! NSNumber).boolValue
        } else {
            cell.isCancelled = false
        }
        cell.isSearching = self.isSearching || self.searchController.searchBar.selectedScopeButtonIndex > 0
        cell.event = event
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.selectedKey = self.groupKeys[indexPath.section]
        if self.selectedKey == "Ad" {
            return
        }
        
        let event = self.groups[self.groupKeys[indexPath.section]]![indexPath.row]
        if let _ = event[EVENT_CANCELLED_KEY] {
            return
        }
        self.selectedRow = indexPath.row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        AppDelegate.user().eventToDisplay = event
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier(SEGUE_TO_EVENT, sender: self)
        })
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func dismissEventController(note: NSNotification)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func eventCreated(note: NSNotification)
    {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        if let createdEvent = note.userInfo?["createdEvent"] as? PFObject {
            self.createdEvent = createdEvent
        }

        self.placer = nil
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if self.tableView.tableHeaderView == nil {
            setupLocationManager()
            configureToDisplayEvents()
        } else {
            separateEventsIntoGroups()
        }
        
        self.tableView.reloadData()
        delay(0) {
            self.tableView.scrollToRowAtIndexPath(self.createdEventIndexPath!, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
            delay(0.2) {
                (self.tableView.cellForRowAtIndexPath(self.createdEventIndexPath!) as! DashboardCell).flashColorView()
            }
        }

        AppDelegate.user().protoEvent = nil
        AppDelegate.user().findReservations()
        AppDelegate.user().createMyReponses()
    }
    
    func eventUpdated(note: NSNotification)
    {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        AppDelegate.user().refreshEvents()
        AppDelegate.user().protoEvent = nil
        AppDelegate.user().findReservations()
        AppDelegate.user().createMyReponses()
    }
    
    func eventClosed(note: NSNotification)
    {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        AppDelegate.user().eventToDisplay = nil
        AppDelegate.user().protoEvent = nil
        AppDelegate.user().createMyReponses()
        self.placer = nil
        self.tableView.delegate = self
        self.tableView.dataSource = self
        separateEventsIntoGroups()
        self.tableView.reloadData()
    }
    
    private func dismissOnboarding()
    {
        self.onboardingScrollView?.hidden = true
        self.onboarding?.hidden = true
    }
    
    func userLoggedOut(note: NSNotification)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func deeplink(note: NSNotification?)
    {
        if let deeplinkObjectId = AppDelegate.app().deeplinkObjectId {
            for event in AppDelegate.user().events as! [PFObject] {
                if event.objectId == deeplinkObjectId {
                    AppDelegate.user().eventToDisplay = event
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier(SEGUE_TO_EVENT, sender: self)
                        AppDelegate.app().deeplinkObjectId = nil
                    })
                    break
                }
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
    {
        self.placer = nil
        self.tableView.delegate = self
        self.tableView.dataSource = self
        separateEventsIntoGroups()
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.placer = nil
        self.tableView.delegate = self
        self.tableView.dataSource = self
        separateEventsIntoGroups()
        self.tableView.reloadData()
    }
    
    // MARK: - UISearchControllerDelegate
    
    func didPresentSearchController(searchController: UISearchController)
    {
        let indexSets = self.adIndexSets
        
        self.isSearching = true
        self.placer = nil
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if self.searchController.searchBar.selectedScopeButtonIndex == 0
        {
            self.tableView.beginUpdates()
            separateEventsIntoGroups()
            
            self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            for indexSet in indexSets {
                self.tableView.deleteSections(indexSet, withRowAnimation: UITableViewRowAnimation.Fade)
            }
            
            self.tableView.endUpdates()
        } else {
            separateEventsIntoGroups()
            self.tableView.reloadData()
        }
    }
    
    func didDismissSearchController(searchController: UISearchController)
    {
        let indexSets = self.adIndexSets

        self.isSearching = false
        self.placer = nil
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if self.searchController.searchBar.selectedScopeButtonIndex == 0
        {
            self.tableView.beginUpdates()
            separateEventsIntoGroups()

            self.tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            for indexSet in indexSets {
                self.tableView.insertSections(indexSet, withRowAnimation: UITableViewRowAnimation.Fade)
            }
            
            self.tableView.endUpdates()
        } else {
            separateEventsIntoGroups()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if !self.isSearching && scrollView.contentOffset.y < 0 {
            self.pullViewHeightConstraint.constant = abs(scrollView.contentOffset.y)
        } else {
            self.pullViewHeightConstraint.constant = 0
        }
    }

    // MARK: - Keyboard
    
    func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        UIView.animateWithDuration(0.35, animations: {
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
        })
    }
    
    // MARK: - DashboardOnboardingViewDelegate
    
    func tappedCreateEventButton()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier(SEGUE_TO_EVENT, sender: self)
        })
    }
}
