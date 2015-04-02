//
//  LaunchViewController.m
//  Invite
//
//  Created by Ryan Jennings on 2/23/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "LaunchViewController.h"

#import "AppDelegate.h"
#import "DashboardViewController.h"
#import "LoginViewController.h"
#import "StringConstants.h"
#import "User.h"

@implementation LaunchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    NSString *email = [AppDelegate objectForKey:EMAIL_KEY];
    
    if (email) {
        
        PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
        [query whereKey:EMAIL_KEY equalTo:email];
        [query includeKey:EVENTS_KEY];
        [query includeKey:FRIENDS_KEY];
        [query includeKey:LOCATIONS_KEY];
        [query includeKey:[NSString stringWithFormat:@"%@.%@", EVENTS_KEY, EVENT_LOCATION_KEY]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (objects.count) {
                [[AppDelegate user] loadParseUser:objects[0]];
            }
        }];

        DashboardViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:DASHBOARD_VIEW_CONTROLLER];
        [self performSelector:@selector(gotoViewController:) withObject:controller afterDelay:0.5];
        
    } else {
        LoginViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:LOGIN_VIEW_CONTROLLER];
        [self performSelector:@selector(gotoViewController:) withObject:controller afterDelay:0.5];
    }
}

- (void)gotoViewController:(UIViewController *)controller
{
    [self.navigationController setViewControllers:@[controller] animated:YES];
}

@end
