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
    var userPFObject: PFObject!
    var eventTitle: String!
    var eventResponse: EventResponse!
    var eventStartDate: NSDate!
    var eventEndDate: NSDate!
    
    @objc class func reservationWithUser(pfObject: PFObject, eventTitle title: String, eventResponse response: EventResponse, eventStartDate startDate: NSDate, eventEndDate endDate: NSDate) -> Reservation
    {
        let r = Reservation()
        r.userPFObject = pfObject
        r.eventTitle = title
        r.eventResponse = response
        r.eventStartDate = startDate
        r.eventEndDate = endDate
        return r
    }
}
