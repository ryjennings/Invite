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

#define kEventCellFont [UIFont systemFontOfSize:17]

CGFloat const EventCoverHeight = 200.0;

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

@interface EventViewController () <EventEditCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *eventCoverView;
@property (nonatomic, weak) IBOutlet UIButton *eventCoverButton;

@property (nonatomic) EventMode mode;
@property (nonatomic, strong) PFObject *event;

@property (nonatomic, strong) NSMutableArray *textViewText;
@property (nonatomic, strong) NSArray *eventData;
@end

@implementation EventViewController

- (void)viewDidLoad
{
    // Instantiate text view array
    _textViewText = [NSMutableArray array];
    for (unsigned i = 0; i < EventRowCount; i++) {
        [_textViewText addObject:@""];
    }

    // Set mode, event data and cover
    if ([AppDelegate user].protoEvent) {
        Event *event = [AppDelegate user].protoEvent;
        _mode = EventModeEditing;
        _eventData = [NSArray arrayWithObjects:
                      event.title ? event.title : @"Tap to add title",
                      [NSString stringWithFormat:@"%@ - %@", event.timeframe.start ? event.timeframe.start : [AppDelegate user].protoEvent.timeframe.start, event.timeframe.end ? event.timeframe.end : [AppDelegate user].protoEvent.timeframe.end],
                      event.eventDescription ? event.eventDescription : @"Tap to add description",
                      @"Location to be listed here",
                      event.invitees ? [event.invitees description] : @"Invitees to be listed here",
                      nil];
        [_eventCoverButton setTitle:@"Tap to add event cover photo." forState:UIControlStateNormal];
        [_eventCoverButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_eventCoverButton addTarget:self action:@selector(accessImagePicker:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        _event = [AppDelegate user].eventToDisplay;
        _mode = EventModeViewing;
        _eventData = [NSArray arrayWithObjects:
                      [_event objectForKey:EVENT_TITLE_KEY],
                      [NSString stringWithFormat:@"%@ - %@", [_event objectForKey:EVENT_START_DATE_KEY], [_event objectForKey:EVENT_END_DATE_KEY]],
                      [_event objectForKey:EVENT_DESCRIPTION_KEY],
                      [_event objectForKey:EVENT_LOCATION_KEY],
                      [_event objectForKey:EVENT_INVITEES_KEY],
                      nil];
        if ([_event objectForKey:EVENT_COVER_IMAGE_KEY]) {
            PFImageView *coverImageView = [[PFImageView alloc] init];
            coverImageView.file = (PFFile *)[_event objectForKey:EVENT_COVER_IMAGE_KEY];
            [coverImageView loadInBackground:^(UIImage *image, NSError *error) {
                [_eventCoverButton setImage:image forState:UIControlStateNormal];
            }];
        }
        _tableView.tableFooterView = nil;
    }
    
    // Additional cover setup
    _eventCoverView.frame = CGRectMake(0, 0, 0, EventCoverHeight);
    [_eventCoverButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
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
    BOOL creator = [((PFObject *)[_event objectForKey:EVENT_CREATOR_KEY]).objectId isEqualToString:[AppDelegate parseUser].objectId];
    
    if (_mode == EventModeEditing && (indexPath.row == EventRowTitle || indexPath.row == EventRowDescription)) {
        
        EventEditCell *cell = (EventEditCell *)[tableView dequeueReusableCellWithIdentifier:EVENT_EDIT_CELL_IDENTIFIER];
        cell.delegate = self;
        cell.placeholderLabel.text = _eventData[indexPath.row];
        cell.placeholderLabel.hidden = cell.textView.text.length;
        cell.textView.tag = indexPath.row;
        cell.textView.text = _textViewText[indexPath.row];
        cell.textView.font = kEventCellFont;
        cell.textView.textContainer.lineFragmentPadding = 0;
        cell.textView.textContainerInset = UIEdgeInsetsMake(1, 0, 0, 0);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else if (indexPath.row == EventRowRSVP && !creator) {
        
        NSDictionary *rsvp = [_event objectForKey:EVENT_RSVP_KEY];
        EventResponse response = [[rsvp objectForKey:[AppDelegate keyFromEmail:[AppDelegate user].email]] integerValue];
        EventRSVPCell *cell = (EventRSVPCell *)[tableView dequeueReusableCellWithIdentifier:EVENT_RSVP_CELL_IDENTIFIER];
        cell.segments.selectedSegmentIndex = response;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else {
        
        EventTextCell *cell = (EventTextCell *)[tableView dequeueReusableCellWithIdentifier:EVENT_TEXT_CELL_IDENTIFIER];
        cell.label.text = _eventData[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = ((NSString *)_textViewText[indexPath.row]).length ? _textViewText[indexPath.row] : _eventData[indexPath.row];
    CGFloat textViewWidth = self.view.frame.size.width - 30;
    CGRect frame = [text boundingRectWithSize:CGSizeMake(textViewWidth, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:@{NSFontAttributeName: kEventCellFont}
                                      context:nil];
    return frame.size.height + 25;
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize size = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, size.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 animations:^{
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, 0.0, 0.0);
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    } completion:nil];
}

#pragma mark - IBActions

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createEvent:(id)sender
{
    [AppDelegate user].protoEvent.title = _textViewText[EventRowTitle];
    [AppDelegate user].protoEvent.eventDescription = _textViewText[EventRowDescription];
    if (_eventCoverButton.imageView.image) {
        [AppDelegate user].protoEvent.coverImage = _eventCoverButton.imageView.image;
    }
    [[AppDelegate user].protoEvent submitEvent];
}

#pragma mark - UIImagePicker

- (void)accessImagePicker:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    [_eventCoverButton setImage:image forState:UIControlStateNormal];
    [_eventCoverButton setTitle:@"" forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EventEditCellDelegate

- (void)eventEditCell:(EventEditCell *)cell textViewDidChange:(UITextView *)textView
{
    _textViewText[textView.tag] = textView.text;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - RSVP

- (IBAction)rsvpChanged:(UISegmentedControl *)control
{
    NSMutableDictionary *rsvp = [[_event objectForKey:EVENT_RSVP_KEY] mutableCopy];
    [rsvp setValue:@(control.selectedSegmentIndex) forKey:[AppDelegate keyFromEmail:[AppDelegate user].email]];
    _event[EVENT_RSVP_KEY] = rsvp;
    [_event saveInBackground];
}

@end
