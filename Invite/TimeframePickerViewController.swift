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
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    var conflicts = [Reservation]()
    var startDate: NSDate!
    var endDate: NSDate!
    
    var reservations: NSSet!
    
    // keyboard height 270.0
    let kDatePickerViewHeight = CGFloat(314.0)
    
    var datePickerView = DatePickerView()
    var datePickerViewBottomConstraint: NSLayoutConstraint!
    
    var startCell: BasicCell!
    var endCell: BasicCell!
    
    var selectingStartDate = AppDelegate.user().protoEvent.startDate == nil
    var selectingEndDate = false
    
    override func viewDidLoad()
    {
        reservations = AppDelegate.user().reservations
        
        tableView.tableHeaderView = tableHeaderView()
        
        self.navigationItem.title = "Event Time"

        configureDatePicker()
        
        if let startDate = AppDelegate.user().protoEvent.startDate {
            self.startDate = startDate
        }
        if let endDate = AppDelegate.user().protoEvent.endDate {
            self.endDate = endDate
        }
        if self.startDate != nil && self.endDate != nil {
            determineConflicts()
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        if (startDate == nil) {
            delay(0.5) {
                self.showDatePicker(true)
            }
        }
    }
    
    func determineConflicts()
    {
        if AppDelegate.user().protoEvent.invitees != nil {
        
            conflicts.removeAll()
            
            var inviteeIds = [String]()
            
            for invitee in AppDelegate.user().protoEvent.invitees as! [PFObject] {
                inviteeIds.append(invitee.objectId!)
            }

            for reservation in AppDelegate.user().reservations {
                
                let r = reservation as! Reservation
                
                if !inviteeIds.contains(r.userPFObject.objectId!) {
                    continue
                }
                
                if (r.eventStartDate.laterDate(startDate).isEqualToDate(r.eventStartDate) &&
                    r.eventStartDate.earlierDate(endDate).isEqualToDate(r.eventStartDate)) ||
                    r.eventStartDate.isEqualToDate(startDate) {
                        // eventStartDate is either equal to startDate or between startDate and endDate
                        if !conflicts.contains(r) {
                            self.conflicts.append(r)
                        }
                        continue
                }

                if (r.eventEndDate.laterDate(startDate).isEqualToDate(r.eventEndDate) &&
                    r.eventEndDate.earlierDate(endDate).isEqualToDate(r.eventEndDate)) ||
                    r.eventEndDate.isEqualToDate(endDate) {
                        // eventEndDate is either equal to endDate or between startDate and endDate
                        if !conflicts.contains(r) {
                            self.conflicts.append(r)
                        }
                        continue
                }
            }
        }
        
        if tableView.numberOfSections == 0 && self.conflicts.count > 0 {
            tableView.insertSections(NSIndexSet(indexesInRange: NSMakeRange(0, 2)), withRowAnimation: UITableViewRowAnimation.Fade)
        } else if tableView.numberOfSections == 0 {
            tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        } else if tableView.numberOfSections == 2 && self.conflicts.count == 0 {
            tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            tableView.reloadData()
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
                self.startCell = cell
                cell.textLabel?.text = startDate == nil ? "Select start time" : formattedDate(startDate)
                cell.textLabel?.textColor = startDate == nil ? UIColor.inviteTableLabelColor() : UIColor.inviteTableHeaderColor()
                cell.detailTextLabel?.text = "Start time"
                if self.selectingStartDate {
                    selectCell(cell)
                } else {
                    unselectRow(TimeframeRow.StartDate)
                }
            } else {
                self.endCell = cell
                cell.textLabel?.text = endDate == nil ? "Select end time" : formattedDate(endDate)
                cell.textLabel?.textColor = endDate == nil ? UIColor.inviteTableLabelColor() : UIColor.inviteTableHeaderColor()
                cell.detailTextLabel?.text = "End time"
                if self.selectingEndDate {
                    selectCell(cell)
                } else {
                    unselectRow(TimeframeRow.EndDate)
                }
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(PROFILE_CELL_IDENTIFIER, forIndexPath: indexPath) as! ProfileCell
            let conflict = self.conflicts[indexPath.row]
            cell.friend = Friend(fullName: conflict.userPFObject[FULL_NAME_KEY] as? String, lastName: conflict.userPFObject[LAST_NAME_KEY] as? String, email: conflict.userPFObject[EMAIL_KEY] as! String, pfObject: conflict.userPFObject)
            cell.flexLabel.textColor = UIColor.inviteTableHeaderColor()
            cell.accessoryView = nil
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
        if indexPath.section == TimeframeSection.Timeframe.rawValue {
            if indexPath.row == TimeframeRow.StartDate.rawValue {
                self.selectingStartDate = true
                unselectRow(TimeframeRow.EndDate)
                datePickerView.isSelectingStartDate = true
                if startDate != nil {
                    self.datePickerView.selectedDate = startDate
                }
            } else if indexPath.row == TimeframeRow.EndDate.rawValue {
                self.selectingEndDate = true
                unselectRow(TimeframeRow.StartDate)
                datePickerView.isSelectingStartDate = false
                if endDate != nil {
                    self.datePickerView.selectedDate = endDate
                }
            }
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? BasicCell {
                selectCell(cell)
            }
            showDatePicker(true)
        }
    }
    
    func selectCell(cell: BasicCell)
    {
        cell.backgroundColor = UIColor.inviteLightSlateColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
    }
    
    func unselectRow(row: TimeframeRow)
    {
        let cell = row == TimeframeRow.StartDate ? self.startCell : self.endCell
        if row == TimeframeRow.StartDate {
            self.selectingStartDate = false
            cell.textLabel?.textColor = self.startDate == nil ? UIColor.inviteTableLabelColor() : UIColor.inviteTableHeaderColor()
        } else {
            self.selectingEndDate = false
            cell.textLabel?.textColor = self.endDate == nil ? UIColor.inviteTableLabelColor() : UIColor.inviteTableHeaderColor()
        }
        cell.backgroundColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.inviteGrayColor()
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if (indexPath.section == TimeframeSection.Timeframe.rawValue) {
            return 54
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    {
        let footerView = view as! UITableViewHeaderFooterView
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        let att = NSMutableAttributedString(string: NSLocalizedString("timeframe_conflict_footer", comment: ""), attributes: [NSFontAttributeName: UIFont.inviteTableFooterFont(), NSParagraphStyleAttributeName: style])
        footerView.textLabel!.attributedText = att
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        if section == 1 {
            return NSLocalizedString("timeframe_conflict_footer", comment: "")
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if section == 1 {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 4
            let text: NSString = NSLocalizedString("timeframe_conflict_footer", comment: "")
            return text.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - (self.tableView.separatorInset.left * 2), CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: [NSFontAttributeName: UIFont.inviteTableFooterFont(), NSParagraphStyleAttributeName: style], context: nil).size.height + 20
        }
        return 0
    }

    func showDatePicker(show: Bool)
    {
        self.saveBarButtonItem.enabled = !show
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
        unselectRow(TimeframeRow.StartDate)
        unselectRow(TimeframeRow.EndDate)
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
    
    func dismissDatePickerView(datePickerView: DatePickerView)
    {
        unselectRow(TimeframeRow.StartDate)
        unselectRow(TimeframeRow.EndDate)
        showDatePicker(false)
    }
    
    @IBAction func cancel(sender: UIBarButtonItem)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func save(sender: UIBarButtonItem)
    {
        if startDate != nil && endDate != nil {
            AppDelegate.user().protoEvent.startDate = startDate
            AppDelegate.user().protoEvent.endDate = endDate
        }
        self.navigationController?.popViewControllerAnimated(true)
    }    
}
