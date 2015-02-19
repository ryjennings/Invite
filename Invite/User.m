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
    NSString *idKey = ID_KEY;
    NSString *linkKey = LINK_KEY;
    NSString *nameKey = NAME_KEY;
    BOOL includeParse = YES;
    
    if ([object isKindOfClass:[PFObject class]]) {
        idKey = FACEBOOK_ID_KEY;
        linkKey = FACEBOOK_LINK_KEY;
        nameKey = FULL_NAME_KEY;
        includeParse = NO;
    }
    
    _gender = [object objectForKey:GENDER_KEY];
    _locale = [object objectForKey:LOCALE_KEY];
    _lastName = [object objectForKey:LAST_NAME_KEY];
    _timezone = (long)[object objectForKey:TIMEZONE_KEY];
    _email = [object objectForKey:EMAIL_KEY];
    _firstName = [object objectForKey:FIRST_NAME_KEY];
    _events = [object objectForKey:EVENTS_KEY];

    _facebookID = [object objectForKey:idKey];
    _facebookLink = [object objectForKey:linkKey];
    _fullName = [object objectForKey:nameKey];

    if (includeParse) {
        
        [self createParseUser];
        
    }
}

- (void)createParseUser
{
    PFObject *object = [PFObject objectWithClassName:CLASS_PERSON_KEY];
    
    _parse = object;
    
    object[GENDER_KEY] = _gender;
    object[LOCALE_KEY] = _locale;
    object[FACEBOOK_ID_KEY] = _facebookID;
    object[LAST_NAME_KEY] = _lastName;
    object[TIMEZONE_KEY] = [NSNumber numberWithLong:_timezone];
    object[EMAIL_KEY] = _email;
    object[FACEBOOK_LINK_KEY] = _facebookLink;
    object[FULL_NAME_KEY] = _fullName;
    object[FIRST_NAME_KEY] = _firstName;
    
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_CREATED_NOTIFICATION object:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:DELETE_USER_NOTIFICATION object:self];
        }
    }];
}

#pragma mark - Events

- (void)checkForNewEventsWhereUserIsInvitee
{
    PFQuery *query = [PFQuery queryWithClassName:CLASS_EVENT_KEY];
    [query whereKey:EVENT_INVITEES_KEY equalTo:_email];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *event in objects) {
            
            // If user is invited to an event, and their email address was used, replace email with Person objectId
            NSMutableArray *invitees = [event objectForKey:EVENT_INVITEES_KEY];
            if ([invitees indexOfObject:_email]) {
                [invitees removeObject:_email];                
                [invitees addObject:[PFObject objectWithoutDataWithClassName:CLASS_PERSON_KEY objectId:_parse.objectId]];
                NSMutableArray *events = [NSMutableArray arrayWithArray:_events];
                [events addObject:event];
                _events = events;
            }
            
            // Add event to user's events
            [_parse addObject:event forKey:EVENTS_KEY];
            
            // Parse: save event and user
            [event saveInBackground];
        }
        [_parse saveInBackground];
    }];
    
}

@end
