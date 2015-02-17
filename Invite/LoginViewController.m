//
//  LoginViewController.m
//  Invite
//
//  Created by Ryan Jennings on 2/9/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "LoginViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

#import "AppDelegate.h"
#import "DashboardViewController.h"
#import "StringConstants.h"
#import "User.h"

@interface LoginViewController () <FBLoginViewDelegate>

@property (nonatomic, assign) BOOL userExists;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[User shared] checkForUser]) {
        
        [self showDashboard];
        
    } else {
        
        [self showFacebookLogin];
        
    }
}

- (void)showDashboard
{
    DashboardViewController *controller = (DashboardViewController *)[self.storyboard instantiateViewControllerWithIdentifier:DASHBOARD_VIEW_CONTROLLER];
    self.navigationController.viewControllers = @[controller];
}

- (void)pushDashboard
{
    DashboardViewController *controller = (DashboardViewController *)[self.storyboard instantiateViewControllerWithIdentifier:DASHBOARD_VIEW_CONTROLLER];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showFacebookLogin
{
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[EMAIL_KEY]];
    loginView.center = self.view.center;
    loginView.delegate = self;
    [self.view addSubview:loginView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Facebook

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    NSString *email = [user objectForKey:EMAIL_KEY];
    
    PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
    [query whereKey:EMAIL_KEY equalTo:email];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (![[AppDelegate app] objectForKey:EMAIL_KEY]) {

            if (!object) {

                // User does not exist in Parse database...
                // Create local, Core Data and Parse users
                
                [[AppDelegate user] createAllUsersFromFacebookUser:user];
                
            } else {
                
                // User found in Parse database...
                // Create local and Core Data users
                
                [[AppDelegate user] createLocalAndCoreUsersFromParseObject:object];
                
            }
            
            [[AppDelegate user] checkForEvents];
            
            [self pushDashboard];
            
        }
    }];
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    [[AppDelegate app] clearUser];
}

@end
