//
//  DashboardViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 10/5/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

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
    
    var groups = [String: [PFObject]]()
    var groupKeys = [String]()
    var groupIndexTitles = [String]()
    var groupIndexTitleSections = [Int]()
    
    var nextEvent: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configureSearchController()
        separateEventsIntoGroups()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if AppDelegate.user().events.count == 0 {
            configureOnboarding()
        }
        
        self.view.backgroundColor = UIColor.inviteSlateColor()

        self.tableView.tableHeaderView = tableHeaderView()
        self.tableView.sectionIndexColor = UIColor.inviteBlueColor()
        self.tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        self.tableView.reloadSectionIndexTitles()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 89
        self.definesPresentationContext = true

        self.navigationItem.title = "Invite"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventCreated:", name: EVENT_CREATED_NOTIFICATION, object: nil)
    }
    
    func configureSearchController()
    {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.scopeButtonTitles = ["All", "My", "Going", "Sorry", "Maybe"]
        self.searchController.searchBar.selectedScopeButtonIndex = 0
        self.searchController.searchBar.placeholder = "Search for an event"
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
        self.searchController.searchBar.autocapitalizationType = UITextAutocapitalizationType.None
        self.searchController.searchBar.autocorrectionType = UITextAutocorrectionType.No
        self.searchController.searchBar.spellCheckingType = UITextSpellCheckingType.No
    }

    private func separateEventsIntoGroups()
    {
        self.groups.removeAll()
        self.groupKeys.removeAll()
        
        var currentDate = NSDate()
        
        let calendar = NSCalendar.currentCalendar()
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        let components: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
        
        var lastMonth = "-"
        for event in AppDelegate.user().events {
            let e = event as! PFObject
            let startDate = e[EVENT_START_DATE_KEY] as! NSDate
            let s = calendar.components(components, fromDate: startDate)
            let c = calendar.components(components, fromDate: currentDate)

            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            let startDateString = dateFormatter.stringFromDate(startDate)

            if currentDate.earlierDate(startDate).isEqualToDate(startDate) {
                // Old event!
                let old = "Old"
                if self.groups[old] == nil {
                    self.groupKeys.append(old)
                    self.groupIndexTitles.append(lastMonth)
                    self.groups[old] = [PFObject]()
                    self.groupIndexTitleSections.append(0)
                }
                self.groups[old]?.append(e)
                continue
            }
            

            if !(s.day == c.day && s.year == c.year) {

                dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
                let string = dateFormatter.stringFromDate(startDate)
                let components = string.componentsSeparatedByString("/")
                if components[0] != lastMonth {
                    self.groupIndexTitleSections.append(self.groups.count)
                    self.groupIndexTitles.append(components[0])
                    lastMonth = components[0]
                }
                
                if self.nextEvent == nil {
                    self.nextEvent = startDateString
                }
                self.groupKeys.append(startDateString)
                self.groups[startDateString] = [PFObject]()
            }
            self.groups[startDateString]?.append(e)
            
            currentDate = startDate
        }
        print("")
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
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-64-[scrollView]-60-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scrollView": self.onboardingScrollView]))
            
            self.onboardingScrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[onboarding(280)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["onboarding": self.onboarding]))
            self.onboardingScrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[onboarding]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["onboarding": self.onboarding]))
            self.onboardingScrollView.addConstraint(NSLayoutConstraint(item: self.onboarding, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.onboardingScrollView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
            
        } else {
            
            self.view.addSubview(self.onboarding)
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[onboarding(300)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["onboarding": self.onboarding]))
            self.view.addConstraint(NSLayoutConstraint(item: self.onboarding, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: self.onboarding, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
            
        }
    }
    
    // MARK: UITableView
    
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
        if let nextEvent = self.nextEvent {
            label.text = "Your next event is on \(nextEvent)"
        }
        view.addSubview(label)
        
        let views = ["bar": searchBarView, "label": label]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bar]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-50-[label]-50-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bar(44)]-34-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
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
        headerView.textLabel!.font = UIFont.inviteTableHeaderFont()
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
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier(SEGUE_TO_EVENT, sender: self)
        })
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func eventCreated(note: NSNotification)
    {
        dismissOnboarding()
        self.dismissViewControllerAnimated(true, completion: nil)
        separateEventsIntoGroups()
        self.tableView.reloadData()

        AppDelegate.user().protoEvent = nil
        AppDelegate.user().findReservations()
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
    
    @IBAction func logout(button: UIBarButtonItem)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(USER_LOGGED_OUT_NOTIFICATION, object: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - UISearchControllerDelegate
    
    func didDismissSearchController(searchController: UISearchController)
    {
//        reloadFriends()
    }
}
