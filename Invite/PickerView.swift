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
    
    required init?(coder aDecoder: NSCoder)
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
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .BlackTranslucent
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Done, target: self, action: "dismiss:"),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Select Response", style: UIBarButtonItemStyle.Done, target: self, action: "selectResponse:")]
        self.addSubview(toolbar)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[toolbar]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["toolbar": toolbar]))
    }
    
    func configurePicker()
    {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = self
        view.addSubview(pickerView)
        
        let views = ["toolbar": toolbar, "view": view, "picker": pickerView]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[toolbar(44)][view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[picker]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[picker]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerOptions.count
    }
    
    func selectResponse(picker: UIPickerView)
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
    
    func showResponse(response: EventResponse)
    {
        switch response {
        case EventResponse.Going:
            self.pickerView.selectRow(EventResponse.Going.hashValue - 1, inComponent: 0, animated: false)
        case EventResponse.Maybe:
            self.pickerView.selectRow(EventResponse.Maybe.hashValue - 1, inComponent: 0, animated: false)
        case EventResponse.Sorry:
            self.pickerView.selectRow(EventResponse.Sorry.hashValue - 1, inComponent: 0, animated: false)
        default:
            self.pickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }

    func dismiss(picker: UIDatePicker)
    {
        self.delegate?.dismissPickerView(self)
    }

    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?
    {
        let string = pickerOptions[row]
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
    }
}

@objc(PickerViewDelegate) protocol PickerViewDelegate
{
    func pickerView(pickerView: PickerView, hasSelectedResponse response: EventResponse, text: String)
    func dismissPickerView(pickerView: PickerView)
}
