//
//  DatePickerView.swift
//  Invite
//
//  Created by Ryan Jennings on 4/25/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(DatePickerView) class DatePickerView: UIView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        prepareView()
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        prepareView()
    }
    
    var toolbar = UIToolbar()
    var delegate: DatePickerViewDelegate?
    var datePicker = UIDatePicker()
    var selectedDate = NSDate() {
        didSet {
            self.datePicker.setDate(self.selectedDate, animated: true)
        }
    }
    
    var isSelectingStartDate = true {
        didSet {
            datePicker.minimumDate = !isSelectingStartDate ? selectedDate : NSDate()
        }
    }

    func prepareView()
    {
        configureToolbar()
        configurePicker()
    }
    
    func configureToolbar()
    {
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .BlackTranslucent
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .Done, target: self, action: "dismiss:"),
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Select Time", style: .Done, target: self, action: "selectTime:")
            ]
        self.addSubview(toolbar)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[toolbar]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["toolbar": toolbar]))
    }
    
    func configurePicker()
    {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        view.translatesAutoresizingMaskIntoConstraints = false
        datePicker.setValue(UIColor.whiteColor(), forKey: "textColor")
        self.addSubview(view)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.minuteInterval = 15
        view.addSubview(datePicker)
        
        var minute = 0
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(
            [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
            , fromDate: datePicker.date)
        let intervals = [0, 15, 30, 45]
        for interval in intervals {
            if interval < components.minute + 15 {
                minute = interval
            }
        }
        components.minute = minute
        components.second = 0
        selectedDate = calendar.dateFromComponents(components)!
        datePicker.minimumDate = NSDate()
        
        let views = ["toolbar": toolbar, "view": view, "picker": datePicker]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[toolbar(44)][view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[picker]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[picker]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    func dismiss(picker: UIDatePicker)
    {
        self.delegate?.dismissDatePickerView(self)
    }

    func selectTime(picker: UIDatePicker)
    {
        selectedDate = datePicker.date
        self.delegate?.datePickerView(self, hasSelectedDate: selectedDate)
    }
}

@objc protocol DatePickerViewDelegate
{
    func datePickerView(datePickerView: DatePickerView, hasSelectedDate date: NSDate)
    func dismissDatePickerView(datePickerView: DatePickerView)
}
