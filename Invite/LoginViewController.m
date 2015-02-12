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
#import "CoreData.h"
#import "DashboardViewController.h"
#import "User.h"

NSString *const Dashboard = @"DashboardViewController";

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
    DashboardViewController *controller = (DashboardViewController *)[self.storyboard instantiateViewControllerWithIdentifier:Dashboard];
    self.navigationController.viewControllers = @[controller];
}

- (void)pushDashboard
{
    DashboardViewController *controller = (DashboardViewController *)[self.storyboard instantiateViewControllerWithIdentifier:Dashboard];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showFacebookLogin
{
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[EmailKey]];
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
    NSString *email = [user objectForKey:EmailKey];
    
    PFQuery *query = [PFQuery queryWithClassName:ClassPersonKey];
    [query whereKey:EmailKey equalTo:email];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
              
        if (![appDelegate objectForKey:EmailKey]) {

            appDelegate.user = [User shared];

            if (!object) {

                // User does not exist in Parse database...
                // Create local, Core Data and Parse users
                
                [appDelegate.user createLocalParseCoreDataUserFromFacebookUser:user];
                
            } else {
                
                // User found in Parse database...
                // Create local and Core Data users
                
                [appDelegate.user createLocalCoreDataUserFromParseObject:object];
                
            }

            [self pushDashboard];
            
        }
    }];
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate removeObjectForKey:EmailKey];
}

@end
