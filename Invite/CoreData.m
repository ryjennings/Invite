//
//  CoreData.m
//  Invite
//
//  Created by Ryan Jennings on 2/12/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "CoreData.h"

#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

#import "AppDelegate.h"

@implementation CoreData

+ (void)createUserFromFacebookUser:(id<FBGraphUser>)user
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ClassPersonKey inManagedObjectContext:[[AppDelegate app] managedObjectContext]];
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:[[AppDelegate app] managedObjectContext]];

    [object setValue:[user objectForKey:GenderKey] forKey:GenderKey];
    [object setValue:[user objectForKey:LocaleKey] forKey:LocaleKey];
    [object setValue:[user objectForKey:IDKey] forKey:FacebookIDKey];
    [object setValue:[user objectForKey:LastNameKey] forKey:LastNameKey];
    [object setValue:[user objectForKey:TimezoneKey] forKey:TimezoneKey];
    [object setValue:[user objectForKey:EmailKey] forKey:EmailKey];
    [object setValue:[user objectForKey:LinkKey] forKey:FacebookLinkKey];
    [object setValue:[user objectForKey:NameKey] forKey:FullNameKey];
    [object setValue:[user objectForKey:FirstNameKey] forKey:FirstNameKey];

    [[AppDelegate app] saveContext];
}

@end
