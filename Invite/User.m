//
//  User.m
//  Invite
//
//  Created by Ryan Jennings on 2/12/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "User.h"

#import "Event.h"

@interface User ()

@property (nonatomic, assign) BOOL userCreated;

@end

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userCreated = NO;
    }
    return self;
}

- (BOOL)checkForUser
{
    // If the email is in NSUserDefaults, check for user in Core Data
    
    NSString *email = [[AppDelegate app] objectForKey:EmailKey];
    if (email) {
        NSManagedObject *user = [self fetchUserFromCoreDataWithEmail:email];
        if (!_userCreated && user) {
            
            // If email, assume Core Data and Parse user exist
            // Create local user from Core Data
            
            [self userFromCoreDataUser:user];
            [self grabParseObjectForEmail:email];
        }
        return YES;
    }
    return NO;
}

- (void)grabParseObjectForEmail:(NSString *)email
{
    PFQuery *query = [PFQuery queryWithClassName:ClassPersonKey];
    [query whereKey:EmailKey equalTo:email];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (object) {
            _parse = object;
        }
        
    }];
}

- (void)userFromCoreDataUser:(NSManagedObject *)user
{
    _gender = [user valueForKey:GenderKey];
    _locale = [user valueForKey:LocaleKey];
    _facebookID = [user valueForKey:FacebookIDKey];
    _lastName = [user valueForKey:LastNameKey];
    _timezone = [[user valueForKey:TimezoneKey] longValue];
    _email = [user valueForKey:EmailKey];
    _facebookLink = [user valueForKey:FacebookIDKey];
    _fullName = [user valueForKey:FullNameKey];
    _firstName = [user valueForKey:FirstNameKey];
    
    [AppDelegate app].inviteUser = self;
//    _parse = [PFObject objectWithoutDataWithObjectId:[user valueForKey:ParseObjectIDKey]];
    
    _userCreated = YES;
}

- (void)createLocalCoreDataUserFromParseObject:(PFObject *)object
{
    _parse = object;
    _gender = [object objectForKey:GenderKey];
    _locale = [object objectForKey:LocaleKey];
    _facebookID = [object objectForKey:FacebookIDKey];
    _lastName = [object objectForKey:LastNameKey];
    _timezone = (long)[object objectForKey:TimezoneKey];
    _email = [object objectForKey:EmailKey];
    _facebookLink = [object objectForKey:FacebookLinkKey];
    _fullName = [object objectForKey:FullNameKey];
    _firstName = [object objectForKey:FirstNameKey];

    // Add to Core Data
    [self createCoreDataUser];

    // Add email to NSUserDefaults
    [self addEmailToDefaults];

    _userCreated = YES;
}

- (void)createLocalParseCoreDataUserFromFacebookUser:(id<FBGraphUser>)user
{
    // Set local properties
    
    _gender = [user objectForKey:GenderKey];
    _locale = [user objectForKey:LocaleKey];
    _facebookID = [user objectForKey:IDKey];
    _lastName = [user objectForKey:LastNameKey];
    _timezone = (long)[user objectForKey:TimezoneKey];
    _email = [user objectForKey:EmailKey];
    _facebookLink = [user objectForKey:LinkKey];
    _fullName = [user objectForKey:NameKey];
    _firstName = [user objectForKey:FirstNameKey];
    
    // Add to Parse
    [self createParseUser];
    
    // Add to Core Data
    [self createCoreDataUser];
    
    // Add email to NSUserDefaults
    [self addEmailToDefaults];

    _userCreated = YES;
}

- (void)createParseUser
{
    PFObject *object = [PFObject objectWithClassName:ClassPersonKey];
    
    _parse = object;
    
    object[GenderKey] = _gender;
    object[LocaleKey] = _locale;
    object[FacebookIDKey] = _facebookID;
    object[LastNameKey] = _lastName;
    object[TimezoneKey] = [NSNumber numberWithLong:_timezone];
    object[EmailKey] = _email;
    object[FacebookLinkKey] = _facebookLink;
    object[FullNameKey] = _fullName;
    object[FirstNameKey] = _firstName;
    
    [object saveInBackground];
}

- (void)createCoreDataUser
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ClassPersonKey inManagedObjectContext:[[AppDelegate app] managedObjectContext]];
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:[[AppDelegate app] managedObjectContext]];
    
    _core = object;
    
    [object setValue:_gender forKey:GenderKey];
    [object setValue:_locale forKey:LocaleKey];
    [object setValue:_facebookID forKey:FacebookIDKey];
    [object setValue:_lastName forKey:LastNameKey];
    [object setValue:[NSNumber numberWithLong:_timezone] forKey:TimezoneKey];
    [object setValue:_email forKey:EmailKey];
    [object setValue:_facebookLink forKey:FacebookLinkKey];
    [object setValue:_fullName forKey:FullNameKey];
    [object setValue:_firstName forKey:FirstNameKey];
    [object setValue:_parse.objectId forKey:ParseObjectIDKey];
    
    [[AppDelegate app] saveContext];
}

- (NSManagedObject *)fetchUserFromCoreDataWithEmail:(NSString *)email
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ClassPersonKey
                                              inManagedObjectContext:[[AppDelegate app] managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"email == %@", email]];
    
    NSError *error = nil;
    NSArray *result = [[[AppDelegate app] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        NSLog(@"%@", result);
    }
    
    if (result.count > 0) {
        return [result objectAtIndex:0];
    } else {
        return nil;
    }
}

- (void)addEmailToDefaults
{
    [[AppDelegate app] setObject:_email forKey:EmailKey];
}

//- (NSManagedObject *)core
//{
//    if (!_core) {
//        _core = [self fetchUserFromCoreDataWithEmail:_email];
//    }
//    return _core;
//}

@end
