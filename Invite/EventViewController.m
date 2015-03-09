//
//  EventViewController.m
//  Invite
//
//  Created by Ryan Jennings on 3/6/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "EventViewController.h"

#import "AppDelegate.h"
#import "Event.h"
#import "EventEditCell.h"
#import "EventRSVPCell.h"
#import "EventTextCell.h"
#import "StringConstants.h"
#import "User.h"

typedef NS_ENUM(NSUInteger, EventMode) {
    EventModeEditing,
    EventModePreviewing,
    EventModeViewing
};

typedef NS_ENUM(NSUInteger, EventRow) {
    EventRowTitle,
    EventRowTimeframe,
    EventRowDescription,
    EventRowLocation,
    EventRowInvitees,
    EventRowRSVP,
    EventRowCount
};

@interface EventViewController () <UITextViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) EventMode mode;
@property (nonatomic, strong) PFObject *parseEvent;
@property (nonatomic, strong) NSMutableDictionary *textViews;
@end

@implementation EventViewController

- (void)viewDidLoad
{
    _textViews = [NSMutableDictionary dictionary];
    
    if ([AppDelegate user].protoEvent) {
        _mode = EventModeEditing;
    } else if ([AppDelegate user].eventToDisplay) {
        _parseEvent = [AppDelegate user].eventToDisplay;
        _mode = EventModeViewing;
        _tableView.tableFooterView = nil;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _mode == EventModeViewing ? EventRowCount : EventRowCount - 1; // No RSVP cell when editing or previewing
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL creator = [((PFObject *)[_parseEvent objectForKey:EVENT_CREATOR_KEY]).objectId isEqualToString:[AppDelegate parseUser].objectId];
    UITableViewCell *cell;
    
    if (_mode == EventModeEditing && (indexPath.item == EventRowTitle || indexPath.item == EventRowDescription)) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:EVENT_EDIT_CELL_IDENTIFIER];
        
    } else if (indexPath.item == EventRowRSVP && !creator) {
        
        NSDictionary *rsvp = [_parseEvent objectForKey:EVENT_RSVP_KEY];
        EventResponse response = [[rsvp objectForKey:[AppDelegate keyFromEmail:[AppDelegate user].email]] integerValue];
        EventRSVPCell *cell = (EventRSVPCell *)[tableView dequeueReusableCellWithIdentifier:EVENT_RSVP_CELL_IDENTIFIER];
        cell.segments.selectedSegmentIndex = response;
        return cell;
        
    } else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:EVENT_TEXT_CELL_IDENTIFIER];
        
    }

    switch (indexPath.item) {
        case EventRowTitle:
        {
            if (_mode == EventModeEditing) {
                ((EventEditCell *)cell).placeholderLabel.text = @"Tap to add event title";
                [_textViews setObject:((EventEditCell *)cell).textView forKey:indexPath];
                [((EventEditCell *)cell).textView setDelegate:self];
                ((EventEditCell *)cell).textView.backgroundColor = [UIColor redColor];
            } else {
                ((EventTextCell *)cell).label.text = _mode == EventModePreviewing ? [AppDelegate user].protoEvent.title : _parseEvent[EVENT_TITLE_KEY];
            }
        }
            break;
        case EventRowTimeframe:
        {
            NSDate *start = _mode == EventModeViewing ? [_parseEvent objectForKey:EVENT_STARTDATE_KEY] : [AppDelegate user].protoEvent.timeframe.start;
            NSDate *end = _mode == EventModeViewing ? [_parseEvent objectForKey:EVENT_ENDDATE_KEY] : [AppDelegate user].protoEvent.timeframe.end;
            ((EventTextCell *)cell).label.text = [NSString stringWithFormat:@"%@ - %@", start, end];
        }
            break;
        case EventRowDescription:
        {
            if (_mode == EventModeEditing) {
                ((EventEditCell *)cell).placeholderLabel.text = @"Tap to add event description";
                [_textViews setObject:((EventEditCell *)cell).textView forKey:indexPath];
                [((EventEditCell *)cell).textView setDelegate:self];
                ((EventEditCell *)cell).textView.backgroundColor = [UIColor redColor];
            } else {
                ((EventTextCell *)cell).label.text = _mode == EventModePreviewing ? [AppDelegate user].protoEvent.eventDescription : _parseEvent[EVENT_DESCRIPTION_KEY];
            }
        }
            break;
        case EventRowInvitees:
        {
            if (_mode == EventModeViewing) {
                ((EventTextCell *)cell).label.text = [NSString stringWithFormat:@"Invitees: %@", _parseEvent[EVENT_RSVP_KEY]];
            } else {
                ((EventTextCell *)cell).label.text = @"Invitees to be listed here";//[NSString stringWithFormat:@"Invitees: %@", [AppDelegate user].protoEvent.invitees];
            }
        }
            break;
        case EventRowLocation:
        {
            ((EventTextCell *)cell).label.text = @"Location to be listed here.";
        }
            break;
        case EventRowRSVP:
        {
            ((EventTextCell *)cell).label.text = @"You are the creator of this event.";
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    for (UITextView *textView in _textViews) {
        [textView resignFirstResponder];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // check here, if it is one of the cells, that needs to be resized
    // to the size of the contained UITextView
    if (indexPath.item == EventRowTitle || indexPath.item == EventRowDescription) {
        return [self textViewHeightForRowAtIndexPath:indexPath];
    } else {
        // return your normal height here:
        return 100.0;
    }
}

- (CGFloat)textViewHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITextView *calculationView = [_textViews objectForKey:indexPath];
    CGFloat textViewWidth = calculationView.frame.size.width;
    if (!calculationView.attributedText) {
        // This will be needed on load, when the text view is not inited yet
        
        calculationView = [[UITextView alloc] init];
        calculationView.attributedText = [[NSAttributedString alloc] initWithString:@""]; // get the text from your datasource add attributes and insert here
        textViewWidth = self.view.frame.size.width; // Insert the width of your UITextViews or include calculations to set it accordingly
    }
    CGSize size = [calculationView sizeThatFits:CGSizeMake(textViewWidth, FLT_MAX)];
    return size.height;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self.tableView beginUpdates]; // This will cause an animated update of
    [self.tableView endUpdates];   // the height of your UITableViewCell
    
    // If the UITextView is not automatically resized (e.g. through autolayout
    // constraints), resize it here
    
//    [self scrollToCursorForTextView:textView]; // OPTIONAL: Follow cursor
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
//    [self scrollToCursorForTextView:textView];
}

- (void)scrollToCursorForTextView:(UITextView *)textView
{
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    
    cursorRect = [self.tableView convertRect:cursorRect fromView:textView];
    
    if (![self rectVisible:cursorRect]) {
        cursorRect.size.height += 8; // To add some space underneath the cursor
        [self.tableView scrollRectToVisible:cursorRect animated:YES];
    }
}

- (BOOL)rectVisible: (CGRect)rect
{
    CGRect visibleRect;
    visibleRect.origin = self.tableView.contentOffset;
    visibleRect.origin.y += self.tableView.contentInset.top;
    visibleRect.size = self.tableView.bounds.size;
    visibleRect.size.height -= self.tableView.contentInset.top + self.tableView.contentInset.bottom;
    
    return CGRectContainsRect(visibleRect, rect);
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, 0.0, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    [UIView commitAnimations];
}

- (IBAction)rsvpChanged:(UISegmentedControl *)control
{
    NSMutableDictionary *rsvp = [[_parseEvent objectForKey:EVENT_RSVP_KEY] mutableCopy];
    [rsvp setValue:@(control.selectedSegmentIndex) forKey:[AppDelegate keyFromEmail:[AppDelegate user].email]];
    _parseEvent[EVENT_RSVP_KEY] = rsvp;
    [_parseEvent saveInBackground];
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createEvent:(id)sender
{
    [AppDelegate user].protoEvent.title = ((UITextView *)[_textViews objectForKey:[NSIndexPath indexPathForRow:0 inSection:0]]).text;
    [AppDelegate user].protoEvent.eventDescription = ((UITextView *)[_textViews objectForKey:[NSIndexPath indexPathForRow:2 inSection:0]]).text;
    [[AppDelegate user].protoEvent submitEvent];
}

@end
