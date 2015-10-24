//
//  Event.h
//  Invite
//
//  Created by Ryan Jennings on 2/13/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>

#import "User.h"

@class Location;

@interface Event : NSObject

@property (nonatomic, strong) PFObject *creator;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *invitees;
@property (nonatomic, strong) NSArray *emails;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) Location *protoLocation;
@property (nonatomic, strong) PFObject *location;
@property (nonatomic, strong) NSDictionary *rsvp;

@property (nonatomic, strong) PFObject *parseEvent;
@property (nonatomic, assign) BOOL isParseEvent;

@property (nonatomic, strong) NSString *existingTitle;
@property (nonatomic, strong) NSArray *existingInvitees;
@property (nonatomic, strong) NSDate *existingStartDate;
@property (nonatomic, strong) NSDate *existingEndDate;
@property (nonatomic, strong) PFObject *existingLocation;

@property (nonatomic, strong) NSString *savedEmailInput;

+ (Event *)createEvent;
+ (Event *)eventFromPFObject:(PFObject *)object;

- (void)submitEvent;
+ (void)makeAdjustmentsToPerson:(PFObject *)person event:(PFObject *)event;

- (NSAttributedString *)editTimeframe;
- (NSString *)viewTimeframe;
- (NSString *)host;

@end
