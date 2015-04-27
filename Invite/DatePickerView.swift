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

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        prepareView()
    }
    
    var toolbar = UIToolbar()
    var delegate: DatePickerViewDelegate?
    var datePicker = UIDatePicker()
    
    var isSelectingStartDate = true

    func prepareView()
    {
        configureToolbar()
        configurePicker()
    }
    
    func configureToolbar()
    {
        toolbar.setTranslatesAutoresizingMaskIntoConstraints(false)
        toolbar.barStyle = .BlackTranslucent
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Select Date", style: .Done, target: self, action: "dismissPicker:"),
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)]
        self.addSubview(toolbar)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[toolbar]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["toolbar": toolbar]))
    }
    
    func configurePicker()
    {
        var view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.backgroundColor = UIColor.inviteLightSlateColor()
        self.addSubview(view)
        
        datePicker.setTranslatesAutoresizingMaskIntoConstraints(false)
        datePicker.addTarget(self, action: "pickerChanged:", forControlEvents: .ValueChanged)
        datePicker.minuteInterval = 15
        datePicker.setDate(NSDate(), animated: false)
        view.addSubview(datePicker)
        
        let views = ["toolbar": toolbar, "view": view, "picker": datePicker]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[toolbar(44)][view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[picker]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[picker]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    }
    
    func pickerChanged(picker: UIDatePicker)
    {
    }
    
    func dismissPicker(picker: UIDatePicker)
    {
        if let delegate = delegate {
            delegate.datePickerView(self, hasSelectedDate: datePicker.date)
        }
    }
}

@objc protocol DatePickerViewDelegate
{
    func datePickerView(datePickerView: DatePickerView, hasSelectedDate date: NSDate)
}
