//
//  EventEditCell.h
//  Invite
//
//  Created by Ryan Jennings on 3/7/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EventEditCellDelegate;

@interface EventEditCell : UITableViewCell

@property (nonatomic, weak) id<EventEditCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, weak) IBOutlet UITextView *textView;

@end

@protocol EventEditCellDelegate <NSObject>

- (void)eventEditCell:(EventEditCell *)cell textViewDidChange:(UITextView *)textView;

@end