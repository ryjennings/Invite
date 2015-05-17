//
//  InviteesSectionViewController.m
//  Invite
//
//  Created by Ryan Jennings on 4/16/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "InviteesSectionViewController.h"

#import "AppDelegate.h"
#import "DateFlowLayout.h"
#import "Invite-Swift.h"
#import "StringConstants.h"

#import "UIImageView+WebCache.h"

NSString *const kGoing = @"Going";
NSString *const kMaybe = @"Maybe";
NSString *const kSorry = @"Sorry";
NSString *const kNoResponse = @"No Response";

@interface InviteesSectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
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

    NSMutableArray *going = [NSMutableArray array];
    NSMutableArray *maybe = [NSMutableArray array];
    NSMutableArray *sorry = [NSMutableArray array];
    NSMutableArray *noresponse = [NSMutableArray array];
    
    _invitees = [NSMutableDictionary dictionary];
    _usedIndexes = [NSMutableArray array];
    
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
        [_invitees setObject:sorry forKey:@(EventResponseMaybe)];
        [_usedIndexes addObject:@(EventResponseSorry)];
    }
    if (noresponse) {
        [_invitees setObject:noresponse forKey:@(EventResponseNoResponse)];
        [_usedIndexes addObject:@(EventResponseNoResponse)];
    }
    
    self.collectionView.collectionViewLayout = DateFlowLayout.new;
    self.flowLayout = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout);
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.headerReferenceSize = CGSizeMake(80, 80);
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, [SDiPhoneVersion deviceSize] == iPhone55inch ? 20 : 15, 0, 0);
    self.flowLayout.itemSize = CGSizeMake(60, 80);
    self.collectionView.alwaysBounceVertical = NO;
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
//    NSInteger sections = 0;
//    if (_invitees[@(EventResponseGoing)] && ((NSArray *)_invitees[@(EventResponseGoing)]).count) {
//        sections++;
//    } else if (_invitees[@(EventResponseMaybe)] && ((NSArray *)_invitees[@(EventResponseMaybe)]).count) {
//        sections++;
//    } else if (_invitees[@(EventResponseSorry)] && ((NSArray *)_invitees[@(EventResponseSorry)]).count) {
//        sections++;
//    } else if (_invitees[@(EventResponseNoResponse)] && ((NSArray *)_invitees[@(EventResponseNoResponse)]).count) {
//        sections++;
//    }
//    return sections;
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
    
    if ([person isKindOfClass:[PFObject class]] && [((PFObject *)person) objectForKey:FACEBOOK_ID_KEY]) {
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square&width=150&height=150", [person objectForKey:FACEBOOK_ID_KEY]]] placeholderImage:nil];
    } else {
        cell.profileImageView.person = person;
    }
    
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        InviteesCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:INVITEES_COLLECTION_HEADER_VIEW_IDENTIFIER forIndexPath:indexPath];
        headerView.label.text = @[kGoing, kMaybe, kSorry, kNoResponse][((NSNumber *)_usedIndexes[indexPath.section]).intValue];
        headerView.label.font = [UIFont proximaNovaRegularFontOfSize:10];
        headerView.label.textColor = [UIColor inviteTableLabelColor];
        reusableview = headerView;
    }
    
    return reusableview;
}

@end
