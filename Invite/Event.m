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
@property (nonatomic, strong) NSManagedObject *core;
@property (nonatomic, strong) NSDate *date;

@end

@implementation Event

+ (Event *)createPrototype
{
    Event *proto = [[Event alloc] init];
    return proto;
}

+ (void)addInvitees:(NSString *)inviteesString toPrototype:(Event *)proto
{
    NSArray *components = [inviteesString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *invitees = [components componentsJoinedByString:@""];
    NSArray *addresses = [invitees componentsSeparatedByString:@","];
    
    PFObject *parseEvent = [PFObject objectWithClassName:CLASS_EVENT_KEY];
    parseEvent[EVENT_CREATOR_KEY] = [AppDelegate user].parse;
    
    for (NSString *address in addresses) {
        [parseEvent addObject:address forKey:EVENT_INVITEES_KEY];
    }
    
    [[AppDelegate parseUser] addObject:parseEvent forKey:EVENTS_KEY];
    [PFObject saveAllInBackground:@[parseEvent, [AppDelegate parseUser]]];
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
