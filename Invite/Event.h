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
#import "Timeframe.h"

@interface Event : NSObject

@property (nonatomic, strong) NSSet *invitees;
@property (nonatomic, strong) NSArray *inviteeEmails;
@property (nonatomic, strong) NSArray *emails;
@property (nonatomic, strong) Timeframe *timeframe;

+ (Event *)createEvent;

- (void)submitEvent;

@end
