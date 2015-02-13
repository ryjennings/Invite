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

extern NSString *const ClassPersonKey;

extern NSString *const GenderKey;
extern NSString *const LocaleKey;
extern NSString *const FacebookIDKey;
extern NSString *const LastNameKey;
extern NSString *const TimezoneKey;
extern NSString *const EmailKey;
extern NSString *const FacebookLinkKey;
extern NSString *const FullNameKey;
extern NSString *const FirstNameKey;
extern NSString *const EventsKey;
extern NSString *const ParseObjectIDKey;

// Keys used by Facebook
extern NSString *const IDKey;
extern NSString *const LinkKey;
extern NSString *const NameKey;

@interface User : NSObject

@property (nonatomic, strong) PFObject *parse;
@property (nonatomic, strong) NSManagedObject *core;

@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *locale;
@property (nonatomic, strong) NSString *facebookID;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, assign) long timezone;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *facebookLink;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *firstName;

+ (instancetype)shared;
- (BOOL)checkForUser;

- (void)createLocalCoreDataUserFromParseObject:(PFObject *)object;
- (void)createLocalParseCoreDataUserFromFacebookUser:(id<FBGraphUser>)user;

@end
