//
//  Event.m
//  Invite
//
//  Created by Ryan Jennings on 2/13/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "Event.h"

#import "AppDelegate.h"
#import "StringConstants.h"

@interface Event ()

@property (nonatomic, strong) NSMutableArray *invitee;
@property (nonatomic, strong) NSMutableArray *email;
@property (nonatomic, strong) NSMutableArray *iEmails;

@property (nonatomic, strong) PFObject *event;
@end

@implementation Event

+ (Event *)createEvent
{
    Event *event = [[Event alloc] init];
    return event;
}

- (void)submitEvent
{
    // INVITEE - invitee selected from table above email field
    // EMAIL - invitee added to email field
    // PARSE - Person on Parse
    
    _email = [_emails mutableCopy];
    _invitee = [_invitees mutableCopy];
    
    _iEmails = [NSMutableArray array];
    
    [_invitees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_iEmails addObject:[((PFObject *)obj) objectForKey:EMAIL_KEY]];
    }];
        
    if (_emails.count) {
        PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
        [query whereKey:EMAIL_KEY containedIn:_emails];
        [query findObjectsInBackgroundWithBlock:^(NSArray *persons, NSError *error) {
            [self reallySubmitEventWithPersons:persons];
        }];
    } else {
        [self reallySubmitEventWithPersons:nil];
    }
}

- (void)reallySubmitEventWithPersons:(NSArray *)persons
{
    // PARSE who were listed in email field
    
    for (PFObject *person in persons) {
        
        if (![_iEmails containsObject:person[EMAIL_KEY]]) {
            
            // PARSE who is not currently INVITEE
            [_invitee addObject:person];
        }
        
        [_email removeObject:person[EMAIL_KEY]];
    }
    
    NSMutableArray *save = [NSMutableArray array];
    
    // Create a new Person for all emails left
    for (NSString *email in _email) {
        
        PFObject *person = [PFObject objectWithClassName:CLASS_PERSON_KEY];
        person[EMAIL_KEY] = email;
        [_invitee addObject:person];
        [save addObject:person];
        
    }
    
    _event = [PFObject objectWithClassName:CLASS_EVENT_KEY];
    _event[EVENT_CREATOR_KEY] = [AppDelegate parseUser];
    _event[EVENT_START_DATE_KEY] = _timeframe.start;
    _event[EVENT_END_DATE_KEY] = _timeframe.end;
    _event[EVENT_TITLE_KEY] = _title;
    _event[EVENT_DESCRIPTION_KEY] = _eventDescription;
    _event[EVENT_LOCATION_KEY] = _location;
    
//    if (_coverImage) {
//        NSData *coverData = UIImagePNGRepresentation(_coverImage);
//        PFFile *coverFile = [PFFile fileWithName:@"cover.png" data:coverData];
//        _event[EVENT_COVER_IMAGE_KEY] = coverFile;
//    }
    
    [save addObject:_event];
    
    [PFObject saveAllInBackground:save target:self selector:@selector(eventCreatedWithResult:error:)];
}

- (void)eventCreatedWithResult:(NSNumber *)result error:(NSError *)error
{
    if ([result boolValue]) { // success
        
        // By now the new event and all people who had to be created for this event have been created...
        [_event addUniqueObjectsFromArray:_invitee forKey:EVENT_INVITEES_KEY];
        
        // Iterate through _invitee and pull out emails so that searching for busy times is easier later...
        NSMutableDictionary *rsvp = [NSMutableDictionary dictionary];
        for (PFObject *invitee in _invitee) {
            NSString *email = [invitee objectForKey:EMAIL_KEY];
            if (email && email.length > 0) {
                [rsvp setValue:@(EventResponseNone) forKey:[AppDelegate keyFromEmail:email]];
            }
        }
        _event[EVENT_RSVP_KEY] = rsvp;
//        _emails = [AppDelegate emailsFromKeys:[rsvp allKeys]];
        
        for (PFObject *person in _invitee) {
            [self makeAdjustmentsToPerson:person event:_event];
        }
        
        [[AppDelegate parseUser] addUniqueObject:_event forKey:EVENTS_KEY];
        
        // Add to _invitee since we are done
        [_invitee addObject:_event];
        [_invitee addObject:[AppDelegate parseUser]];
        
        [PFObject saveAllInBackground:_invitee block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                if (![AppDelegate user].events) {
                    [AppDelegate user].events = [NSArray array];
                }
                NSMutableArray *events = [[AppDelegate user].events mutableCopy];
                [events addObject:_event];
                [AppDelegate user].events = events;
                
                [self sendPushNotification];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CREATED_NOTIFICATION object:self];
                
            } else {
                NSLog(@"ERRRRRRRROR!!!");
            }
        }];
    } else {
        NSLog(@"ERRRRRRRROR!!!");
    }
}

- (void)makeAdjustmentsToPerson:(PFObject *)person event:(PFObject *)event
{
    // Add event to invitee
    [person addUniqueObject:event forKey:EVENTS_KEY];
    
    // Add invitee to creator's (user's) friends
    [[AppDelegate parseUser] addUniqueObject:person forKey:FRIENDS_KEY];
    
    // Add location
    [[AppDelegate parseUser] addUniqueObject:_location forKey:EVENT_LOCATIONS_KEY];
    
    // Add person to local friends
    if (![AppDelegate user].friends) {
        [AppDelegate user].friends = [NSArray array];
    }
    NSMutableArray *friends = [[AppDelegate user].friends mutableCopy];
    [friends addObject:person];
    [AppDelegate user].friends = friends;
    
    // Add invitee's email to creator's (user's) friendEmails
    [[AppDelegate parseUser] addUniqueObject:[person objectForKey:EMAIL_KEY] forKey:FRIENDS_EMAILS_KEY];
    
    // Add person's email to local friendEmails
    if (![AppDelegate user].friendEmails) {
        [AppDelegate user].friendEmails = [NSArray array];
    }
    NSMutableArray *friendEmails = [[AppDelegate user].friendEmails mutableCopy];
    [friendEmails addObject:[person objectForKey:EMAIL_KEY]];
    [AppDelegate user].friendEmails = friendEmails;

    // Add creator (user) to invitee's friends
    [person addUniqueObject:[AppDelegate parseUser] forKey:FRIENDS_KEY];
    [person addUniqueObject:[AppDelegate user].email forKey:FRIENDS_EMAILS_KEY];
}

- (void)sendPushNotification
{
    NSMutableArray *emails = [NSMutableArray arrayWithArray:_inviteeEmails];
    [emails addObjectsFromArray:_emails];
    
    if (_inviteeEmails) {
        PFQuery *query = [PFInstallation query];
        [query whereKey:EMAIL_KEY containedIn:emails];
        
        // Send push notification to query
        [PFPush sendPushMessageToQueryInBackground:query
                                       withMessage:@"You've received a new event!"];
    }
}

@end
