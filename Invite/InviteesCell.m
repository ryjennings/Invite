//
//  InviteesCell.m
//  Invite
//
//  Created by Ryan Jennings on 4/16/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "InviteesCell.h"

#import "AppDelegate.h"
#import "DateFlowLayout.h"
#import "Invite-Swift.h"
#import "StringConstants.h"

#import "UIImageView+WebCache.h"

typedef NS_ENUM(NSUInteger, InviteesCellSection) {
    InviteesCellSectionGoing,
    InviteesCellSectionMaybe,
    InviteesCellSectionSorry,
    InviteesCellSectionNoResponse,
    InviteesCellSectionCount
};

NSString *const kGoing = @"Going";
NSString *const kMaybe = @"Maybe";
NSString *const kSorry = @"Sorry";
NSString *const kNoResponse = @"No Response";

@interface InviteesCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *going;
@property (nonatomic, strong) NSMutableArray *maybe;
@property (nonatomic, strong) NSMutableArray *sorry;
@property (nonatomic, strong) NSMutableArray *noresponse;

@property (nonatomic, strong) NSMutableDictionary *invitees;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end

@implementation InviteesCell

#pragma mark - UICollectionView

- (void)prepareCell
{
    _going = [NSMutableArray array];
    _maybe = [NSMutableArray array];
    _sorry = [NSMutableArray array];
    _noresponse = [NSMutableArray array];
    _invitees = [NSMutableDictionary dictionary];
    
    if (_emailInvitees.count) {
        [_noresponse addObjectsFromArray:_emailInvitees];
    }
    
    [_rsvpDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([self personForKey:key]) {
            switch (((NSNumber *)obj).integerValue) {
                case EventResponseGoing:
                    [_going addObject:[self personForKey:key]];
                    break;
                case EventResponseMaybe:
                    [_maybe addObject:[self personForKey:key]];
                    break;
                case EventResponseSorry:
                    [_sorry addObject:[self personForKey:key]];
                    break;
                default:
                    [_noresponse addObject:[self personForKey:key]];
                    break;
            }
        }
    }];
    
    if (_going.count) {
        [_invitees setObject:_going forKey:@(EventResponseGoing)];
    }
    if (_maybe.count) {
        [_invitees setObject:_maybe forKey:@(EventResponseMaybe)];
    }
    if (_sorry.count) {
        [_invitees setObject:_sorry forKey:@(EventResponseMaybe)];
    }
    if (_noresponse) {
        [_invitees setObject:_noresponse forKey:@(EventResponseNone)];
    }
    
    self.collectionView.collectionViewLayout = DateFlowLayout.new;
    self.flowLayout = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout);
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.headerReferenceSize = CGSizeMake(80, 80);
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, self.separatorInset.left, 0, 0);
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
    NSInteger sections = 0;
    if (_invitees[@(EventResponseGoing)] && ((NSArray *)_invitees[@(EventResponseGoing)]).count) {
        sections++;
    } else if (_invitees[@(EventResponseMaybe)] && ((NSArray *)_invitees[@(EventResponseMaybe)]).count) {
        sections++;
    } else if (_invitees[@(EventResponseSorry)] && ((NSArray *)_invitees[@(EventResponseSorry)]).count) {
        sections++;
    } else if (_invitees[@(EventResponseNone)] && ((NSArray *)_invitees[@(EventResponseNone)]).count) {
        sections++;
    }
    return sections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger items = 0;
    items = ((NSArray *)_invitees[@(section)]).count;
    return items;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    InviteesCollectionCell *cell = (InviteesCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:INVITEES_COLLECTION_CELL_IDENTIFIER forIndexPath:indexPath];
    
    id person = ((NSArray *)_invitees[@(indexPath.section)])[indexPath.row];
    
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
        headerView.label.text = @[kGoing, kMaybe, kSorry, kNoResponse][indexPath.section];
        headerView.label.font = [UIFont proximaNovaRegularFontOfSize:10];
        headerView.label.textColor = [UIColor inviteTableLabelColor];
        reusableview = headerView;
    }
    
    return reusableview;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
