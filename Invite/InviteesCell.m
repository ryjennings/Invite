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
    
    if (_emailInvitees.count) {
        [_noresponse addObjectsFromArray:_emailInvitees];
    }
    
    [_rsvpDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
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
    }];

    self.collectionView.collectionViewLayout = DateFlowLayout.new;
    self.flowLayout = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout);
    
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.headerReferenceSize = CGSizeMake(50, 50); //width is margin to the left of the header - must be bigger than 0 to show headers correct.
    self.flowLayout.minimumInteritemSpacing = 10;
    self.flowLayout.minimumLineSpacing = 17;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
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
    return InviteesCellSectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == InviteesCellSectionGoing) {
        return _going.count ? _going.count : 0;
    } else if (section == InviteesCellSectionMaybe) {
        return _maybe.count ? _maybe.count : 0;
    } else if (section == InviteesCellSectionSorry) {
        return _sorry.count ? _sorry.count : 0;
    } else {
        return _noresponse.count ? _noresponse.count : 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *invitee;
    NSString *email;
    
    switch (indexPath.section) {
        case InviteesCellSectionGoing:
            invitee = _going[indexPath.item];
            break;
        case InviteesCellSectionMaybe:
            invitee = _maybe[indexPath.item];
            break;
        case InviteesCellSectionSorry:
            invitee = _sorry[indexPath.item];
            break;
        default:
            
            if ([_noresponse[indexPath.item] isKindOfClass:[PFObject class]]) {
                invitee = _noresponse[indexPath.item];
            } else {
                email = _noresponse[indexPath.item];
            }
            
            break;
    }
    InviteesCollectionCell *cell = (InviteesCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:INVITEES_COLLECTION_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (email.length) {
        [cell.profileImageView prepareLabelForEmail:email];
    } else if ([invitee objectForKey:FACEBOOK_ID_KEY]) {
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square&width=150&height=150", [invitee objectForKey:FACEBOOK_ID_KEY]]] placeholderImage:nil];
    } else {
        [cell.profileImageView prepareLabelForPerson:invitee];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    return nil;
    if (kind == UICollectionElementKindSectionHeader) {
        InviteesCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:INVITEES_COLLECTION_HEADER_VIEW_IDENTIFIER forIndexPath:indexPath];
        headerView.label.text = @"Going";
        reusableview = headerView;
    }
    
    return reusableview;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
