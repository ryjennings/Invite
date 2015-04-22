//
//  TimeframePickerViewController.swift
//  Invite
//
//  Created by Ryan Jennings on 4/19/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

enum TimeframeSection: Int {
    case Timeframe = 0
    case Conflicts
    case Count
}

@objc(TimeframePickerViewController) class TimeframePickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    
    var conflicts: Array<AnyObject> = []
    var startDate: NSDate!
    var endDate: NSDate!
    
    override func viewDidLoad()
    {
        navigationItem.titleView = ProgressView(frame: CGRectMake(0, 0, 150, 15), step: 3, steps: 5)
        
        tableView.tableHeaderView = tableHeaderView()
//        tableView.estimatedRowHeight = 100
//        tableView.rowHeight = UITableViewAutomaticDimension
        
        nextButton.layer.cornerRadius = CGFloat(kCornerRadius)
        nextButton.clipsToBounds = true
        nextButton.titleLabel!.font = UIFont.proximaNovaRegularFontOfSize(18)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
//        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func tableHeaderView() -> UIView
    {
        var view = UIView(frame: CGRectMake(0, 0, 0, 100))
        view.backgroundColor = UIColor.clearColor()
        
        var label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.inviteQuestionColor()
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.font = UIFont.inviteQuestionFont()
        label.text = "When would you like this event to start and end?"
        view.addSubview(label)
        
        let views = ["label": label]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[label]-15-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-34-[label]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        
        return view
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
        case TimeframeSection.Timeframe.rawValue:
            return "Start and End Times"
        case TimeframeSection.Conflicts.rawValue:
            return "Conflicts"
        default:
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return TimeframeSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch (section) {
        case TimeframeSection.Timeframe.rawValue:
            return 2
        case TimeframeSection.Conflicts.rawValue:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (indexPath.section == TimeframeSection.Timeframe.rawValue) {
            var cell = tableView.dequeueReusableCellWithIdentifier(TIME_CELL_IDENTIFIER, forIndexPath: indexPath) as! TimeCell
            cell.prepareCell()
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier(BASIC_CELL_IDENTIFIER, forIndexPath: indexPath) as! BasicCell
            cell.textLabel!.text = "There are no conflicts with this time! You're good to go!"
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 54
    }
}
