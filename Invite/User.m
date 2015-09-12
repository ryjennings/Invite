//
//  User.m
//  Invite
//
//  Created by Ryan Jennings on 2/12/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "User.h"

#import "BusyDetails.h"
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
    [self findBusyTimes];
    [[NSNotificationCenter defaultCenter] postNotificationName:PARSE_LOADED_NOTIFICATION object:self];
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
    _email = [object objectForKey:EMAIL_KEY];
    _firstName = [object objectForKey:FIRST_NAME_KEY];

    _facebookID = [object objectForKey:parseObject ? FACEBOOK_ID_KEY : ID_KEY];
    _facebookLink = [object objectForKey:parseObject ? FACEBOOK_LINK_KEY : LINK_KEY];
    _fullName = [object objectForKey:parseObject ? FULL_NAME_KEY : NAME_KEY];

    if (!parseObject) {
        
        [self createParseUser];
        
    } else {
        
        // Delete old events
        NSMutableArray *mEvents = [[object objectForKey:EVENTS_KEY] mutableCopy];
        NSMutableArray *eventsToRemove = [NSMutableArray array];
        NSDate *date = [NSDate date];
        BOOL save = NO;
        for (PFObject *event in mEvents) {
            NSDate *endDate = [event objectForKey:EVENT_END_DATE_KEY];
            if ([[endDate earlierDate:date] isEqualToDate:endDate]) {
                [_parse removeObject:event forKey:EVENTS_KEY];
//                [mEvents removeObject:event];
                [eventsToRemove addObject:event];
                save = YES;
            }
        }
        [mEvents removeObjectsInArray:eventsToRemove];
        if (save) {
            [_parse saveInBackground];
        }
        _events = [mEvents sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDate *e1start = [((PFObject *)obj1) objectForKey:EVENT_START_DATE_KEY];
            NSDate *e2start = [((PFObject *)obj2) objectForKey:EVENT_START_DATE_KEY];
            if ([[e1start earlierDate:e2start] isEqualToDate:e1start]) {
                return NSOrderedAscending;
            } else if ([[e1start earlierDate:e2start] isEqualToDate:e2start]) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        
        _friends = [object objectForKey:FRIENDS_KEY];
        _friendEmails = [object objectForKey:FRIENDS_EMAILS_KEY];
        _locations = [object objectForKey:LOCATIONS_KEY];
        
    }
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
        person[FACEBOOK_LINK_KEY] = _facebookLink;
        person[FULL_NAME_KEY] = _fullName;
        person[FIRST_NAME_KEY] = _firstName;
        
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

- (void)findBusyTimes
{
    // Only check for busy times if the user has friends
    if (_friends) {
        
        NSMutableSet *busyTimes = [NSMutableSet set];
        
        // Create "events" to fetch...
        NSMutableArray *fetchEvents = [NSMutableArray array];
        for (PFObject *friend in _friends) {
            [fetchEvents addObjectsFromArray:[friend objectForKey:EVENTS_KEY]];
        }

        [PFObject fetchAllIfNeededInBackground:fetchEvents block:^(NSArray *events, NSError *error) {
            
            NSMutableDictionary *eventsThatFriendsAreAttending = [NSMutableDictionary dictionary];
            // eventsThatFriendsAreAttending = { "eventObjectId" = [friend, friend], etc }
            for (PFObject *friend in _friends) {
                for (PFObject *event in [friend objectForKey:EVENTS_KEY]) {
                    if (eventsThatFriendsAreAttending[event.objectId]) {
                        [eventsThatFriendsAreAttending[event.objectId] addObject:friend];
                    } else {
                        eventsThatFriendsAreAttending[event.objectId] = [NSMutableArray arrayWithObject:friend];
                    }
                }
            }

            for (PFObject *event in events) {
                
                NSDate *start = [event objectForKey:EVENT_START_DATE_KEY];
                NSDate *end = [event objectForKey:EVENT_END_DATE_KEY];
                
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *startComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:start];
                startComponents.hour = 0;
                NSDateComponents *endComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:end];
                endComponents.hour = 0;
                
                NSDate *startBaseDate = [calendar dateFromComponents:startComponents];
                NSDate *endBaseDate = [calendar dateFromComponents:endComponents];
                
                [eventsThatFriendsAreAttending[event.objectId] enumerateObjectsUsingBlock:^(PFObject *friend, NSUInteger idx, BOOL *stop) {
                    
                    NSDictionary *rsvp = [event objectForKey:EVENT_RSVP_KEY];
                    NSString *email = [friend objectForKey:EMAIL_KEY];
                    EventResponse response = [rsvp[[AppDelegate keyFromEmail:email]] integerValue];
#warning Uncomment conditional
//                    if (response == EventResponseGoing || response == EventResponseMaybe) {
                        [busyTimes addObject:[BusyDetails busyDetailsWithName:[friend objectForKey:FULL_NAME_KEY]
                                                                        email:email
                                                                   eventTitle:[event objectForKey:EVENT_TITLE_KEY]
                                                                eventResponse:response
                                                                        start:start
                                                                startBaseDate:startBaseDate
                                                                          end:end
                                                                  endBaseDate:endBaseDate]];
//                    }
                }];
            }
            
            _busyTimes = busyTimes;
            
        }];
    }
}

@end
