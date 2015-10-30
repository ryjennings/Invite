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

@objc(DashboardViewController) class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchBarDelegate, UIScrollViewDelegate
{
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pullView: UIView!
    @IBOutlet weak var pullViewHeightConstraint: NSLayoutConstraint!
    
    var searchController: UISearchController!

    var onboardingScrollView: UIScrollView!
    var gradientView: OBGradientView!
    var onboarding: DashboardOnboardingView!
    
    var oldEvents = [String: [PFObject]]()
    var groups = [String: [PFObject]]()
    var groupKeys = [String]()
    var groupIndexTitles = [String]()
    var groupIndexTitleSections = [Int]()
    
    var nextEvent: String?
    var createdEvent: PFObject?
    var createdEventIndexPath: NSIndexPath?
    
    var selectedKey: String?
    var selectedRow: Int?
    
    var removedIndexPath: NSIndexPath?
    
    var refreshControl: UIRefreshControl!

    var placer: MPTableViewAdPlacer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if AppDelegate.user().events != nil && AppDelegate.user().events.count > 0 {
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

        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.attributedTitle = nil
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.insertSubview(refreshControl, atIndex: 0)
        
        self.navigationItem.title = "Invite"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventCreated:", name: EVENT_CREATED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventUpdated:", name: EVENT_UPDATED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissEventController:", name: DISMISS_EVENT_CONTROLLER_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventClosed:", name: EVENT_CLOSED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLoggedOut:", name: USER_LOGGED_OUT_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishedRefreshingEvents:", name: FINISHED_REFRESHING_EVENTS_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removedEvent:", name: FINISHED_REMOVING_EVENT_NOTIFICATION, object: nil)
        
        if (AppDelegate.app().deeplinkObjectId != nil) {
            deeplink(nil)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deeplink:", name: DEEPLINK_NOTIFICATION, object: nil)
        
//        delay(10) {
//            Crashlytics.sharedInstance().crash()
//        }
        
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
        self.tableView.tableHeaderView = tableHeaderView()
        self.tableView.reloadData()
    }
    
    func removedEvent(note: NSNotification)
    {
        separateEventsIntoGroups()
        if (self.tableView.numberOfRowsInSection(self.removedIndexPath!.section) > 1) {
            self.tableView.deleteRowsAtIndexPaths([self.removedIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            self.tableView.deleteSections(NSIndexSet(index: self.removedIndexPath!.section), withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    func configureToDisplayEvents()
    {
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
        let targeting = MPNativeAdRequestTargeting()
        
        // TODO: Use the device's location
        targeting.location = CLLocation(latitude: 37.7793, longitude: -122.4175)
        targeting.desiredAssets = Set([kAdIconImageKey, kAdMainImageKey, kAdCTATextKey, kAdTextKey, kAdTitleKey])
        let positioning = MPClientAdPositioning()

        self.oldEvents.removeAll()
        self.groups.removeAll()
        self.groupKeys.removeAll()
        self.groupIndexTitles.removeAll()
        self.groupIndexTitleSections.removeAll()
        
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
        
        var eventsToDisplay = [PFObject]()
        if self.searchController.searchBar.selectedScopeButtonIndex == 0 {
            eventsToDisplay = AppDelegate.user().events as! [PFObject]
        } else {
            for event in AppDelegate.user().events {
                switch self.searchController.searchBar.selectedScopeButtonIndex {
                case 1:
                    if (event[EVENT_CREATOR_KEY] as! PFObject)[FACEBOOK_ID_KEY] as! String == AppDelegate.parseUser()[FACEBOOK_ID_KEY] as! String {
                        eventsToDisplay.append(event as! PFObject)
                    }
                case 2:
                    let response = EventMyResponse(rawValue: AppDelegate.user().myResponses[event.objectId!!] as! UInt)!
                    if response == EventMyResponse.Going || response == EventMyResponse.Maybe {
                        eventsToDisplay.append(event as! PFObject)
                    }
                case 3:
                    if EventMyResponse(rawValue: AppDelegate.user().myResponses[event.objectId!!] as! UInt)! == EventMyResponse.Sorry {
                        eventsToDisplay.append(event as! PFObject)
                    }
                case 4:
                    if EventMyResponse(rawValue: AppDelegate.user().myResponses[event.objectId!!] as! UInt)! == EventMyResponse.NoResponse {
                        eventsToDisplay.append(event as! PFObject)
                    }
                default:
                    break
                }
            }
        }
        
        if AppDelegate.user().needsResponse != nil {
            // New event
            let new = "New"
            self.groupKeys.append(new)
            self.groupIndexTitles.append("N")
            
            section++
            
            self.groups[new] = [PFObject]()
            self.groupIndexTitleSections.append(self.groups.count - 1)
            self.nextEvent = AppDelegate.user().needsResponse[EVENT_TITLE_KEY] as? String
            self.groups[new]?.append(AppDelegate.user().needsResponse)
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
                    self.groupIndexTitles.append("T")
                    
                    section++
                    row = -1
                    
                    self.groups[today] = [PFObject]()
                    self.groupIndexTitleSections.append(self.groups.count - 1)
                }
                row++
                if self.createdEvent === event {
                    self.createdEventIndexPath = NSIndexPath(forRow: row, inSection: section)
                }
                self.groups[today]?.append(event)
                adRowCount++
                lastEventStartDate = startDate
                continue
            }
            
            if !(s.day == l.day && s.month == l.month && s.year == l.year) {

                if adRowCount > 3 {
                    adRowCount = 0
                    
                    // Ad
                    section++
                    positioning.addFixedIndexPath(NSIndexPath(forRow: 0, inSection: section))

                    let ad = "Ad"
                    self.groupKeys.append(ad)
                    self.groupIndexTitles.append(" ")
                    self.groups[ad] = [PFObject]()
                    self.groupIndexTitleSections.append(self.groups.count - 1)
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
            if self.createdEvent === event {
                self.createdEventIndexPath = NSIndexPath(forRow: row, inSection: section)
            }
            self.groups[startDateString]?.append(event)
            adRowCount++
            
            lastEventStartDate = startDate
        }
        
        if let oldEvents = oldEvents {
            let old = "Old Events"
            if self.groups[old] == nil {

                self.groupKeys.append(old)
                self.groupIndexTitles.append("O")

                section++

                self.groups[old] = oldEvents
                self.groupIndexTitleSections.append(self.groups.count - 1)
            }
        }

        // Ad placer
        self.placer = MPTableViewAdPlacer(tableView: self.tableView, viewController: self, adPositioning: positioning, defaultAdRenderingClass: AdCell.self)
        self.placer.loadAdsForAdUnitID("d5566993d01246f3a67b01378bf829ee", targeting: targeting)
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
        self.onboarding = DashboardOnboardingView()
        self.onboarding.translatesAutoresizingMaskIntoConstraints = false
        self.onboarding.backgroundColor = UIColor.clearColor()
        
        if SDiPhoneVersion.deviceSize() == DeviceSize.iPhone35inch || SDiPhoneVersion.deviceSize() == DeviceSize.iPhone4inch {
            
            self.onboardingScrollView = UIScrollView()
            self.onboardingScrollView.translatesAutoresizingMaskIntoConstraints = false
            self.onboardingScrollView.backgroundColor = UIColor.clearColor()
            self.onboardingScrollView.indicatorStyle = UIScrollViewIndicatorStyle.White
            self.view.addSubview(self.onboarding)
            
            self.gradientView = OBGradientView()
            self.gradientView.colors = [UIColor.inviteSlateClearColor(), UIColor.inviteSlateColor()]
            self.gradientView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(self.gradientView)
            
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[gradientView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["gradientView": self.gradientView]))
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[gradientView(30)]-60-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["gradientView": self.gradientView]))
            
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
    }
    
    // MARK: UITableView
    
    func tableHeaderView() -> UIView
    {
        let view = OBGradientView(frame: CGRectMake(0, 0, 0, AppDelegate.user().needsResponse != nil ? 115 : 150))
        view.backgroundColor = UIColor.clearColor()
        if AppDelegate.user().needsResponse == nil {
            view.colors = [UIColor.inviteGrayColor(), UIColor.whiteColor()]
        } else {
            view.colors = [UIColor.inviteLightYellowGradientColor(), UIColor.inviteLightYellowColor()]
        }
        
        let searchBarView = UIView()
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        searchBarView.addSubview(searchController.searchBar)
        view.addSubview(searchBarView)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.inviteQuestionColor()
        label.textAlignment = .Center
        label.preferredMaxLayoutWidth = 300
        label.numberOfLines = 0
        label.font = UIFont.inviteQuestionFont()
        view.addSubview(label)
        
        let profile = ProfileImageView()
        profile.translatesAutoresizingMaskIntoConstraints = false
        profile.setup()
        profile.configureForPerson(AppDelegate.parseUser(), responseValue: 0, width: 80, showResponse: false)
        profile.layer.borderColor = UIColor.whiteColor().CGColor
        profile.layer.borderWidth = 2
        profile.layer.cornerRadius = 40
        profile.clipsToBounds = true
        view.addSubview(profile)
        
        let shadow = OBGradientView()
        shadow.translatesAutoresizingMaskIntoConstraints = false
        shadow.backgroundColor = UIColor.clearColor()
        shadow.colors = [UIColor.inviteYellowColor(), UIColor.inviteYellowColor(), UIColor.darkGrayColor().colorWithAlphaComponent(0.15), UIColor.darkGrayColor().colorWithAlphaComponent(0)]
        shadow.locations = [0, 0.05, 0.05, 1]
        if AppDelegate.user().needsResponse != nil {
            view.addSubview(shadow)
        }
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        
        let att = NSMutableAttributedString()
        
        if AppDelegate.user().needsResponse != nil {
            att.appendAttributedString(NSAttributedString(string: "You've been invited to", attributes: [NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(18), NSForegroundColorAttributeName: UIColor.inviteOrangeColor(), NSParagraphStyleAttributeName: style]))
            att.appendAttributedString(NSAttributedString(string: "\n\(self.nextEvent!)", attributes: [NSFontAttributeName: UIFont.proximaNovaSemiboldFontOfSize(24), NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSParagraphStyleAttributeName: style]))
        } else {
            att.appendAttributedString(NSAttributedString(string: "Your next event\n", attributes: [NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(20), NSForegroundColorAttributeName: UIColor.inviteQuestionColor(), NSParagraphStyleAttributeName: style]))
            att.appendAttributedString(NSAttributedString(string: self.nextEvent!, attributes: [NSFontAttributeName: UIFont.proximaNovaSemiboldFontOfSize(24), NSForegroundColorAttributeName: UIColor.inviteQuestionColor(), NSParagraphStyleAttributeName: style]))
        }

        label.attributedText = att
        label.shadowColor = UIColor.whiteColor()
        label.shadowOffset = CGSizeMake(0, 1)
        
        let views = ["bar": searchBarView, "label": label, "profile": profile, "shadow": shadow]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bar]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[profile(80)]-20-[label]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[profile(80)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        if AppDelegate.user().needsResponse != nil {
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bar(44)]-34-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[shadow]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-215-[shadow(15)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        } else {
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bar(44)]-26-[label]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        }
        view.addConstraint(NSLayoutConstraint(item: profile, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: label, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: AppDelegate.user().needsResponse != nil ? 10 : 0))
        
        
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
        return self.groupKeys[indexPath.section] == "Old Events" || EventResponse(rawValue: AppDelegate.user().myResponses[event.objectId!] as! UInt)! == EventResponse.Sorry
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let deleteButton = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            
            self.removedIndexPath = indexPath
            AppDelegate.user().removeEvent(self.groups[self.groupKeys[indexPath.section]]![indexPath.row])
            
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
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor.inviteTableHeaderColor()
        headerView.textLabel!.font = UIFont.proximaNovaSemiboldFontOfSize(13)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0 {
            return nil
        }
        return self.groupKeys[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.groups.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.groups[self.groupKeys[section]]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let event = self.groups[self.groupKeys[indexPath.section]]![indexPath.row]
        
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
        cell.needsResponse = AppDelegate.user().needsResponse != nil && indexPath.section == 0
        cell.isOld = now.earlierDate(end).isEqualToDate(end)
        cell.isLast = indexPath.row == self.groups[self.groupKeys[indexPath.section]]!.count - 1
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
        self.selectedRow = indexPath.row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        AppDelegate.user().eventToDisplay = self.groups[self.groupKeys[indexPath.section]]![indexPath.row]
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
        if let createdEvent = note.userInfo?["createdEvent"] as? PFObject {
            self.createdEvent = createdEvent
        }

        self.placer = nil
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if self.tableView.tableHeaderView == nil {
            configureToDisplayEvents()
        } else {
            dismissOnboarding()
            separateEventsIntoGroups()
            self.tableView.tableHeaderView = tableHeaderView()
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
        AppDelegate.user().refreshEvents()
        AppDelegate.user().protoEvent = nil
        AppDelegate.user().findReservations()
        AppDelegate.user().createMyReponses()
    }
    
    func eventClosed(note: NSNotification)
    {
        AppDelegate.user().eventToDisplay = nil
        AppDelegate.user().protoEvent = nil
        AppDelegate.user().createMyReponses()
        self.placer = nil
        self.tableView.delegate = self
        self.tableView.dataSource = self
        separateEventsIntoGroups()
        self.tableView.tableHeaderView = tableHeaderView()
        self.tableView.reloadData()
    }
    
    private func dismissOnboarding()
    {
        self.onboardingScrollView?.removeFromSuperview()
        self.onboarding?.removeFromSuperview()
        self.gradientView?.removeFromSuperview()
        self.onboardingScrollView = nil
        self.onboarding = nil
        self.gradientView = nil
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
    
    func didDismissSearchController(searchController: UISearchController)
    {
        self.placer = nil
        self.tableView.delegate = self
        self.tableView.dataSource = self
        separateEventsIntoGroups()
        self.tableView.reloadData()
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if scrollView.contentOffset.y < 0 {
            self.pullViewHeightConstraint.constant = abs(scrollView.contentOffset.y)
        } else {
            self.pullViewHeightConstraint.constant = 0
        }
    }
}
