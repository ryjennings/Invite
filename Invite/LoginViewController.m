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

@property (nonatomic, assign) BOOL receivedUser;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _receivedUser = NO;
    
    [self showFacebookLogin];
    
    self.navigationController.navigationItem.title = @"Select Invitees";
    
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userCreated:) name:USER_CREATED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteUser:) name:DELETE_USER_NOTIFICATION object:nil];
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

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)facebookUser
{
    // REMEBER: This method gets called twice for some reason...
    
    if (!_receivedUser) {

        _receivedUser = YES;

        PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
        [query whereKey:EMAIL_KEY equalTo:[facebookUser objectForKey:EMAIL_KEY]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *parseUser, NSError *error) {
            
            if (![parseUser objectForKey:FACEBOOK_ID_KEY]) {

                // User does not exist in Parse database...
                // Create Parse user
                
                [[AppDelegate user] createParseUserFromFacebookUser:facebookUser];
                
            } else {
                
                [[AppDelegate user] loadParseUser:parseUser];
                
            }
        }];
    }
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    [AppDelegate clearUser];
}

- (void)userCreated:(NSNotification *)notification
{
    [self pushDashboard];
}

- (void)deleteUser:(NSNotification *)notification
{
    [AppDelegate clearUser];
    [self showAlert];
}

- (void)showAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert_cannotlogin_title", nil) message:NSLocalizedString(@"alert_cannotlogin_message", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [FBSession.activeSession closeAndClearTokenInformation];
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
