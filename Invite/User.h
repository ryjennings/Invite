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

// Keys used by Facebook
extern NSString *const IDKey;
extern NSString *const LinkKey;
extern NSString *const NameKey;

@interface User : NSObject

+ (instancetype)shared;
- (BOOL)checkForUser;

- (void)createLocalCoreDataUserFromParseObject:(PFObject *)object;
- (void)createLocalParseCoreDataUserFromFacebookUser:(id<FBGraphUser>)user;

@end
