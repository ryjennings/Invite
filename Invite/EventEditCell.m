//
//  EventEditCell.m
//  Invite
//
//  Created by Ryan Jennings on 3/7/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "EventEditCell.h"

@interface EventEditCell () <UITextViewDelegate>

@end

@implementation EventEditCell

- (void)textViewDidChange:(UITextView *)textView
{
    _placeholderLabel.hidden = _textView.text.length;
    if (_delegate && [_delegate respondsToSelector:@selector(eventEditCell:textViewDidChange:)]) {
        [_delegate eventEditCell:self textViewDidChange:_textView];
    }
}

@end
