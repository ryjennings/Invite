//
//  InviteesSectionViewController.m
//  Invite
//
//  Created by Ryan Jennings on 4/16/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "InviteesSectionViewController.h"

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
@property (nonatomic, strong) NSMutableDictionary *responsesDictionary;

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
    if (!_responses) {
        NSMutableArray *responses = [NSMutableArray array];
        for (PFObject *invitee in _event.invitees) {
            NSString *email = invitee[EMAIL_KEY];
            if (email && email.length > 0) {
                [responses addObject:[NSString stringWithFormat:@"%@:%@", email, @(EventResponseNoResponse)]];
            }
        }
        for (NSString *email in _event.emails) {
            if (email && email.length > 0) {
                [responses addObject:[NSString stringWithFormat:@"%@:%@", email, @(EventResponseNoResponse)]];
            }
        }
        _responses = responses;
    }
    
    NSMutableArray *going = [NSMutableArray array];
    NSMutableArray *maybe = [NSMutableArray array];
    NSMutableArray *sorry = [NSMutableArray array];
    NSMutableArray *noresponse = [NSMutableArray array];
    
    _responsesDictionary = [NSMutableDictionary dictionary];
    
    _invitees = [NSMutableDictionary dictionary];
    _usedIndexes = [NSMutableArray array];
    
    [_responses enumerateObjectsUsingBlock:^(NSString *response, NSUInteger idx, BOOL *stop) {
        NSArray *com = [response componentsSeparatedByString:@":"];
        NSString *email = com[0];
        PFObject *person = [self personForEmail:email];
        _responsesDictionary[com[0]] = @(((NSString *)com[1]).integerValue);
//        if (person) {
            switch (((NSString *)com[1]).integerValue) {
                case EventResponseGoing:
                    [going addObject:person ? person : email];
                    break;
                case EventResponseMaybe:
                    [maybe addObject:person ? person : email];
                    break;
                case EventResponseSorry:
                    [sorry addObject:person ? person : email];
                    break;
                default:
                    [noresponse addObject:person ? person : email];
                    break;
            }
//        }
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
    [_collectionView reloadData];
}

- (PFObject *)personForEmail:(NSString *)email
{
    __block PFObject *person;
    [(_event.parseEvent ? _event.parseEvent[EVENT_INVITEES_KEY] : _event.invitees) enumerateObjectsUsingBlock:^(PFObject *invitee, NSUInteger idx, BOOL *stop) {
        if ([invitee[EMAIL_KEY] isEqualToString:email]) {
            person = invitee;
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
    
    if ([person isKindOfClass:[PFObject class]]) {
        PFObject *thisPerson = (PFObject *)person;
        [cell.profileImageView configureForPerson:person responseValue:((NSNumber *)_responsesDictionary[thisPerson[EMAIL_KEY]]).integerValue width:40 showResponse:YES];
        if ([thisPerson objectForKey:FIRST_NAME_KEY]) {
            cell.label.text = [thisPerson objectForKey:FULL_NAME_KEY];
        } else {
            cell.label.text = [thisPerson objectForKey:EMAIL_KEY];
        }
    } else {
        [cell.profileImageView configureForPerson:person responseValue:((NSNumber *)_responsesDictionary[person]).integerValue width:40 showResponse:YES];
        cell.label.text = (NSString *)person;
    }
    
    return cell;
}

@end
