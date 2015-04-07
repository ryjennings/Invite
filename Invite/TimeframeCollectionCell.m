//
//  TimeframeCollectionCell.m
//  Invite
//
//  Created by Ryan Jennings on 2/19/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "TimeframeCollectionCell.h"

#import "Invite-Swift.h"

@interface TimeframeCollectionCell ()

@end

@implementation TimeframeCollectionCell

- (void)awakeFromNib
{
    UIView *view = [[UIView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self insertSubview:view atIndex:0];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": view}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]-|" options:0 metrics:nil views:@{@"view": view}]];
}

@end
