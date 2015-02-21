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
    // CREATE ALL NEW OBJECTS FIRST, THEN SAVE TO EXISTING OBJECTS

    // INVITEE - invitee selected from table above email field
    // EMAIL - invitee added to email field
    // PARSE - Person on Parse
    
    _email = [_emails mutableCopy];
    _invitee = [[_invitees allObjects] mutableCopy];
    
    NSMutableArray *inviteeEmails = [NSMutableArray array];
    [_invitees enumerateObjectsUsingBlock:^(PFObject *invitee, BOOL *stop) {
        [inviteeEmails addObject:[invitee objectForKey:EMAIL_KEY]];
    }];
    
    PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
    [query whereKey:EMAIL_KEY containedIn:_emails];
    [query findObjectsInBackgroundWithBlock:^(NSArray *persons, NSError *error) {
        
        // PARSE who were listed in email field
        
        for (PFObject *person in persons) {
            
            if (![inviteeEmails containsObject:person[EMAIL_KEY]]) {
                
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
        _event[EVENT_STARTDATE_KEY] = _timeframe.start;
        _event[EVENT_ENDDATE_KEY] = _timeframe.end;
        [save addObject:_event];

        [PFObject saveAllInBackground:save target:self selector:@selector(eventCreated)];
    }];
}
     
- (void)eventCreated
{
    // By now the new event and all people who had to be created for this event have been created...
    [_event addUniqueObjectsFromArray:_invitee forKey:EVENT_INVITEES_KEY];
    for (PFObject *person in _invitee) {
        [self makeAdjustmentsToPerson:person event:_event];
    }
    [[AppDelegate parseUser] addUniqueObject:_event forKey:EVENTS_KEY];
    
    // Add to _invitee since we are done
    [_invitee addObject:_event];
    [_invitee addObject:[AppDelegate parseUser]];
    
    [PFObject saveAllInBackground:_invitee block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CREATED_NOTIFICATION object:self];
        } else {
            NSLog(@"ERRRRRRRROR!!!");
        }
    }];
}

- (void)makeAdjustmentsToPerson:(PFObject *)person event:(PFObject *)event
{
    // Add event to invitee
    [person addUniqueObject:event forKey:EVENTS_KEY];
    
    // Add invitee to creator's (user's) friends
    [[AppDelegate parseUser] addUniqueObject:person forKey:FRIENDS_KEY];
    
    // Add creator (user) to invitee's friends
    [person addUniqueObject:[AppDelegate parseUser] forKey:FRIENDS_KEY];
    
}

@end
