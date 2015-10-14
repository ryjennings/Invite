//
//  InviteesSectionViewController.m
//  Invite
//
//  Created by Ryan Jennings on 4/16/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "InviteesSectionViewController.h"

#import "AppDelegate.h"
#import "Invite-Swift.h"
#import "StringConstants.h"

#import "UIImageView+WebCache.h"

NSString *const kGoing = @"Going";
NSString *const kMaybe = @"Maybe";
NSString *const kSorry = @"Sorry";
NSString *const kNoResponse = @"No Response";

@interface InviteesSectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingConstraint;

@property (nonatomic, strong) NSMutableDictionary *invitees;
@property (nonatomic, strong) NSMutableArray *usedIndexes;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end

@implementation InviteesSectionViewController

#pragma mark - UICollectionView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _leadingConstraint.constant = [SDiPhoneVersion deviceSize] == iPhone55inch ? 20 : 15;

    _headerLabel.textColor = [UIColor inviteTableHeaderColor];
    _headerLabel.font = [UIFont inviteTableHeaderFont];
    _headerLabel.text = @"WHO'S INVITED";
}

- (void)buildInviteesDictionary
{
    NSMutableArray *going = [NSMutableArray array];
    NSMutableArray *maybe = [NSMutableArray array];
    NSMutableArray *sorry = [NSMutableArray array];
    NSMutableArray *noresponse = [NSMutableArray array];
    
    _invitees = [NSMutableDictionary dictionary];
    _usedIndexes = [NSMutableArray array];
    
    if (_userInvitees) {
        NSMutableArray *inviteeEmails = [NSMutableArray array];
        for (PFObject *invitee in _userInvitees) {
            [inviteeEmails addObject:[invitee objectForKey:EMAIL_KEY]];
        }
//        [noresponse addObjectsFromArray:inviteeEmails];
    }
    
    if (_emailInvitees.count) {
        [noresponse addObjectsFromArray:_emailInvitees];
    }
    
    [_rsvpDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([self personForKey:key]) {
            switch (((NSNumber *)obj).integerValue) {
                case EventResponseGoing:
                    [going addObject:[self personForKey:key]];
                    break;
                case EventResponseMaybe:
                    [maybe addObject:[self personForKey:key]];
                    break;
                case EventResponseSorry:
                    [sorry addObject:[self personForKey:key]];
                    break;
                default:
                    [noresponse addObject:[self personForKey:key]];
                    break;
            }
        }
    }];
    
    if (going.count) {
        [_invitees setObject:going forKey:@(EventResponseGoing)];
        [_usedIndexes addObject:@(EventResponseGoing)];
    }
    if (maybe.count) {
        [_invitees setObject:maybe forKey:@(EventResponseMaybe)];
        [_usedIndexes addObject:@(EventResponseMaybe)];
    }
    if (sorry.count) {
        [_invitees setObject:sorry forKey:@(EventResponseSorry)];
        [_usedIndexes addObject:@(EventResponseSorry)];
    }
    if (noresponse) {
        [_invitees setObject:noresponse forKey:@(EventResponseNoResponse)];
        [_usedIndexes addObject:@(EventResponseNoResponse)];
    }
    
    _collectionView.hidden = !_rsvpDictionary.count;
    
}

- (PFObject *)personForKey:(NSString *)key
{
    __block PFObject *person;
    [_userInvitees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[((PFObject *)obj) objectForKey:EMAIL_KEY] isEqualToString:[AppDelegate emailFromKey:key]]) {
            person = obj;
            *stop = YES;
        }
    }];
    return person;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _usedIndexes.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger items = 0;
    items = ((NSArray *)_invitees[_usedIndexes[section]]).count;
    return items;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    InviteesCollectionCell *cell = (InviteesCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:INVITEES_COLLECTION_CELL_IDENTIFIER forIndexPath:indexPath];
    
    id person = ((NSArray *)_invitees[_usedIndexes[indexPath.section]])[indexPath.row];
    
    [cell.profileImageView configureForPerson:person event:_event ? _event : nil width:40 showResponse:YES];
    if ([person isKindOfClass:[PFObject class]]) {
        PFObject *thisPerson = (PFObject *)person;
        if ([thisPerson objectForKey:FIRST_NAME_KEY]) {
            cell.label.text = [thisPerson objectForKey:FIRST_NAME_KEY];
        } else {
            cell.label.text = [thisPerson objectForKey:EMAIL_KEY];
        }
    } else {
        cell.label.text = (NSString *)person;
    }
    
    return cell;
}

@end
