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
#import "Invite-Swift.h"
#import "StringConstants.h"
#import "User.h"

CGFloat const kEventCoverHeight = 200.0;

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
    
    NSMutableArray *mEvent = [NSMutableArray array];

    // Set mode, event data and cover
    if ([AppDelegate user].protoEvent) {
        Event *event = [AppDelegate user].protoEvent;
        _mode = EventModeEditing;
        
        NSMutableString *persons = [[NSMutableString alloc] initWithString:@"Friends invited:"];
        for (PFObject *invitee in event.invitees) {
            [persons appendFormat:@"\n%@", [invitee objectForKey:FULL_NAME_KEY] ? [invitee objectForKey:FULL_NAME_KEY] : [invitee objectForKey:EMAIL_KEY]];
        }
        for (NSString *email in event.emails) {
            [persons appendFormat:@"\n%@", email];
        }

        mEvent = [NSMutableArray arrayWithObjects:
                      event.title ? event.title : @"Tap to add title",
                      [AppDelegate presentationTimeframeFromStartDate:[AppDelegate user].protoEvent.timeframe.start endDate:[AppDelegate user].protoEvent.timeframe.end],
                      event.eventDescription ? event.eventDescription : @"Tap to add description",
                      @"Location to be listed here",
                      persons,
                      nil];
        [_eventCoverButton setTitle:@"Tap to add event cover photo." forState:UIControlStateNormal];
        [_eventCoverButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_eventCoverButton addTarget:self action:@selector(accessImagePicker:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        _event = [AppDelegate user].eventToDisplay;
        _mode = EventModeViewing;
        
        NSString *title = [_event objectForKey:EVENT_TITLE_KEY];
        NSString *description = [_event objectForKey:EVENT_DESCRIPTION_KEY];
        PFObject *location = [_event objectForKey:EVENT_LOCATION_KEY];
        NSArray *invitees = [_event objectForKey:EVENT_INVITEES_KEY];

        NSMutableString *persons = [[NSMutableString alloc] initWithString:@"Not yet responded:"];
        for (PFObject *invitee in invitees) {
            [persons appendFormat:@"\n%@", [invitee objectForKey:FULL_NAME_KEY] ? [invitee objectForKey:FULL_NAME_KEY] : [invitee objectForKey:EMAIL_KEY]];
        }
        
        [mEvent addObject:title.length > 0 ? title : @"No title"];
        [mEvent addObject:[AppDelegate presentationTimeframeFromStartDate:[_event objectForKey:EVENT_START_DATE_KEY] endDate:[_event objectForKey:EVENT_END_DATE_KEY]]];
        [mEvent addObject:description.length > 0 ? description : @"No description"];
        [mEvent addObject:@"No location"];
        [mEvent addObject:persons];
        [mEvent addObject:@"You are the creator of this event"];

        if ([_event objectForKey:EVENT_COVER_IMAGE_KEY]) {
            PFImageView *coverImageView = [[PFImageView alloc] init];
            coverImageView.file = (PFFile *)[_event objectForKey:EVENT_COVER_IMAGE_KEY];
            [coverImageView loadInBackground:^(UIImage *image, NSError *error) {
                [_eventCoverButton setImage:image forState:UIControlStateNormal];
            }];
        }
        
        _tableView.tableFooterView = [[UIView alloc] init];
    }

    _eventData = mEvent;
    
    // Additional cover setup
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
        
        EventEditCell *cell = (EventEditCell *)[tableView dequeueReusableCellWithIdentifier:EVENT_EDIT_CELL_IDENTIFIER forIndexPath:indexPath];
        cell.delegate = self;
        cell.placeholderLabel.text = _eventData[indexPath.row];
        cell.placeholderLabel.hidden = cell.textView.text.length;
        cell.textView.tag = indexPath.row;
        cell.textView.text = _textViewText[indexPath.row];
        cell.textView.font = [UIFont inviteTableLabelFont];
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
                                   attributes:@{NSFontAttributeName: [UIFont inviteTableLabelFont]}
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
