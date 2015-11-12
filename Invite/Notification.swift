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
        var ti: NSTimeInterval
        var alertBody = ""
        
        switch remindMe {
        case 0:
            ti = 0
            alertBody = "\(eventTitle) happening now"
        case 1:
            ti = 5 * 60 * -1
            alertBody = "\(eventTitle) in 5 mins"
        case 2:
            ti = 15 * 60 * -1
            alertBody = "\(eventTitle) in 15 mins"
        case 3:
            ti = 30 * 60 * -1
            alertBody = "\(eventTitle) in 30 mins"
        case 4:
            ti = 60 * 60 * -1
            alertBody = "\(eventTitle) in 1 hour"
        case 5:
            ti = 120 * 60 * -1
            alertBody = "\(eventTitle) in 2 hours"
        default:
            ti = 0
            alertBody = ""
        }
        
        let notification = UILocalNotification()
        notification.alertBody = alertBody
        notification.fireDate = date.dateByAddingTimeInterval(ti)
        notification.soundName = "alert_43.mp3"
        notification.userInfo = ["objectId": objectId]
        notification.category = "InviteCategory"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        print("scheduled \(objectId) notification")
    }
    
    class func cancelLocalNotification(objectId: String)
    {
        var notification: UILocalNotification?
        
        if let scheduledLocalNotifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            for note in scheduledLocalNotifications {
                if note.userInfo!["objectId"] as! String == objectId {
                    notification = note
                    print("canceled \(objectId) notification")
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
}
