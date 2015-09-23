//
//  AppDelegate.swift
//  Invite
//
//  Created by Ryan Jennings on 4/2/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

extension AppDelegate
{
    class func presentationTimeframeForStartDate(startDate: NSDate!, endDate: NSDate!) -> NSString
    {
        let string = NSMutableString()
        let calendar = NSCalendar.currentCalendar()
        let startComponents = calendar.components(
            [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
            , fromDate: startDate)
        let endComponents = calendar.components(
            [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
            , fromDate: endDate)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        string.appendString(dateFormatter.stringFromDate(startDate))
        if (startComponents.day == endComponents.day &&
            startComponents.month == endComponents.month &&
            startComponents.year == endComponents.year) {
                dateFormatter.dateStyle = .NoStyle
        }
        if (!(startComponents.day == endComponents.day &&
            startComponents.month == endComponents.month &&
            startComponents.year == endComponents.year &&
            startComponents.hour == endComponents.hour &&
            startComponents.minute == endComponents.minute &&
            startComponents.second == endComponents.second)) {
                string.appendString(NSString(format: " - %@", dateFormatter.stringFromDate(endDate)) as String)
        }
        return string
    }

}

func delay(delay: Double, closure: () -> ()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}