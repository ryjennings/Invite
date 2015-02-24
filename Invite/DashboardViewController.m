//
//  DashboardViewController.m
//  Invite
//
//  Created by Ryan Jennings on 2/11/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "DashboardViewController.h"

#import "AppDelegate.h"
#import "DashboardEventCell.h"
#import "Event.h"
#import "StringConstants.h"

@interface DashboardViewController ()
@property (nonatomic, weak) IBOutlet UIButton *addNewEventButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end

@implementation DashboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_addNewEventButton setTitle:NSLocalizedString(@"dashboard_button_addnewevent", nil) forState:UIControlStateNormal];
    [_settingsButton setTitle:NSLocalizedString(@"navigation_button_settings", nil)];
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    
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
    id event = [AppDelegate user].events[indexPath.item];
    if ([event isKindOfClass:[Event class]]) {
        cell.label.text = [NSString stringWithFormat:@"Start: %@\nEnd: %@\nInvitees: %@", ((Event *)event).timeframe.start, ((Event *)event).timeframe.end, ((Event *)event).emails];
    } else {
        cell.label.text = [NSString stringWithFormat:@"Start: %@\nEnd: %@\nInvitees: %@", event[EVENT_STARTDATE_KEY], event[EVENT_ENDDATE_KEY], event[EVENT_EMAILS_KEY]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.frame.size;
}

#pragma mark - Notifications

- (void)eventCreated:(NSNotification *)notification
{
    // Add event to local user
    if (![AppDelegate user].events) {
        [AppDelegate user].events = [NSArray array];
    }
    NSMutableArray *events = [[AppDelegate user].events mutableCopy];
    [events addObject:[AppDelegate user].protoEvent];
    [AppDelegate user].events = events;
    
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

@end
