//
//  TimeframeCollectionCell.h
//  Invite
//
//  Created by Ryan Jennings on 2/19/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeframeCollectionCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *label;

@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger year;

@end
