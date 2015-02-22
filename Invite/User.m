//
//  User.m
//  Invite
//
//  Created by Ryan Jennings on 2/12/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "User.h"

#import "Event.h"
#import "StringConstants.h"

@implementation User

+ (instancetype)shared
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Create

- (void)loadParseUser:(PFObject *)user
{
    _parse = user;
    [self createUserFromObject:user];
    [[NSNotificationCenter defaultCenter] postNotificationName:USER_CREATED_NOTIFICATION object:self];
}

- (void)createParseUserFromFacebookUser:(id<FBGraphUser>)user
{
    [self createUserFromObject:user];
}

- (void)createUserFromObject:(id)object
{
    BOOL parseObject = [object isKindOfClass:[PFObject class]];
    
    _gender = [object objectForKey:GENDER_KEY];
    _locale = [object objectForKey:LOCALE_KEY];
    _lastName = [object objectForKey:LAST_NAME_KEY];
    _timezone = (long)[object objectForKey:TIMEZONE_KEY];
    _email = [object objectForKey:EMAIL_KEY];
    _firstName = [object objectForKey:FIRST_NAME_KEY];

    _facebookID = [object objectForKey:parseObject ? FACEBOOK_ID_KEY : ID_KEY];
    _facebookLink = [object objectForKey:parseObject ? FACEBOOK_LINK_KEY : LINK_KEY];
    _fullName = [object objectForKey:parseObject ? FULL_NAME_KEY : NAME_KEY];

    if (!parseObject) {
        
        [self createParseUser];
        
    } else {
        
        _events = [object objectForKey:EVENTS_KEY];
        _friends = [object objectForKey:FRIENDS_KEY];
        _friendEmails = [object objectForKey:FRIENDEMAILS_KEY];
        
    }
}

- (void)createParseUser
{
    // First, check to make sure a dummy user wasn't created with the same email address
    
    PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
    [query whereKey:EMAIL_KEY equalTo:_email];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *match, NSError *error) {
        
        PFObject *person;
        
        if (match) {
            
            person = match;
            
        } else {
            
            person = [PFObject objectWithClassName:CLASS_PERSON_KEY];
            person[EMAIL_KEY] = _email;
            
        }
        
        _parse = person;

        person[GENDER_KEY] = _gender;
        person[LOCALE_KEY] = _locale;
        person[FACEBOOK_ID_KEY] = _facebookID;
        person[LAST_NAME_KEY] = _lastName;
        person[TIMEZONE_KEY] = [NSNumber numberWithLong:_timezone];
        person[FACEBOOK_LINK_KEY] = _facebookLink;
        person[FULL_NAME_KEY] = _fullName;
        person[FIRST_NAME_KEY] = _firstName;
        
        // Keys we don't need when initially setting someone up: events, friends
        
        [person saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[NSNotificationCenter defaultCenter] postNotificationName:USER_CREATED_NOTIFICATION object:self];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:DELETE_USER_NOTIFICATION object:self];
                NSLog(@"ERRRRRRRROR!!!");
            }
        }];
    }];
}

@end
