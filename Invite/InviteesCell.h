//
//  InviteesCell.h
//  Invite
//
//  Created by Ryan Jennings on 4/16/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface InviteesCell : UITableViewCell

@property (nonatomic, strong) NSArray *userInvitees;
@property (nonatomic, strong) NSArray *emailInvitees;
@property (nonatomic, strong) NSDictionary *rsvpDictionary;

- (void)prepareCell;

@end
