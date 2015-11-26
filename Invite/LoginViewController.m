//
//  LoginViewController.m
//  Invite
//
//  Created by Ryan Jennings on 2/9/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "LoginViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>
#import <TwitterKit/TwitterKit.h>

#import "AppDelegate.h"
#import "StringConstants.h"
#import "Invite-Swift.h"
#import "User.h"

#define kMessageStartingCenterY -133
#define kAmountToMoveUp 100

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface LoginViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *logo;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *logoCenterYConstraint;
@property (nonatomic, weak) IBOutlet UIView *messageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *messageViewCenterYConstraint;
@property (nonatomic, weak) IBOutlet UILabel *inviteLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIView *lineView;

@property (nonatomic, weak) IBOutlet UIView *buttonView;
@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
@property (nonatomic, weak) IBOutlet UIView *twitterView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, assign) BOOL sentToFacebookLogin;

@property (nonatomic, strong) UIDynamicAnimator *animator;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _inviteLabel.font = [UIFont proximaNovaLightFontOfSize:36];
    _lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    _messageLabel.font = [UIFont proximaNovaRegularFontOfSize:16];
    
    _sentToFacebookLogin = NO;
    _spinner.hidden = YES;
    
    TWTRLogInButton *logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            // Callback for login success or failure. The TWTRSession
            // is also available on the [Twitter sharedInstance]
            // singleton.
            //
            // Here we pop an alert just to give an example of how
            // to read Twitter user info out of a TWTRSession.
            //
            // TODO: Remove alert and use the TWTRSession's userID
            // with your app's user model
            NSString *message = [NSString stringWithFormat:@"@%@ logged in! (%@)",
                                 [session userName], [session userID]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged in!"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            NSLog(@"Login error: %@", [error localizedDescription]);
        }
    }];
    
    _twitterView.backgroundColor = [UIColor clearColor];
    _twitterView.clipsToBounds = YES;
    logInButton.frame = CGRectMake(0, 0, 60, 300);
    [logInButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    [logInButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"twitter"]]];
    [logInButton setBackgroundImage:[UIImage new] forState:UIControlStateHighlighted];
    [logInButton setBackgroundImage:[UIImage new] forState:UIControlStateSelected];
    [logInButton setBackgroundImage:[UIImage new] forState:UIControlStateDisabled];
    [_twitterView addSubview:logInButton];
    
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userCreated:) name:USER_CREATED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteUser:) name:DELETE_USER_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut:) name:USER_LOGGED_OUT_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _messageView.alpha = 0;
    _facebookButton.alpha = 0;
    _twitterView.alpha = 0;
    _messageViewCenterYConstraint.constant = kMessageStartingCenterY + 35;
    _logoCenterYConstraint.constant = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_sentToFacebookLogin) {
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

                self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:_buttonView];
                
                UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[_facebookButton, _twitterView]];
                
                UICollisionBehavior *ballCollision = [[UICollisionBehavior alloc] initWithItems:@[_facebookButton, _twitterView]];
                [ballCollision setTranslatesReferenceBoundsIntoBoundary:YES];
                
                UIPushBehavior *facebookPush = [[UIPushBehavior alloc] initWithItems:@[_facebookButton] mode:UIPushBehaviorModeInstantaneous];
                [facebookPush setAngle:DEGREES_TO_RADIANS(90)];
                [facebookPush setMagnitude:0.5];
                
                UIPushBehavior *twitterPush = [[UIPushBehavior alloc] initWithItems:@[_facebookButton] mode:UIPushBehaviorModeInstantaneous];
                [twitterPush setAngle:DEGREES_TO_RADIANS(90)];
                [twitterPush setMagnitude:0.4];
                
                UIDynamicItemBehavior *dynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[_facebookButton, _twitterView]];
                [dynamicBehavior setElasticity:1];
                [dynamicBehavior setResistance:4];
                
                [self.animator addBehavior:gravityBehavior];
                [self.animator addBehavior:ballCollision];
                [self.animator addBehavior:facebookPush];
                [self.animator addBehavior:dynamicBehavior];
                [self.animator addBehavior:twitterPush];
                [UIView animateWithDuration:0.33 animations:^{
                    _facebookButton.alpha = 1;
//                    _twitterView.alpha = 1;
                }];
            }];
        });
    } else {
        _spinner.hidden = NO;
        [_spinner startAnimating];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _spinner.hidden = YES;
    [_spinner stopAnimating];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)loginToFacebook:(id)sender
{
    switch ([[AppDelegate app].reachability currentReachabilityStatus]) {
        case NotReachable:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"The Internet connection appears to be offline. Please check your settings and try again." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
                [self loginToFacebook:nil];
            }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        default:
        {
            FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
            _sentToFacebookLogin = YES;
            [login logInWithReadPermissions:@[EMAIL_KEY] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                if (error) {
                    // Error
                } else if (result.isCancelled) {
                    // Cancelled
                    _sentToFacebookLogin = NO;
                } else {
                    // Logged in
                    if ([result.grantedPermissions containsObject:EMAIL_KEY]) {
                        NSMutableDictionary *facebookDictionary = [NSMutableDictionary dictionary];
                        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields" : @"id, name, first_name, last_name, email, gender, locale, link"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                            if (!error) {
                                facebookDictionary[GENDER_KEY] = result[GENDER_KEY];
                                facebookDictionary[LOCALE_KEY] = result[LOCALE_KEY];
                                facebookDictionary[LAST_NAME_KEY] = result[LAST_NAME_KEY];
                                facebookDictionary[EMAIL_KEY] = result[EMAIL_KEY];
                                facebookDictionary[FIRST_NAME_KEY] = result[FIRST_NAME_KEY];
                                facebookDictionary[FACEBOOK_ID_KEY] = result[ID_KEY];//[[FBSDKAccessToken currentAccessToken] userID];
                                facebookDictionary[LINK_KEY] = result[LINK_KEY];
                                facebookDictionary[FULL_NAME_KEY] = result[NAME_KEY];
                                [self loginUser:facebookDictionary];
                            }
                        }];
                    }
                }
            }];
        }
        break;
    }
}

- (void)loginUser:(NSDictionary *)user
{
    [UserDefaults setObject:user[EMAIL_KEY] key:EMAIL_KEY];
    
    PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
    [query whereKey:EMAIL_KEY equalTo:user[EMAIL_KEY]];
    [query includeKey:EVENTS_KEY];
    [query includeKey:FRIENDS_KEY];
    [query includeKey:LOCATIONS_KEY];
    [query includeKey:[NSString stringWithFormat:@"%@.%@", EVENTS_KEY, EVENT_LOCATION_KEY]];
    [query includeKey:[NSString stringWithFormat:@"%@.%@", EVENTS_KEY, EVENT_CREATOR_KEY]];
    [query includeKey:[NSString stringWithFormat:@"%@.%@", EVENTS_KEY, EVENT_INVITEES_KEY]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects.count) {
            
            PFObject *person = objects[0];
            
            if (!person[FACEBOOK_ID_KEY]) {
                
                person[GENDER_KEY] = user[GENDER_KEY];
                person[LOCALE_KEY] = user[LOCALE_KEY];
                person[FACEBOOK_ID_KEY] = user[FACEBOOK_ID_KEY];
                person[LAST_NAME_KEY] = user[LAST_NAME_KEY];
                person[FULL_NAME_KEY] = user[FULL_NAME_KEY];
                person[FIRST_NAME_KEY] = user[FIRST_NAME_KEY];
                [person saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [self loginUser:user]; // Recall this method after setting the facebook details so that they are reflected in event invitees
                }];

                return;
            }
            
            [[AppDelegate user] loadParseUser:person];
            [self performSelector:@selector(showDashboard) withObject:nil afterDelay:0.5];
            
        } else {
            
            // User does not exist in Parse database...
            // Create Parse user
            
            [[AppDelegate user] createParseUserFromFacebookUser:user];
            
        }
    }];
}

- (void)userLoggedOut:(NSNotification *)notification
{
    _sentToFacebookLogin = NO;
    [UserDefaults removeObjectForKey:EMAIL_KEY];
}

@end
