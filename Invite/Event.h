//
//  Event.h
//  Invite
//
//  Created by Ryan Jennings on 2/13/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

#import "User.h"

@interface Event : NSObject

+ (Event *)createPrototype;
//+ (Event *)createEvent;

+ (void)createEventWithEmailAddresses:(NSArray *)emailAddresses;

@end
