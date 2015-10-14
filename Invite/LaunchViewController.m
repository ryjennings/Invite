//
//  LaunchViewController.m
//  Invite
//
//  Created by Ryan Jennings on 2/23/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "LaunchViewController.h"

#import "AppDelegate.h"
#import "Invite-Swift.h"
#import "LoginViewController.h"
#import "StringConstants.h"
#import "User.h"

@implementation LaunchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseLoaded:) name:PARSE_LOADED_NOTIFICATION object:nil];
    [self login];
}

- (void)login
{
    NSString *email = [UserDefaults objectForKey:EMAIL_KEY];
    
    if (email) {
        
        switch ([[AppDelegate app].reachability currentReachabilityStatus]) {
            case NotReachable:
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"The Internet connection appears to be offline. Please check your settings and try again." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                    [self login];
                }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
            default:
            {
                PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
                [query whereKey:EMAIL_KEY equalTo:email];
                [query includeKey:EVENTS_KEY];
                [query includeKey:FRIENDS_KEY];
                [query includeKey:LOCATIONS_KEY];
                [query includeKey:[NSString stringWithFormat:@"%@.%@", EVENTS_KEY, EVENT_LOCATION_KEY]];
                [query includeKey:[NSString stringWithFormat:@"%@.%@", EVENTS_KEY, EVENT_CREATOR_KEY]];
                [query includeKey:[NSString stringWithFormat:@"%@.%@", EVENTS_KEY, EVENT_INVITEES_KEY]];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    if (objects.count) {
                        [[AppDelegate user] loadParseUser:objects[0]];
                    } else {
                        LoginViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:LOGIN_VIEW_CONTROLLER];
                        controller.prepareForSegueFromLaunchViewController = YES;
                        [self performSelector:@selector(gotoLoginViewController:) withObject:controller afterDelay:0.5];
                    }
                }];
            }
        }
        
    } else {
        LoginViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:LOGIN_VIEW_CONTROLLER];
        controller.prepareForSegueFromLaunchViewController = YES;
        [self performSelector:@selector(gotoLoginViewController:) withObject:controller afterDelay:0.5];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)gotoDashboardViewController:(UIViewController *)controller
{
    LoginViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:LOGIN_VIEW_CONTROLLER];
    [self.navigationController setViewControllers:@[loginController, controller] animated:YES];
}

- (void)gotoLoginViewController:(UIViewController *)controller
{
    [self.navigationController pushViewController:controller animated:NO];
}

- (void)parseLoaded:(NSNotification *)notification
{
    DashboardViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:DASHBOARD_VIEW_CONTROLLER];
    [self performSelector:@selector(gotoDashboardViewController:) withObject:controller afterDelay:0.5];
}

@end
