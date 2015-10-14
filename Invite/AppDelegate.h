//
//  AppDelegate.h
//  Invite
//
//  Created by Ryan Jennings on 2/9/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>

#import "Reachability.h"

@class User;
@class Event;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Reachability *reachability;

+ (AppDelegate *)app;
+ (User *)user;
+ (PFObject *)parseUser;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (void)clearUser;

+ (NSString *)keyFromEmail:(NSString *)email;
+ (NSString *)emailFromKey:(NSString *)key;
+ (NSArray *)emailsFromKeys:(NSArray *)keys;

@end
