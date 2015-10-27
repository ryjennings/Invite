//
//  InviteesSectionViewController.h
//  Invite
//
//  Created by Ryan Jennings on 4/16/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "Event.h"

@interface InviteesSectionViewController : UIViewController

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSArray *responses;

- (void)buildInviteesDictionary;

@end
