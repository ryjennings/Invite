//
//  DashboardViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 10/5/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit
import Crashlytics

@objc(DashboardViewController) class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchBarDelegate
{
//    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if AppDelegate.user().events != nil && AppDelegate.user().events.count > 0 {
            configureToDisplayEvents()
        } else {
            configureOnboarding()
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.view.backgroundColor = UIColor.inviteSlateColor()

        self.tableView.sectionIndexColor = UIColor.inviteBlueColor()
        self.tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        self.tableView.reloadSectionIndexTitles()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 89
        self.definesPresentationContext = true

        self.navigationItem.title = "Invite"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventCreated:", name: EVENT_CREATED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissEventController:", name: DISMISS_EVENT_CONTROLLER_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventClosed:", name: EVENT_CLOSED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLoggedOut:", name: USER_LOGGED_OUT_NOTIFICATION, object: nil)
        
//        delay(10) {
//            Crashlytics.sharedInstance().crash()
//        }
        
//        let to = [["email": "ryjennings@gmail.com", "name": "Ryan Jennings"], ["email": "rjennings@ancestry.com", "name": "Ryan Jennings"]]
//        PFCloud.callFunctionInBackground("emailTemplate", withParameters: ["template": "new-event-creator", "to": to, "fromEmail": "ryjennings@gmail.com", "fromName": "Ryan Jennings", "subject": "New event!"]) { (result: AnyObject?, error: NSError?) -> Void in
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                print(result)
//            }
//        }
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
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.scopeButtonTitles = ["All", "My", "Going/Maybe", "Sorry", "Needs Response"]
        self.searchController.searchBar.selectedScopeButtonIndex = 0
        self.searchController.searchBar.placeholder = "Search for an event"
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
        self.searchController.searchBar.autocapitalizationType = UITextAutocapitalizationType.None
        self.searchController.searchBar.autocorrectionType = UITextAutocorrectionType.No
        self.searchController.searchBar.spellCheckingType = UITextSpellCheckingType.No
    }

    private func separateEventsIntoGroups()
    {
        self.oldEvents.removeAll()
        self.groups.removeAll()
        self.groupKeys.removeAll()
        self.groupIndexTitles.removeAll()
        self.groupIndexTitleSections.removeAll()
        
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
        
        for event in eventsToDisplay {
            let startDate = event[EVENT_START_DATE_KEY] as! NSDate
            let s = calendar.components(components, fromDate: startDate)
            let l = calendar.components(components, fromDate: lastEventStartDate)
            let n = calendar.components(components, fromDate: now)

            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            let startDateString = dateFormatter.stringFromDate(startDate)

            if now.earlierDate(startDate).isEqualToDate(startDate) {
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
                lastEventStartDate = startDate
                continue
            }

            if !(s.day == l.day && s.month == l.month && s.year == l.year) {

                dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
                let string = dateFormatter.stringFromDate(startDate)
                let components = string.componentsSeparatedByString("/")
                if components[0] != lastMonth {
                    self.groupIndexTitleSections.append(self.groups.count - 1)
                    self.groupIndexTitles.append(components[0])
                    lastMonth = components[0]
                }
                
                if self.nextEvent == nil {
                    self.nextEvent = startDateString
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
            
            lastEventStartDate = startDate
        }
        
        if let oldEvents = oldEvents {
            let old = "Old"
            if self.groups[old] == nil {

                self.groupKeys.append(old)
                self.groupIndexTitles.append("O")

                section++

                self.groups[old] = oldEvents
                self.groupIndexTitleSections.append(self.groups.count - 1)
            }
        }
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        let view = UIView(frame: CGRectMake(0, 0, 0, 160))
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
        label.preferredMaxLayoutWidth = 300
        label.numberOfLines = 0
        label.font = UIFont.inviteQuestionFont()
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        style.alignment = NSTextAlignment.Center
        
        let att = NSMutableAttributedString()
        att.appendAttributedString(NSAttributedString(string: "Your next event is on\n", attributes: [NSFontAttributeName: UIFont.proximaNovaLightFontOfSize(26), NSForegroundColorAttributeName: UIColor.inviteQuestionColor(), NSParagraphStyleAttributeName: style]))
        att.appendAttributedString(NSAttributedString(string: self.nextEvent!, attributes: [NSFontAttributeName: UIFont.proximaNovaSemiboldFontOfSize(26), NSForegroundColorAttributeName: UIColor.inviteQuestionColor(), NSParagraphStyleAttributeName: style]))
        label.attributedText = att
        
        view.addSubview(label)
        
        let views = ["bar": searchBarView, "label": label]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bar]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[label]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bar(44)]-36-[label]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        return view
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]?
    {
        return self.groupIndexTitles
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
        return self.groupKeys[section]
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
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
        let cell = tableView.dequeueReusableCellWithIdentifier(DASHBOARD_CELL_IDENTIFIER, forIndexPath: indexPath) as! DashboardCell
        cell.event = self.groups[self.groupKeys[indexPath.section]]![indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        AppDelegate.user().eventToDisplay = self.groups[self.groupKeys[indexPath.section]]![indexPath.row]
        self.selectedKey = self.groupKeys[indexPath.section]
        self.selectedRow = indexPath.row
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
        if self.tableView.tableHeaderView == nil {
            configureToDisplayEvents()
        }

        if let createdEvent = note.userInfo?["createdEvent"] as? PFObject {
            self.createdEvent = createdEvent
        }
        
        dismissOnboarding()
        separateEventsIntoGroups()
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
    
    func eventClosed(note: NSNotification)
    {
//        self.groups[self.selectedKey!]![self.selectedRow!] = AppDelegate.user().eventToDisplay
        AppDelegate.user().eventToDisplay = nil
        AppDelegate.user().createMyReponses()
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
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
    {
        separateEventsIntoGroups()
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        separateEventsIntoGroups()
        self.tableView.reloadData()
    }
    
    // MARK: - UISearchControllerDelegate
    
    func didDismissSearchController(searchController: UISearchController)
    {
        separateEventsIntoGroups()
        self.tableView.reloadData()
    }
}
