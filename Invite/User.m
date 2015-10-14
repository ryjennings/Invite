//
//  User.m
//  Invite
//
//  Created by Ryan Jennings on 2/12/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "User.h"

#import "Event.h"
#import "Invite-Swift.h"
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
    [self findReservations];
    [self createMyReponses];
    [[NSNotificationCenter defaultCenter] postNotificationName:PARSE_LOADED_NOTIFICATION object:self];
}

- (void)createParseUserFromFacebookUser:(NSDictionary *)user
{
    [self createUserFromObject:user];
}

- (void)createUserFromObject:(id)object
{
    BOOL parseObject = [object isKindOfClass:[PFObject class]];
    
    _gender = [object objectForKey:GENDER_KEY];
    _locale = [object objectForKey:LOCALE_KEY];
    _lastName = [object objectForKey:LAST_NAME_KEY];
    _email = [object objectForKey:EMAIL_KEY];
    _firstName = [object objectForKey:FIRST_NAME_KEY];
    _facebookID = [object objectForKey:FACEBOOK_ID_KEY];
    _fullName = [object objectForKey:FULL_NAME_KEY];
    
    [CrashlyticsKit setUserIdentifier:_facebookID];
    [CrashlyticsKit setUserEmail:_email];
    [CrashlyticsKit setUserName:_fullName];
    
    if (!parseObject) {
        
        [self createParseUser];
        
    } else {
        
        _events = [User sortEvents:[object objectForKey:EVENTS_KEY]];
        
        if ([object objectForKey:FRIENDS_KEY]) {
            _friends = [object objectForKey:FRIENDS_KEY];
        } else {
            _friends = [[NSArray alloc] init];
        }
        
        if ([object objectForKey:FRIENDS_EMAILS_KEY]) {
            _friendEmails = [object objectForKey:FRIENDS_EMAILS_KEY];
        } else {
            _friendEmails = [[NSArray alloc] init];
        }
        
        if ([object objectForKey:LOCATIONS_KEY]) {
            _locations = [object objectForKey:LOCATIONS_KEY];
        } else {
            _locations = [[NSArray alloc] init];
        }
        _reservations = [[NSSet alloc] init];
    }
}

+ (NSArray *)sortEvents:(NSArray *)events
{
    return [events sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *e1start = [((PFObject *)obj1) objectForKey:EVENT_START_DATE_KEY];
        NSDate *e2start = [((PFObject *)obj2) objectForKey:EVENT_START_DATE_KEY];
        if ([[e1start earlierDate:e2start] isEqualToDate:e1start]) {
            return NSOrderedAscending;
        } else if ([[e1start earlierDate:e2start] isEqualToDate:e2start]) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
}

- (void)createParseUser
{
    // First, check to make sure a dummy user wasn't created with the same email address
    
    PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
    [query whereKey:EMAIL_KEY equalTo:_email];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        PFObject *person;
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        
        if (objects.count) {
            
            person = objects[0];
            
        } else {
            
            person = [PFObject objectWithClassName:CLASS_PERSON_KEY];
            person[EMAIL_KEY] = _email;
            
            currentInstallation[EMAIL_KEY] = _email;

        }
        
        _parse = person;
        
        person[GENDER_KEY] = _gender;
        person[LOCALE_KEY] = _locale;
        person[FACEBOOK_ID_KEY] = _facebookID;
        person[LAST_NAME_KEY] = _lastName;
        person[FULL_NAME_KEY] = _fullName;
        person[FIRST_NAME_KEY] = _firstName;
        
        _events = [[NSArray alloc] init];
        _friends = [[NSArray alloc] init];
        _friendEmails = [[NSArray alloc] init];
        _locations = [[NSArray alloc] init];
        _reservations = [[NSSet alloc] init];

        // Keys we don't need when initially setting someone up: events, friends
        
        [PFObject saveAllInBackground:@[person, currentInstallation] block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[NSNotificationCenter defaultCenter] postNotificationName:USER_CREATED_NOTIFICATION object:self];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:DELETE_USER_NOTIFICATION object:self];
                NSLog(@"ERRRRRRRROR!!!");
            }
        }];
    }];
}

- (void)addFacebookDetails:(NSDictionary *)details toParseUser:(PFObject *)parse
{
    parse[GENDER_KEY] = details[GENDER_KEY];
    parse[LOCALE_KEY] = details[LOCALE_KEY];
    parse[FACEBOOK_ID_KEY] = details[FACEBOOK_ID_KEY];
    parse[LAST_NAME_KEY] = details[LAST_NAME_KEY];
    parse[FULL_NAME_KEY] = details[FULL_NAME_KEY];
    parse[FIRST_NAME_KEY] = details[FIRST_NAME_KEY];
    [parse saveInBackground];
}

- (void)findReservations
{
    // Create "events" to fetch...
    NSMutableArray *eventsToFetch = [NSMutableArray array];
    for (PFObject *friend in _friends) {
        [eventsToFetch addObjectsFromArray:friend[EVENTS_KEY]];
    }

    if (eventsToFetch.count) {
        [PFObject fetchAllIfNeededInBackground:eventsToFetch block:^(NSArray *events, NSError *error) {
            
            NSMutableSet *reservations = [NSMutableSet set];

            for (PFObject *friend in _friends) {
                
                [friend[EVENTS_KEY] enumerateObjectsUsingBlock:^(PFObject *event, NSUInteger idx, BOOL *stop) {
                    
                    NSDictionary *rsvp = event[EVENT_RSVP_KEY];
                    NSString *email = friend[EMAIL_KEY];
                    EventResponse response = [rsvp[[AppDelegate keyFromEmail:email]] integerValue];
                    if (response == EventResponseGoing || response == EventResponseMaybe) {
                        [reservations addObject:[Reservation reservationWithUser:friend
                                                                      eventTitle:event[EVENT_TITLE_KEY]
                                                                   eventResponse:response
                                                                  eventStartDate:event[EVENT_START_DATE_KEY]
                                                                    eventEndDate:event[EVENT_END_DATE_KEY]]];
                    }
                }];
            }
            
            _reservations = reservations;
            
        }];
    }
}

- (void)createMyReponses
{
    if (_events) {
        NSMutableDictionary *myResponses = [NSMutableDictionary dictionary];
        for (PFObject *event in _events) {
            if ([((PFObject *)event[EVENT_CREATOR_KEY])[EMAIL_KEY] isEqualToString:[AppDelegate user].email]) {
                myResponses[event.objectId] = @(EventMyResponseHost);
            }
            NSDictionary *rsvp = event[EVENT_RSVP_KEY];
            for (NSString *key in rsvp) {
                NSString *email = [AppDelegate emailFromKey:key];
                if ([email isEqualToString:[AppDelegate user].email]) {
                    myResponses[event.objectId] = rsvp[key];
                }
            }
        }
        _myResponses = myResponses;
    }
}

@end
