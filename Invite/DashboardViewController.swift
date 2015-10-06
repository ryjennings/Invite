//
//  DashboardViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 10/5/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

@objc(DashboardViewController) class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var onboardingScrollView: UIScrollView!
    var gradientView: OBGradientView!
    var onboarding: DashboardOnboardingView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if AppDelegate.user().events.count == 0 {
            configureOnboarding()
        }
        
        self.view.backgroundColor = UIColor.inviteSlateColor()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 89

        self.newButton.setTitle(NSLocalizedString("dashboard_button_addnewevent", comment: ""), forState: UIControlState.Normal)
        self.newButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.newButton.titleLabel?.font = UIFont.proximaNovaRegularFontOfSize(18)
        self.newButton.backgroundColor = UIColor.inviteSlateButtonColor()
        
        self.navigationItem.title = "Invite"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventCreated:", name: EVENT_CREATED_NOTIFICATION, object: nil)
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return AppDelegate.user().events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(DASHBOARD_CELL_IDENTIFIER, forIndexPath: indexPath) as! DashboardCell
        cell.event = AppDelegate.user().events[indexPath.row] as! PFObject
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        AppDelegate.user().eventToDisplay = AppDelegate.user().events[indexPath.row] as! PFObject
        self.performSegueWithIdentifier(SEGUE_TO_EVENT, sender: self)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func eventCreated(note: NSNotification)
    {
        self.dismissOnboarding()
        self.dismissViewControllerAnimated(true, completion: nil)
        self.tableView.reloadData()

        AppDelegate.user().protoEvent = nil
        AppDelegate.user().findReservations()
    }
    
    private func dismissOnboarding()
    {
        self.onboardingScrollView.removeFromSuperview()
        self.onboarding.removeFromSuperview()
        self.gradientView.removeFromSuperview()
        self.onboardingScrollView = nil
        self.onboarding = nil
        self.gradientView = nil
    }
    
    @IBAction func logout(button: UIBarButtonItem)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(USER_LOGGED_OUT_NOTIFICATION, object: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
