//
//  TimeframeCollectionLayout.m
//  Invite
//
//  Created by Ryan Jennings on 3/2/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "TimeframeCollectionLayout.h"

@implementation TimeframeCollectionLayout

- (void)awakeFromNib
{
    self.minimumInteritemSpacing = 1.0;
    self.minimumLineSpacing = 1.0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalOffset = proposedContentOffset.x;// + 5;
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
        CGFloat itemOffset = layoutAttributes.frame.origin.x;
        if (ABS(itemOffset - horizontalOffset) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemOffset - horizontalOffset;
        }
    }
    
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end
