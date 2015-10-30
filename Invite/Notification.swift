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
    class func scheduleNotificationForDate(fireDate: NSDate, alertBody: String, objectId: String)
    {
        let notification = UILocalNotification()
        notification.alertBody = alertBody
        notification.fireDate = fireDate
        notification.soundName = "alert_43.mp3"
        notification.userInfo = ["objectId": objectId]
        notification.category = "InviteCategory"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        print("scheduled \(objectId) notification")
    }
    
    class func cancelNotification(objectId: String)
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
}
