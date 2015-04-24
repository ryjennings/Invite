//
//  DashboardViewController.m
//  Invite
//
//  Created by Ryan Jennings on 2/11/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "DashboardViewController.h"

#import "AppDelegate.h"
#import "Event.h"
#import "EventViewController.h"
#import "LoginViewController.h"
#import "StringConstants.h"
#import "Invite-Swift.h"
#import "SDiPhoneVersion.h"

@interface DashboardViewController ()
@property (nonatomic, weak) IBOutlet UIButton *createEventButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end

@implementation DashboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    if (![AppDelegate user].events) {
        [self configureOnboarding];
    }

    self.view.backgroundColor = [UIColor inviteSlateColor];
    
    [_createEventButton setTitle:NSLocalizedString(@"dashboard_button_addnewevent", nil) forState:UIControlStateNormal];
    [_createEventButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _createEventButton.titleLabel.font = [UIFont proximaNovaRegularFontOfSize:18];
    _createEventButton.backgroundColor = [UIColor inviteSlateButtonColor];
    
    [_settingsButton setTitle:NSLocalizedString(@"navigation_button_settings", nil)];
    
    [_collectionView registerClass:[DashboardCell class] forCellWithReuseIdentifier:DASHBOARD_CELL_IDENTIFIER];
    
    self.navigationItem.title = @"Invite";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventCreated:) name:EVENT_CREATED_NOTIFICATION object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)settings:(id)sender
{
    
}

- (void)configureOnboarding
{
    DashboardOnboardingView *onboarding = [[DashboardOnboardingView alloc] init];
    onboarding.translatesAutoresizingMaskIntoConstraints = NO;
    onboarding.backgroundColor = [UIColor clearColor];

    if ([SDiPhoneVersion deviceSize] == iPhone35inch || [SDiPhoneVersion deviceSize] == iPhone4inch) {
        
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        [self.view addSubview:scrollView];
        [scrollView addSubview:onboarding];
        
        OBGradientView *gradientView = [[OBGradientView alloc] init];
        gradientView.colors = @[[UIColor inviteSlateClearColor], [UIColor inviteSlateColor]];
        gradientView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:gradientView];

        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[gradientView]|" options:0 metrics:nil views:@{@"gradientView": gradientView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[gradientView(30)]-60-|" options:0 metrics:nil views:@{@"gradientView": gradientView}]];

        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:nil views:@{@"scrollView": scrollView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[scrollView]-60-|" options:0 metrics:nil views:@{@"scrollView": scrollView}]];

        [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[onboarding(280)]" options:0 metrics:nil views:@{@"onboarding": onboarding}]];
        [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[onboarding]|" options:0 metrics:nil views:@{@"onboarding": onboarding}]];
        [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:onboarding attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
    } else {
        
        [self.view addSubview:onboarding];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[onboarding(300)]" options:0 metrics:nil views:@{@"onboarding": onboarding}]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:onboarding attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:onboarding attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_TO_INVITEES]) {
        [AppDelegate user].protoEvent = [Event createEvent];
    }
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger items = [AppDelegate user].events.count;
    return items;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DashboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DASHBOARD_CELL_IDENTIFIER forIndexPath:indexPath];
    PFObject *event = [AppDelegate user].events[indexPath.item];
    cell.event = event;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [AppDelegate user].eventToDisplay = [AppDelegate user].events[indexPath.item];
    [self performSegueWithIdentifier:SEGUE_TO_EVENT sender:self];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
}

#pragma mark - Notifications

- (void)eventCreated:(NSNotification *)notification
{
    // Add event to local user

    [self dismissViewControllerAnimated:YES completion:nil];
    [AppDelegate user].protoEvent = nil;
    [_collectionView reloadData];
    [self performSelector:@selector(scrollToItemAtIndexPath) withObject:nil afterDelay:0.5];
}

- (void)scrollToItemAtIndexPath
{
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[AppDelegate user].events.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (IBAction)logout:(id)sender
{
//    [FBSession.activeSession closeAndClearTokenInformation];
    
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    
//    LoginViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:LOGIN_VIEW_CONTROLLER];
//    controller.prepareForSegueFromLaunchViewController = NO;
//    [self.navigationController setViewControllers:@[controller] animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
