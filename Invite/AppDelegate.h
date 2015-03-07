//
//  AppDelegate.h
//  Invite
//
//  Created by Ryan Jennings on 2/9/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@class User;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) User *user;

+ (AppDelegate *)app;
+ (User *)user;
+ (PFObject *)parseUser;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (void)removeObjectForKey:(NSString *)key;
+ (void)setObject:(id)object forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

+ (void)clearUser;

+ (NSString *)keyFromEmail:(NSString *)email;
+ (NSString *)emailFromKey:(NSString *)key;
+ (NSArray *)emailsFromKeys:(NSArray *)keys;

@end
