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

@property (nonatomic, strong) NSMutableArray *actualInviteesToInvite;
@property (nonatomic, strong) NSMutableArray *actualEmailsToInvite;
@property (nonatomic, strong) NSMutableArray *inviteeEmails;
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
    _actualEmailsToInvite = [_emails mutableCopy];
    _actualInviteesToInvite = [_invitees mutableCopy];
    
    if (_emails.count) {
        
        // Check to see if any database user has email address
        
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
    _inviteeEmails = [NSMutableArray array];
    [_invitees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_inviteeEmails addObject:[((PFObject *)obj) objectForKey:EMAIL_KEY]];
    }];
    
    // If email address exists for any database user, move user from emails to invitees
    
    for (PFObject *person in persons) {
        
        if (![_inviteeEmails containsObject:person[EMAIL_KEY]]) {
            
            [_actualInviteesToInvite addObject:person];
            [_inviteeEmails addObject:[person objectForKey:EMAIL_KEY]];

        }
        
        [_actualEmailsToInvite removeObject:person[EMAIL_KEY]];
    }
    
    NSMutableArray *save = [NSMutableArray array];
    
    // Create a new Person for all emails left
    for (NSString *email in _actualEmailsToInvite) {
        
        PFObject *person = [PFObject objectWithClassName:CLASS_PERSON_KEY];
        person[EMAIL_KEY] = email;
        [_actualInviteesToInvite addObject:person];
        [save addObject:person];
        
    }
    
    _event = [PFObject objectWithClassName:CLASS_EVENT_KEY];
    _event[EVENT_CREATOR_KEY] = [AppDelegate parseUser];
    _event[EVENT_START_DATE_KEY] = _startDate;
    _event[EVENT_END_DATE_KEY] = _endDate;
    _event[EVENT_TITLE_KEY] = _title;
    _event[EVENT_DESCRIPTION_KEY] = _eventDescription;
    _event[EVENT_LOCATION_KEY] = _location;
    
    [save addObject:_event];
    
    [PFObject saveAllInBackground:save target:self selector:@selector(eventCreatedWithResult:error:)];
}

- (void)eventCreatedWithResult:(NSNumber *)result error:(NSError *)error
{
    if ([result boolValue]) { // success
        
        NSMutableArray *save = _actualInviteesToInvite;

        // By now the new event and all people who had to be created for this event have been created...
        [_event addUniqueObjectsFromArray:_actualInviteesToInvite forKey:EVENT_INVITEES_KEY];
        
        // Iterate through _invitee and pull out emails so that searching for busy times is easier later...
        NSMutableDictionary *rsvp = [NSMutableDictionary dictionary];
        for (PFObject *invitee in _actualInviteesToInvite) {
            NSString *email = [invitee objectForKey:EMAIL_KEY];
            if (email && email.length > 0) {
                [rsvp setValue:@(EventResponseNoResponse) forKey:[AppDelegate keyFromEmail:email]];
            }
        }
        _event[EVENT_RSVP_KEY] = rsvp;
        
        for (PFObject *person in _actualInviteesToInvite) {
            [self makeAdjustmentsToPerson:person event:_event];
        }
        
        [[AppDelegate parseUser] addUniqueObject:_event forKey:EVENTS_KEY];
        
        // Add to _invitee since we are done
        [save addObject:_event];
        [save addObject:[AppDelegate parseUser]];
        
        [PFObject saveAllInBackground:save block:^(BOOL succeeded, NSError *error) {
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
    if (_inviteeEmails) {
        PFQuery *query = [PFInstallation query];
        [query whereKey:EMAIL_KEY containedIn:_inviteeEmails];
        
        // Send push notification to query
        [PFPush sendPushMessageToQueryInBackground:query
                                       withMessage:@"You've received a new event!"];
    }
}

@end

//    if (_coverImage) {
//        NSData *coverData = UIImagePNGRepresentation(_coverImage);
//        PFFile *coverFile = [PFFile fileWithName:@"cover.png" data:coverData];
//        _event[EVENT_COVER_IMAGE_KEY] = coverFile;
//    }
