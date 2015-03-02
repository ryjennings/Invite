//
//  BusyDetails.m
//  Invite
//
//  Created by Ryan Jennings on 2/21/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "BusyDetails.h"

@implementation BusyDetails

+ (BusyDetails *)busyDetailsWithPersonName:(NSString *)personName eventName:(NSString *)eventName startDate:(NSDate *)startDate duration:(NSUInteger)duration
{
    BusyDetails *busy = [[BusyDetails alloc] init];
    busy.personName = personName;
    busy.eventName = eventName;
    busy.startDate = startDate;
    busy.duration = duration;
    return busy;
}

@end
