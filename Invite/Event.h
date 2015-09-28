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

@interface Event : NSObject

@property (nonatomic, strong) PFObject *creator;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *invitees;
@property (nonatomic, strong) NSArray *emails;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) PFObject *location;
@property (nonatomic, strong) NSDictionary *rsvp;

@property (nonatomic, strong) NSString *savedEmailInput;

+ (Event *)createEvent;
+ (Event *)eventFromPFObject:(PFObject *)object;

- (void)submitEvent;
+ (void)makeAdjustmentsToPerson:(PFObject *)person event:(PFObject *)event;

- (NSString *)timeframe;
- (NSString *)host;

- (void)saveToParse;

@end
