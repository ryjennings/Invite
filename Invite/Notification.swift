//
//  Notification.swift
//  Invite
//
//  Created by Ryan Jennings on 10/27/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

class Notification: NSObject
{
    class func scheduleLocalNotificationForDate(date: NSDate, eventTitle: String, remindMe: Int, objectId: String)
    {
        let ti = self.tiForRemindMe(RemindMe(rawValue: remindMe)!)
        let alertBody = self.alertBodyForRemindMe(RemindMe(rawValue: remindMe)!, eventTitle: eventTitle)
        
        let notification = UILocalNotification()
        notification.alertBody = alertBody
        notification.fireDate = date.dateByAddingTimeInterval(ti)
//        print("scheduled \(objectId) notification at \(date.dateByAddingTimeInterval(ti)) \(eventTitle)")
        notification.soundName = "alert_43.mp3"
        notification.userInfo = ["objectId": objectId]
        notification.category = "InviteCategory"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    class func actualFireDateForDate(date: NSDate, remindMe: Int) -> NSDate
    {
        let ti = self.tiForRemindMe(RemindMe(rawValue: remindMe)!)
        return date.dateByAddingTimeInterval(ti)
    }
    
    class func cancelLocalNotification(objectId: String)
    {
        var notification: UILocalNotification?
        
        if let scheduledLocalNotifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            for note in scheduledLocalNotifications {
                if note.userInfo!["objectId"] as! String == objectId {
                    notification = note
//                    print("canceled \(objectId) notification")
                    break
                }
            }
        }
        if let notification = notification {
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
    }
    
    class func cancelAllLocalNotifications()
    {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    class func tiForRemindMe(remindMe: RemindMe) -> Double
    {
        switch remindMe {
        case .UseDefault:
            return self.tiForDefaultRemindMe()
        case .AtTimeOfEvent:
            return 0
        case .FiveMinutesBefore:
            return 5 * 60 * -1
        case .FifteenMinutesBefore:
            return 15 * 60 * -1
        case .ThirtyMinutesBefore:
            return 30 * 60 * -1
        case .OneHourBefore:
            return 60 * 60 * -1
        case .TwoHoursBefore:
            return 120 * 60 * -1
        }
    }
    
    class func tiForDefaultRemindMe() -> Double
    {
        if UserDefaults.objectForKey("DefaultRemindMe") == nil {
            UserDefaults.setInteger(RemindMe.FifteenMinutesBefore.rawValue, key: "DefaultRemindMe")
        }
        switch RemindMe(rawValue: UserDefaults.integerForKey("DefaultRemindMe"))! {
        case .FiveMinutesBefore:
            return 5 * 60 * -1
        case .FifteenMinutesBefore:
            return 15 * 60 * -1
        case .ThirtyMinutesBefore:
            return 30 * 60 * -1
        case .OneHourBefore:
            return 60 * 60 * -1
        case .TwoHoursBefore:
            return 120 * 60 * -1
        default: return 0
        }
    }
    
    class func alertBodyForRemindMe(remindMe: RemindMe, eventTitle: String) -> String
    {
        switch remindMe {
        case .UseDefault:
            return self.alertBodyForRemindMe(RemindMe(rawValue: UserDefaults.integerForKey("DefaultRemindMe"))!, eventTitle: eventTitle)
        case .AtTimeOfEvent:
            return "\(eventTitle) happening now"
        case .FiveMinutesBefore:
            return "\(eventTitle) in 5 mins"
        case .FifteenMinutesBefore:
            return "\(eventTitle) in 15 mins"
        case .ThirtyMinutesBefore:
            return "\(eventTitle) in 30 mins"
        case .OneHourBefore:
            return "\(eventTitle) in 1 hour"
        case .TwoHoursBefore:
            return "\(eventTitle) in 2 hours"
        }
    }

    class func alertBodyForDefaultRemindMe(eventTitle: String) -> String
    {
        if UserDefaults.objectForKey("DefaultRemindMe") == nil {
            UserDefaults.setInteger(RemindMe.FifteenMinutesBefore.rawValue, key: "DefaultRemindMe")
        }
        switch RemindMe(rawValue: UserDefaults.integerForKey("DefaultRemindMe"))! {
        case .FiveMinutesBefore:
            return "\(eventTitle) in 5 mins"
        case .FifteenMinutesBefore:
            return "\(eventTitle) in 15 mins"
        case .ThirtyMinutesBefore:
            return "\(eventTitle) in 30 mins"
        case .OneHourBefore:
            return "\(eventTitle) in 1 hour"
        case .TwoHoursBefore:
            return "\(eventTitle) in 2 hours"
        default:
            return "\(eventTitle) happening now"
        }
    }
}
