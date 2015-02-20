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

@property (nonatomic, strong) PFObject *parse;

@end

@implementation Event

+ (Event *)createEvent
{
    Event *event = [[Event alloc] init];
    return event;
}

- (void)createEventWithEmailAddresses:(NSArray *)emailAddresses
{
    NSMutableArray *mutable = [emailAddresses mutableCopy];

    // First, make sure an email address does not match an existing Invite user, if so remove address from invitees

    PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
    [query whereKey:EMAIL_KEY containedIn:emailAddresses];
    
    // Return all Persons who are also invitees
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *persons, NSError *error) {
        
        NSMutableArray *objectsToSave = [NSMutableArray array];

        // 1. Create new event
        
        PFObject *event = [PFObject objectWithClassName:CLASS_EVENT_KEY];
        event[EVENT_CREATOR_KEY] = [AppDelegate parseUser];
        [objectsToSave addObject:event];
        
        // 2. Weed out email addresses who are already Persons

        for (PFObject *person in persons) {
            NSString *email = [person objectForKey:EMAIL_KEY];
            if ([mutable containsObject:email]) {
                [mutable removeObject:email];
            }
            // Add person to event invitees
            [event addObject:person forKey:EVENT_INVITEES_KEY];
        }
        
        // 3. Create a new Person for each remaining email
        
        for (NSString *emailAddress in emailAddresses) {
            PFObject *person = [PFObject objectWithClassName:CLASS_PERSON_KEY];
            person[EMAIL_KEY] = emailAddress;
            [objectsToSave addObject:person];

            // Add person to event invitees
            [event addObject:person forKey:EVENT_INVITEES_KEY];
            
            // Add person to user's friends
            [[AppDelegate parseUser] addObject:person forKey:FRIENDS_KEY];
        }
        
        [[AppDelegate parseUser] addObject:event forKey:EVENTS_KEY];
        [objectsToSave addObject:[AppDelegate parseUser]];
        
        [PFObject saveAllInBackground:objectsToSave];
        
    }];
}

/*
+ (Event *)createEvent
{
    Event *event = [[Event alloc] init];
    event.date = [NSDate date];
    
    // Add to Parse
    PFObject *parseEvent = [PFObject objectWithClassName:ClassEventKey];
    event.parse = parseEvent;
    parseEvent[EventDateKey] = event.date;
    [parseEvent addObject:[AppDelegate app].inviteUser.parse forKey:EventPersonsKey];
    [[AppDelegate app].inviteUser.parse addObject:parseEvent forKey:EventsKey];
    [PFObject saveAllInBackground:@[parseEvent, [AppDelegate app].inviteUser.parse]];
    
    // Add to Core Data
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ClassEventKey inManagedObjectContext:[[AppDelegate app] managedObjectContext]];
    NSManagedObject *coreEvent = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:[[AppDelegate app] managedObjectContext]];
    event.core = coreEvent;
    [coreEvent setValue:event.date forKey:EventDateKey];
    [[[AppDelegate app].inviteUser.core mutableSetValueForKey:EventsKey] addObject:coreEvent];
    [[AppDelegate app] saveContext];

    return event;
}
 */

@end
