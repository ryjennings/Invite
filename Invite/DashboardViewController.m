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

@interface DashboardViewController ()
@property (nonatomic, weak) IBOutlet UIButton *createEventButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *createEventButtonLeadingConstraint;
@end

@implementation DashboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_createEventButton setTitle:[NSLocalizedString(@"dashboard_button_addnewevent", nil) uppercaseString] forState:UIControlStateNormal];
    _createEventButton.layer.cornerRadius = kCornerRadius;
    _createEventButton.clipsToBounds = YES;
    _createEventButton.titleLabel.font = [UIFont inviteButtonTitleFont];
    _createEventButtonLeadingConstraint.constant = kDashboardPadding;
    
    [_settingsButton setTitle:NSLocalizedString(@"navigation_button_settings", nil)];
    
    [_collectionView registerClass:[DashboardEventCell class] forCellWithReuseIdentifier:DASHBOARD_EVENT_CELL_IDENTIFIER];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventCreated:) name:EVENT_CREATED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseLoaded:) name:PARSE_LOADED_NOTIFICATION object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)settings:(id)sender
{
    
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
    return [AppDelegate user].events.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DashboardEventCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DASHBOARD_EVENT_CELL_IDENTIFIER forIndexPath:indexPath];
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

- (void)parseLoaded:(NSNotification *)notification
{
    [_collectionView reloadData];
}

- (IBAction)logout:(id)sender
{
    [FBSession.activeSession closeAndClearTokenInformation];
    [AppDelegate clearUser];
    LoginViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:LOGIN_VIEW_CONTROLLER];
    [self.navigationController setViewControllers:@[controller]];
}

@end
