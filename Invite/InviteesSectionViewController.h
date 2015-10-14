//
//  InviteesSectionViewController.h
//  Invite
//
//  Created by Ryan Jennings on 4/16/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface InviteesSectionViewController : UIViewController

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *userInvitees;
@property (nonatomic, strong) NSArray *emailInvitees;
@property (nonatomic, strong) NSDictionary *rsvpDictionary;
@property (nonatomic, strong) PFObject *event;

- (void)buildInviteesDictionary;

@end
