//
//  BusyDetails.m
//  Invite
//
//  Created by Ryan Jennings on 2/21/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "BusyDetails.h"

@implementation BusyDetails

+ (BusyDetails *)busyDetailsWithPersonName:(NSString *)personName eventName:(NSString *)eventName
{
    BusyDetails *busy = [[BusyDetails alloc] init];
    busy.personName = personName;
    busy.eventName = eventName;
    return busy;
}

@end
