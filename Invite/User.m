//
//  User.m
//  Invite
//
//  Created by Ryan Jennings on 2/12/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "User.h"

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

- (BOOL)checkForUser
{
    // If the email is in NSUserDefaults, check for user in Core Data
    
    NSString *email = [[AppDelegate app] objectForKey:EMAIL_KEY];
    if (email) {
        NSManagedObject *user = [self fetchUserFromCoreDataWithEmail:email];
        if (user) {
            
            // If email, assume Core Data and Parse exist
            // Create local user from Core Data, and get Parse object with email
            
            [self localUserFromCoreDataUser:user];
            [self parseObjectWithEmail:email];
            return YES;
        }
    }
    return NO;
}

- (void)parseObjectWithEmail:(NSString *)email
{
    PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
    [query whereKey:EMAIL_KEY equalTo:email];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (object) {
            _parse = object;
        }
        
    }];
}

- (void)localUserFromCoreDataUser:(NSManagedObject *)user
{
    _gender = [user valueForKey:GENDER_KEY];
    _locale = [user valueForKey:LOCALE_KEY];
    _facebookID = [user valueForKey:FACEBOOK_ID_KEY];
    _lastName = [user valueForKey:LAST_NAME_KEY];
    _timezone = [[user valueForKey:TIMEZONE_KEY] longValue];
    _email = [user valueForKey:EMAIL_KEY];
    _facebookLink = [user valueForKey:FACEBOOK_LINK_KEY];
    _fullName = [user valueForKey:FULL_NAME_KEY];
    _firstName = [user valueForKey:FIRST_NAME_KEY];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).user = self;
}

- (void)createLocalAndCoreUsersFromParseObject:(PFObject *)object
{
    _parse = object;
    
    _gender = [object objectForKey:GENDER_KEY];
    _locale = [object objectForKey:LOCALE_KEY];
    _facebookID = [object objectForKey:FACEBOOK_ID_KEY];
    _lastName = [object objectForKey:LAST_NAME_KEY];
    _timezone = (long)[object objectForKey:TIMEZONE_KEY];
    _email = [object objectForKey:EMAIL_KEY];
    _facebookLink = [object objectForKey:FACEBOOK_LINK_KEY];
    _fullName = [object objectForKey:FULL_NAME_KEY];
    _firstName = [object objectForKey:FIRST_NAME_KEY];

    // Add to Core Data
    [self createCoreDataUser];

    // Add email to NSUserDefaults
    [[AppDelegate app] setObject:_email forKey:EMAIL_KEY];
}

- (void)createAllUsersFromFacebookUser:(id<FBGraphUser>)user
{
    _gender = [user objectForKey:GENDER_KEY];
    _locale = [user objectForKey:LOCALE_KEY];
    _facebookID = [user objectForKey:ID_KEY];
    _lastName = [user objectForKey:LAST_NAME_KEY];
    _timezone = (long)[user objectForKey:TIMEZONE_KEY];
    _email = [user objectForKey:EMAIL_KEY];
    _facebookLink = [user objectForKey:LINK_KEY];
    _fullName = [user objectForKey:NAME_KEY];
    _firstName = [user objectForKey:FIRST_NAME_KEY];
    
    // Add to Parse
    [self createParseUser];
    
    // Add to Core Data
    [self createCoreDataUser];
    
    // Add email to NSUserDefaults
    [[AppDelegate app] setObject:_email forKey:EMAIL_KEY];
}

- (void)createParseUser
{
    PFObject *object = [PFObject objectWithClassName:CLASS_PERSON_KEY];
    
    _parse = object;
    
    object[GENDER_KEY] = _gender;
    object[LOCALE_KEY] = _locale;
    object[FACEBOOK_ID_KEY] = _facebookID;
    object[LAST_NAME_KEY] = _lastName;
    object[TIMEZONE_KEY] = [NSNumber numberWithLong:_timezone];
    object[EMAIL_KEY] = _email;
    object[FACEBOOK_LINK_KEY] = _facebookLink;
    object[FULL_NAME_KEY] = _fullName;
    object[FIRST_NAME_KEY] = _firstName;
    
    [object saveInBackground];
}

- (void)createCoreDataUser
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:CLASS_PERSON_KEY inManagedObjectContext:[[AppDelegate app] managedObjectContext]];
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:[[AppDelegate app] managedObjectContext]];
    
    _core = object;
    
    [object setValue:_gender forKey:GENDER_KEY];
    [object setValue:_locale forKey:LOCALE_KEY];
    [object setValue:_facebookID forKey:FACEBOOK_ID_KEY];
    [object setValue:_lastName forKey:LAST_NAME_KEY];
    [object setValue:[NSNumber numberWithLong:_timezone] forKey:TIMEZONE_KEY];
    [object setValue:_email forKey:EMAIL_KEY];
    [object setValue:_facebookLink forKey:FACEBOOK_LINK_KEY];
    [object setValue:_fullName forKey:FULL_NAME_KEY];
    [object setValue:_firstName forKey:FIRST_NAME_KEY];
    
    [[AppDelegate app] saveContext];
}

- (NSManagedObject *)fetchUserFromCoreDataWithEmail:(NSString *)email
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:CLASS_PERSON_KEY
                                              inManagedObjectContext:[[AppDelegate app] managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"email == %@", email]];
    
    NSError *error = nil;
    NSArray *result = [[[AppDelegate app] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (error) NSLog(@"%@, %@", error, error.localizedDescription);
    
    return result.count > 0 ? [result objectAtIndex:0] : nil;
}

- (void)checkForEvents
{
    PFQuery *query = [PFQuery queryWithClassName:CLASS_EVENT_KEY];
    [query whereKey:@"invitees" equalTo:_email];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            [_parse addObject:object forKey:EVENTS_KEY];
        }
        [_parse saveInBackground];
    }];
    
}

@end
