//
//  Event.m
//  Invite
//
//  Created by Ryan Jennings on 2/13/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "Event.h"

#import "AppDelegate.h"

NSString *const EventDateKey = @"date";
NSString *const EventPersonsKey = @"persons";

@interface Event ()

@property (nonatomic, strong) PFObject *parse;
@property (nonatomic, strong) NSManagedObject *core;
@property (nonatomic, strong) NSDate *date;

@end

@implementation Event

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

@end
