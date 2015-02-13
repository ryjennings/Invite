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

extern NSString *const ClassEventKey;
extern NSString *const EventsKey;

@interface Event : NSObject

+ (Event *)addEventToUser:(User *)user;

@end
