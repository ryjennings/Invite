//
//  UIView+Invite.m
//  Invite
//
//  Created by Ryan Jennings on 4/6/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "UIView+Invite.h"

@implementation UIView (Invite)

+ (void)appearanceObjC
{
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundColor:[UIColor clearColor]];
}

@end
