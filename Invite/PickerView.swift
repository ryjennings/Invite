//
//  PickerView.swift
//  Invite
//
//  Created by Ryan Jennings on 5/16/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

@objc(PickerView) class PickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate
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
    var delegate: PickerViewDelegate?
    var pickerView = UIPickerView()
    let pickerOptions = [kGoingText, kMaybeText, kSorryText]
    var initialOption = 0 {
        didSet {
            pickerView.selectRow(initialOption, inComponent: 0, animated: false)
        }
    }

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
            UIBarButtonItem(title: "Select Response", style: .Done, target: self, action: "dismissPicker:"),
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
        
        pickerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        pickerView.delegate = self
        view.addSubview(pickerView)
        
        let views = ["toolbar": toolbar, "view": view, "picker": pickerView]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[toolbar(44)][view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[picker]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[picker]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerOptions.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return pickerOptions[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
    }
    
    func dismissPicker(picker: UIPickerView)
    {
        let row = pickerView.selectedRowInComponent(0)
        if let delegate = delegate {
            switch row {
            case 0:
                delegate.pickerView(self, hasSelectedResponse: EventResponse.Going, text: pickerOptions[row])
            case 1:
                delegate.pickerView(self, hasSelectedResponse: EventResponse.Maybe, text: pickerOptions[row])
            default:
                delegate.pickerView(self, hasSelectedResponse: EventResponse.Sorry, text: pickerOptions[row])
            }
        }
    }
}

@objc(PickerViewDelegate) protocol PickerViewDelegate
{
    func pickerView(pickerView: PickerView, hasSelectedResponse response: EventResponse, text: String)
}
