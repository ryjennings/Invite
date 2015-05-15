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
#import "Invite-Swift.h"
#import "User.h"

#define kMessageStartingCenterY -133
#define kAmountToMoveUp 100

@interface LoginViewController () <FBLoginViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *logo;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *logoCenterYConstraint;
@property (nonatomic, weak) IBOutlet UIView *messageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *messageViewCenterYConstraint;
@property (nonatomic, weak) IBOutlet UIView *facebookView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *facebookViewBottomConstraint;
@property (nonatomic, weak) IBOutlet UILabel *inviteLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIView *lineView;

@property (nonatomic, strong) FBLoginView *loginView;

@property (nonatomic, assign) BOOL receivedUser;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _receivedUser = NO;
    
    _inviteLabel.font = [UIFont proximaNovaLightFontOfSize:36];
    _lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    _messageLabel.font = [UIFont proximaNovaRegularFontOfSize:16];
    _facebookView.backgroundColor = [UIColor inviteSlateButtonColor];

    [self showFacebookLogin];
        
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userCreated:) name:USER_CREATED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteUser:) name:DELETE_USER_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:APPLICATION_WILL_RESIGN_ACTIVE_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _messageView.alpha = 0;
    _messageViewCenterYConstraint.constant = kMessageStartingCenterY + 35;
    _facebookViewBottomConstraint.constant = -120;
    _logoCenterYConstraint.constant = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _loginView.delegate = self;

    _logoCenterYConstraint.constant = kAmountToMoveUp;
    [UIView animateWithDuration:1 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _messageViewCenterYConstraint.constant = kMessageStartingCenterY + kAmountToMoveUp;
        [UIView animateWithDuration:1 animations:^{
            _messageView.alpha = 1;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            _facebookViewBottomConstraint.constant = 0;
            [UIView animateWithDuration:1 delay:0.25 options:0 animations:^{
                [self.view layoutIfNeeded];
            } completion:nil];
        }];
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _receivedUser = NO;
    _loginView.delegate = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showDashboard
{
    DashboardViewController *controller = (DashboardViewController *)[self.storyboard instantiateViewControllerWithIdentifier:DASHBOARD_VIEW_CONTROLLER];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pushDashboard
{
    DashboardViewController *controller = (DashboardViewController *)[self.storyboard instantiateViewControllerWithIdentifier:DASHBOARD_VIEW_CONTROLLER];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showFacebookLogin
{
    _loginView = [[FBLoginView alloc] initWithReadPermissions:@[EMAIL_KEY]];
    _loginView.frame = CGRectMake(-500, -500, 0, 0);
    [self.view addSubview:_loginView];
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

        [UserDefaults setObject:[facebookUser objectForKey:EMAIL_KEY] key:EMAIL_KEY];

        PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
        [query whereKey:EMAIL_KEY equalTo:[facebookUser objectForKey:EMAIL_KEY]];
        [query includeKey:EVENTS_KEY];
        [query includeKey:FRIENDS_KEY];
        [query includeKey:LOCATIONS_KEY];
        [query includeKey:[NSString stringWithFormat:@"%@.%@", EVENTS_KEY, EVENT_LOCATION_KEY]];
        [query includeKey:[NSString stringWithFormat:@"%@.%@", EVENTS_KEY, EVENT_INVITEES_KEY]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (objects.count) {
                
                [[AppDelegate user] loadParseUser:objects[0]];
                [self performSelector:@selector(showDashboard) withObject:nil afterDelay:0.5];
                
            } else {

                // User does not exist in Parse database...
                // Create Parse user
                
                [[AppDelegate user] createParseUserFromFacebookUser:facebookUser];
                
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

- (IBAction)loginToFacebook:(id)sender
{
    switch ([[AppDelegate app].reachability currentReachabilityStatus]) {
        case NotReachable:
            [AlertViewController alert:@"The Internet connection appears to be offline." vc:self];
            return;
        default:
        {
            for (id object in self.loginView.subviews) {
                if ([[object class] isSubclassOfClass:[UIButton class]]) {
                    UIButton *button = (UIButton *)object;
                    [button sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
            break;
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    if (_receivedUser) {
        _messageView.alpha = 0;
        _messageViewCenterYConstraint.constant = kMessageStartingCenterY;
        _facebookViewBottomConstraint.constant = -120;
        _logoCenterYConstraint.constant = 0;
    }
}

@end
