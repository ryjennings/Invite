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
    class func editTimeframeForStartDate(startDate: NSDate!, endDate: NSDate!) -> NSAttributedString
    {
        let att = NSMutableAttributedString()
        let calendar = NSCalendar.currentCalendar()
        let dateFormatter = NSDateFormatter()
        let components: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
        let s = calendar.components(components, fromDate: startDate)
        let e = calendar.components(components, fromDate: endDate)
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        
        let startDayText = dateFormatter.stringFromDate(startDate)
        
        var endDayText: String?
        var endHourText: String?

        if (!(s.day  == e.day &&
            s.month  == e.month &&
            s.year   == e.year))
        {
            endDayText = dateFormatter.stringFromDate(endDate)
        }

        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        
        let startHourText = dateFormatter.stringFromDate(startDate)

        if (!(s.day  == e.day &&
            s.month  == e.month &&
            s.year   == e.year &&
            s.hour   == e.hour &&
            s.minute == e.minute))
        {
            endHourText = dateFormatter.stringFromDate(endDate)
        }
        
        if let endDayText = endDayText, endHourText = endHourText
        {
            att.appendAttributedString(NSAttributedString(string: "Starting \(startDayText) at \(startHourText)", attributes: [NSForegroundColorAttributeName: UIColor.inviteTableHeaderColor(), NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(17)]))
            att.appendAttributedString(NSAttributedString(string: "\n \n", attributes: [NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(5)]))
            att.appendAttributedString(NSAttributedString(string: "until \(endHourText) on \(endDayText)", attributes: [NSForegroundColorAttributeName: UIColor.inviteTableHeaderColor(), NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(17)]))
        }
        else if let endHourText = endHourText
        {
            att.appendAttributedString(NSAttributedString(string: "\(startHourText) until \(endHourText)", attributes: [NSForegroundColorAttributeName: UIColor.inviteTableHeaderColor(), NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(20)]))
            att.appendAttributedString(NSAttributedString(string: "\n \n", attributes: [NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(5)]))
            att.appendAttributedString(NSAttributedString(string: "on \(startDayText)", attributes: [NSForegroundColorAttributeName: UIColor.inviteTableHeaderColor(), NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(18)]))
        }
        else
        {
            att.appendAttributedString(NSAttributedString(string: "\(startHourText) on \(startDayText)", attributes: [NSForegroundColorAttributeName: UIColor.inviteTableHeaderColor(), NSFontAttributeName: UIFont.proximaNovaRegularFontOfSize(20)]))
        }
        
        return att
    }

    class func viewTimeframeForStartDate(startDate: NSDate!, endDate: NSDate!) -> NSString
    {
        var string = ""
        let calendar = NSCalendar.currentCalendar()
        let dateFormatter = NSDateFormatter()
        let components: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
        let s = calendar.components(components, fromDate: startDate)
        let e = calendar.components(components, fromDate: endDate)
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        
        let startDayText = dateFormatter.stringFromDate(startDate)
        
        var endDayText: String?
        var endHourText: String?
        
        if (!(s.day  == e.day &&
            s.month  == e.month &&
            s.year   == e.year))
        {
            endDayText = dateFormatter.stringFromDate(endDate)
        }
        
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        
        let startHourText = dateFormatter.stringFromDate(startDate)
        
        if (!(s.day  == e.day &&
            s.month  == e.month &&
            s.year   == e.year &&
            s.hour   == e.hour &&
            s.minute == e.minute))
        {
            endHourText = dateFormatter.stringFromDate(endDate)
        }
        
        if let endDayText = endDayText, endHourText = endHourText
        {
            string = "Starting \(startDayText) at \(startHourText)\nuntil \(endHourText) on \(endDayText)"
        }
        else if let endHourText = endHourText
        {
            string = "\(startHourText) until \(endHourText)\non \(startDayText)"
        }
        else
        {
            string = "\(startHourText) on \(startDayText)"
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
