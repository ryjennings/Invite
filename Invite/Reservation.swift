//
//  Reservation.swift
//  Invite
//
//  Created by Ryan Jennings on 9/23/15.
//  Copyright © 2015 Appuous. All rights reserved.
//

import UIKit

class Reservation: NSObject
{
    var userName: String!
    var userEmail: String!
    var eventTitle: String!
    var eventResponse: EventResponse!
    var eventStartDate: NSDate!
    var eventEndDate: NSDate!
    
    @objc class func reservationWithUserName(name: String, userEmail email: String, eventTitle title: String, eventResponse response: EventResponse, eventStartDate startDate: NSDate, eventEndDate endDate: NSDate) -> Reservation
    {
        let r = Reservation()
        r.userName = name
        r.userEmail = email
        r.eventTitle = title
        r.eventResponse = response
        r.eventStartDate = startDate
        r.eventEndDate = endDate
        return r
    }
}
