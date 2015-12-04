//
//  AppDelegate.m
//  Invite
//
//  Created by Ryan Jennings on 2/9/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <TwitterKit/TwitterKit.h>
#import <MoPub/MoPub.h>

#import "Invite-Swift.h"
#import "StringConstants.h"
#import "User.h"
#import "Event.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    [[Crashlytics sharedInstance] setDebugMode:YES];
    [Fabric with:@[[Crashlytics class], [Twitter class], [MoPub class]]];

    [Parse setApplicationId:@"bDCtNhAgLH0h8TClwos5BxTLJ9q2gIs19uG8dSjD"
                  clientKey:@"XRnFQGL8mad8vS1iVt1JDxT1UPInSsffw0JLDOWK"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Logs 'install' and 'app activate' App Events.
    [FBSDKAppEvents activateApp];
    
    // Register for notifications
    UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:[NSSet setWithObject:[self notificationCategories]]];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    [InviteTheme customizeAppAppearance];
        
    _reachability = [Reachability reachabilityForInternetConnection];
    [_reachability startNotifier];

    [UIApplication sharedApplication].delegate.window.backgroundColor = [UIColor inviteSlateColor];
    
    return YES;
}

- (UIUserNotificationCategory *)notificationCategories
{
    UIMutableUserNotificationAction *viewAction = [[UIMutableUserNotificationAction alloc] init];
    viewAction.identifier = @"ViewAction";
    viewAction.destructive = NO;
    viewAction.title = @"View";
    viewAction.activationMode = UIUserNotificationActivationModeForeground;
    viewAction.authenticationRequired = NO;
    
    UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
    category.identifier = @"InviteCategory";
    [category setActions:@[viewAction] forContext:UIUserNotificationActionContextDefault];
    
    return category;
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"ViewAction"]) {
        self.deeplinkObjectId = userInfo[@"objectId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:DEEPLINK_NOTIFICATION object:nil];
    }
    if (completionHandler) {
        completionHandler();
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler
{
    if ([identifier isEqualToString:@"ViewAction"]) {
        self.deeplinkObjectId = notification.userInfo[@"objectId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:DEEPLINK_NOTIFICATION object:nil];
    }
    if (completionHandler) {
        completionHandler();
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (notification.userInfo[@"objectId"]) {
        self.deeplinkObjectId = notification.userInfo[@"objectId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:DEEPLINK_NOTIFICATION object:nil];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:APPLICATION_WILL_RESIGN_ACTIVE_NOTIFICATION object:self];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([url.absoluteString containsString:@"invite"]) {
        NSArray *com = [url.absoluteString componentsSeparatedByString:@"/"];
        self.deeplinkObjectId = com[2];
        [[NSNotificationCenter defaultCenter] postNotificationName:DEEPLINK_NOTIFICATION object:nil];
        return YES;
    }
    
    // attempt to extract a token from the url
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

#pragma mark - User

+ (void)clearUser
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.user = nil;
    [UserDefaults removeObjectForKey:EMAIL_KEY];
}

+ (AppDelegate *)app
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (User *)user
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.user) {
        delegate.user = [User shared];
    }
    return delegate.user;
}

+ (PFObject *)parseUser
{
    return ((AppDelegate *)[[UIApplication sharedApplication] delegate]).user.parse;
}

#pragma mark - Helpers

+ (NSString *)keyFromEmail:(NSString *)email
{
    return [email stringByReplacingOccurrencesOfString:@"." withString:@":"];
}

+ (NSString *)emailFromKey:(NSString *)key
{
    return [key stringByReplacingOccurrencesOfString:@":" withString:@"."];
}

+ (NSArray *)emailsFromKeys:(NSArray *)keys
{
    NSMutableArray *emails = [NSMutableArray array];
    for (NSString *key in keys) {
        [emails addObject:[key stringByReplacingOccurrencesOfString:@":" withString:@"."]];
    }
    return emails;
}

@end
