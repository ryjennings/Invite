//
//  Event.h
//  Invite
//
//  Created by Ryan Jennings on 2/13/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

#import "User.h"

@interface Event : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *eventDescription;
@property (nonatomic, strong) NSArray *invitees;
@property (nonatomic, strong) NSArray *emails;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) PFObject *location;

//@property (nonatomic, strong) UIImage *coverImage;

@property (nonatomic, strong) NSArray *inviteeEmails;

@property (nonatomic, strong) NSArray *allInvitees;

+ (Event *)createEvent;

- (void)submitEvent;

@end
