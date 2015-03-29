//
//  User.h
//  Invite
//
//  Created by Ryan Jennings on 2/12/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

#import "AppDelegate.h"
@class Event;

@interface User : NSObject

@property (nonatomic, strong) PFObject *parse;

@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *locale;
@property (nonatomic, strong) NSString *facebookID;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *facebookLink;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *firstName;

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSArray *friendEmails;
@property (nonatomic, strong) NSDictionary *locations;

@property (nonatomic, strong) PFObject *eventToDisplay;

@property (nonatomic, strong) NSSet *busyTimes;

@property (nonatomic, strong) Event *protoEvent;

+ (instancetype)shared;

- (void)loadParseUser:(PFObject *)user;
- (void)createParseUserFromFacebookUser:(id<FBGraphUser>)user;

//- (void)checkForEventsWhereUserIsInvited;

@end
