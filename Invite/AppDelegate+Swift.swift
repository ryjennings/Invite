//
//  AppDelegate+Swift.swift
//  Invite
//
//  Created by Ryan Jennings on 4/2/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

import UIKit

extension AppDelegate
{
    class func presentationTimeframeFromStartDate(startDate: NSDate!, endDate: NSDate!) -> NSString
    {
        let eventTimeframeFont = UIFont.boldSystemFontOfSize(10)
        var presentationString = NSMutableString()
        let calendar = NSCalendar.currentCalendar()
        let startComponents = calendar.components(
            NSCalendarUnit.YearCalendarUnit |
                NSCalendarUnit.MonthCalendarUnit |
                NSCalendarUnit.DayCalendarUnit |
                NSCalendarUnit.HourCalendarUnit |
                NSCalendarUnit.MinuteCalendarUnit |
                NSCalendarUnit.SecondCalendarUnit
            , fromDate: startDate)
        let endComponents = calendar.components(
            NSCalendarUnit.YearCalendarUnit |
                NSCalendarUnit.MonthCalendarUnit |
                NSCalendarUnit.DayCalendarUnit |
                NSCalendarUnit.HourCalendarUnit |
                NSCalendarUnit.MinuteCalendarUnit |
                NSCalendarUnit.SecondCalendarUnit
            , fromDate: endDate)
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        presentationString.appendString(dateFormatter.stringFromDate(startDate))
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
                presentationString.appendString(NSString(format: " - %@", dateFormatter.stringFromDate(endDate)))
        }
        return presentationString
    }

    class func delay(delay: Double, closure: () -> ()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}
