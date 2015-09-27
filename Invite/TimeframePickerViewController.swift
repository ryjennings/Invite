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

enum TimeframeRow: Int {
    case StartDate = 0
    case EndDate
    case Count
}

@objc(TimeframePickerViewController) class TimeframePickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatePickerViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var conflicts = [Reservation]()
    var startDate: NSDate!
    var endDate: NSDate!
    
    var reservations: NSSet!
    
    // keyboard height 270.0
    let kDatePickerViewHeight = CGFloat(314.0)
    
    var datePickerView = DatePickerView()
    var datePickerViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad()
    {
        reservations = AppDelegate.busyTimes()
        
        tableView.tableHeaderView = tableHeaderView()
        
        self.navigationItem.title = "Event Time"

        configureDatePicker()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        if (startDate == nil) {
            delay(0.5) {
                self.showDatePicker(true)
            };
        }
    }
    
    func determineConflicts()
    {
        conflicts.removeAll(keepCapacity: true)
        
        if (reservations != nil) {
            reservations.enumerateObjectsUsingBlock { (object, stop) -> Void in
                let reservation = object as! Reservation
                self.conflicts.append(reservation)
            }
            if tableView.numberOfSections == 0 && conflicts.count > 0 {
                tableView.insertSections(NSIndexSet(indexesInRange: NSMakeRange(0, 2)), withRowAnimation: UITableViewRowAnimation.Fade)
            } else if tableView.numberOfSections == 0 {
                tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            } else if tableView.numberOfSections == 2 && conflicts.count == 0 {
                tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
            } else {
                tableView.reloadData()
            }
        }
    }
    
    func configureDatePicker()
    {
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        datePickerView.delegate = self
        self.view.addSubview(datePickerView)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[picker]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["picker": datePickerView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[picker(height)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["height": kDatePickerViewHeight], views: ["picker": datePickerView]))
        datePickerViewBottomConstraint = NSLayoutConstraint(item: datePickerView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: kDatePickerViewHeight)
        self.view.addConstraint(datePickerViewBottomConstraint)
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
    }
    
    func tableHeaderView() -> UIView
    {
        let view = UIView(frame: CGRectMake(0, 0, 0, 100))
        view.backgroundColor = UIColor.clearColor()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.inviteQuestionColor()
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.font = UIFont.inviteQuestionFont()
        label.text = "When would you like this event to start and end?"
        view.addSubview(label)
        
        let views = ["label": label]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-50-[label]-50-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-34-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
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
        switch (section) {
        case TimeframeSection.Timeframe.rawValue:
            return "Timeframe"
        case TimeframeSection.Conflicts.rawValue:
            return "Conflicts"
        default:
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if startDate == nil {
            return 1
        }
        if conflicts.count == 0 {
            return 1
        }
        return TimeframeSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch (section) {
        case TimeframeSection.Timeframe.rawValue:
            return 2
        case TimeframeSection.Conflicts.rawValue:
            return conflicts.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (indexPath.section == TimeframeSection.Timeframe.rawValue) {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(BASIC_RIGHT_CELL_IDENTIFIER, forIndexPath: indexPath) as! BasicCell
            cell.textLabel?.font = UIFont.inviteTableMediumFont()
            cell.detailTextLabel?.font = UIFont.inviteTableMediumFont()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            if (indexPath.row == TimeframeRow.StartDate.rawValue) {
                cell.textLabel?.text = startDate == nil ? "Select start time" : formattedDate(startDate)
                cell.detailTextLabel?.text = "Start time"
            } else {
                cell.textLabel?.text = endDate == nil ? "Select end time" : formattedDate(endDate)
                cell.detailTextLabel?.text = "End time"
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(CONFLICT_CELL_IDENTIFIER, forIndexPath: indexPath) as! ConflictCell
            cell.conflictViewLeadingConstraint.constant = cell.separatorInset.left
            
            if (conflicts.count == 0) {
                cell.label.text = "There are no conflicts with this time! You're good to go!"
            } else {
                cell.label.text = conflicts[indexPath.row].userName ?? conflicts[indexPath.row].userEmail
            }
            return cell
        }
    }
    
    func formattedDate(date: NSDate) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(date)
    }
    
    func hourFromDate(date: NSDate) -> Int
    {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Hour, fromDate: date)
        var hour = components.hour
        if hour > 12 {
            hour -= 12
        }
        return hour
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if (indexPath.section == TimeframeSection.Timeframe.rawValue) {
            showDatePicker(true)
            datePickerView.isSelectingStartDate = indexPath.row == TimeframeRow.StartDate.rawValue ? true : false
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if (indexPath.section == TimeframeSection.Timeframe.rawValue) {
            return 54
        } else {
            return 44
        }
    }
    
    func showDatePicker(show: Bool)
    {
        datePickerViewBottomConstraint.constant = show ? 0 : kDatePickerViewHeight

        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.25)
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: 7)!)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        self.view.layoutIfNeeded()
        
        UIView.commitAnimations()
    }
    
    // MARK: - DatePickerViewDelegate
    
    func datePickerView(datePickerView: DatePickerView, hasSelectedDate date: NSDate)
    {
        showDatePicker(false)
        if (datePickerView.isSelectingStartDate) {
            startDate = date
            if (endDate == nil || endDate.earlierDate(startDate).isEqualToDate(endDate)) {
                endDate = startDate
            }
        } else {
            endDate = date
        }
        determineConflicts()
    }
    
    @IBAction func cancel(sender: UIBarButtonItem)
    {
//        AppDelegate.nilProtoEvent()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func save(sender: UIBarButtonItem)
    {
        if startDate != nil && endDate != nil {
            AppDelegate.addToProtoEventStartDate(startDate, endDate: endDate)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == SEGUE_TO_LOCATION) {
            AppDelegate.addToProtoEventStartDate(startDate, endDate: endDate)
        }
    }
}
