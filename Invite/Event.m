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

@interface Event ()

@property (nonatomic, strong) PFObject *parseEvent;
@property (nonatomic, strong) NSDate *date;

@end

@implementation Event

+ (Event *)addEventToUser:(User *)user
{
    Event *event = [[Event alloc] init];
    event.date = [NSDate date];
    
    // Add to Parse
    PFObject *parseEvent = [PFObject objectWithClassName:ClassEventKey];
    event.parseEvent = parseEvent;
    parseEvent[EventDateKey] = event.date;
    [user.parse addObject:parseEvent forKey:EventsKey];
    [PFObject saveAllInBackground:@[parseEvent, user.parse]];
    
    // Add to Core Data
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ClassEventKey inManagedObjectContext:[[AppDelegate app] managedObjectContext]];
    NSManagedObject *coreEvent = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:[[AppDelegate app] managedObjectContext]];
    [coreEvent setValue:event.date forKey:EventDateKey];
    [[user.core mutableSetValueForKey:EventsKey] addObject:coreEvent];
    [[AppDelegate app] saveContext];

    return event;
}

@end
