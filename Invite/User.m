//
//  User.m
//  Invite
//
//  Created by Ryan Jennings on 2/12/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "User.h"

#import "AppDelegate.h"

@interface User ()

@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *locale;
@property (nonatomic, strong) NSString *facebookID;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, assign) long timezone;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *facebookLink;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *firstName;

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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // If the email is in NSUserDefaults, check for user in Core Data
    
    NSString *email = [appDelegate objectForKey:EmailKey];
    if (email) {
        NSManagedObject *user = [self fetchUserFromCoreDataWithEmail:email];
        if (!_userCreated && user) {
            
            // If email, assume Core Data and Parse user exist
            // Create local user from Core Data
            
            [self userFromCoreDataUser:user];
        }
        return YES;
    }
    return NO;
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
    
    _userCreated = YES;
}

- (void)createLocalCoreDataUserFromParseObject:(PFObject *)object
{
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
    PFObject *person = [PFObject objectWithClassName:ClassPersonKey];
    person[GenderKey] = _gender;
    person[LocaleKey] = _locale;
    person[FacebookIDKey] = _facebookID;
    person[LastNameKey] = _lastName;
    person[TimezoneKey] = [NSNumber numberWithLong:_timezone];
    person[EmailKey] = _email;
    person[FacebookLinkKey] = _facebookLink;
    person[FullNameKey] = _fullName;
    person[FirstNameKey] = _firstName;
    [person saveInBackground];
}

- (void)createCoreDataUser
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ClassPersonKey inManagedObjectContext:appDelegate.managedObjectContext];
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:appDelegate.managedObjectContext];
    
    [object setValue:_gender forKey:GenderKey];
    [object setValue:_locale forKey:LocaleKey];
    [object setValue:_facebookID forKey:FacebookIDKey];
    [object setValue:_lastName forKey:LastNameKey];
    [object setValue:[NSNumber numberWithLong:_timezone] forKey:TimezoneKey];
    [object setValue:_email forKey:EmailKey];
    [object setValue:_facebookLink forKey:FacebookLinkKey];
    [object setValue:_fullName forKey:FullNameKey];
    [object setValue:_firstName forKey:FirstNameKey];
    
    [appDelegate saveContext];
}

- (NSManagedObject *)fetchUserFromCoreDataWithEmail:(NSString *)email
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ClassPersonKey
                                              inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"email == %@", email]];
    
    NSError *error = nil;
    NSArray *result = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setObject:_email forKey:EmailKey];
}

@end
