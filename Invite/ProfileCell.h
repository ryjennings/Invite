//
//  ProfileCell.h
//  Invite
//
//  Created by Ryan Jennings on 4/13/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Invite-Swift.h"

@interface ProfileCell : UITableViewCell

@property (nonatomic, weak) IBOutlet ProfileImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UILabel *label;

@end
