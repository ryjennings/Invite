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
#import "Invite-Swift.h"
#import "InviteesCell.h"
#import "StringConstants.h"
#import "User.h"

typedef NS_ENUM(NSUInteger, EventMode) {
    EventModePreviewing,
    EventModeViewing
};

typedef NS_ENUM(NSUInteger, EventSection) {
    // EventSectionLocation is in the table header
    EventSectionDetails, // Title, timeframe, description
    EventSectionRSVP,
    EventSectionInvitees,
    EventSectionCount
};

@interface EventViewController () <UINavigationControllerDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *createEventButton;

@property (nonatomic) EventMode mode;
@property (nonatomic, assign) BOOL isCreator;

@property (nonatomic, strong) NSMutableDictionary *rsvpDictionary;
@property (nonatomic, strong) PFObject *event;
@end

@implementation EventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = [[ProgressView alloc] initWithFrame:CGRectMake(0, 0, 150, 15) step:5 steps:5];
    _isCreator = [((PFObject *)[_event objectForKey:EVENT_CREATOR_KEY]).objectId isEqualToString:[AppDelegate parseUser].objectId];
    
    _createEventButton.layer.cornerRadius = kCornerRadius;
    _createEventButton.clipsToBounds = YES;
    _createEventButton.titleLabel.font = [UIFont inviteButtonTitleFont];

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
    return EventSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == EventSectionRSVP && (_mode == EventModePreviewing || _isCreator)) ? 0 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mode == EventModePreviewing) {
        
        if (indexPath.section == EventSectionDetails) {
        
            BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];
            
            NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[AppDelegate user].protoEvent.title attributes:@{NSFontAttributeName: [UIFont proximaNovaLightFontOfSize:20]}];
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:[AppDelegate presentationTimeframeFromStartDate:[AppDelegate user].protoEvent.timeframe.start endDate:[AppDelegate user].protoEvent.timeframe.end] attributes:@{NSFontAttributeName: [UIFont proximaNovaSemiboldFontOfSize:14]}]];
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:[AppDelegate user].protoEvent.eventDescription attributes:@{NSFontAttributeName: [UIFont proximaNovaRegularFontOfSize:16]}]];
            
            cell.textLabel.attributedText = att;
            cell.textLabel.numberOfLines = 0;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            
        } else {
            
            InviteesCell *cell = (InviteesCell *)[tableView dequeueReusableCellWithIdentifier:INVITEES_CELL_IDENTIFIER forIndexPath:indexPath];
            cell.userInvitees = [AppDelegate user].protoEvent.invitees;
            cell.emailInvitees = [AppDelegate user].protoEvent.emails;
            cell.rsvpDictionary = _rsvpDictionary;
            [cell prepareCell];
            return cell;
            
        }
        
    } else {
        
        if (indexPath.section == EventSectionDetails) {
            
            BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];
            
            NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[_event objectForKey:EVENT_TITLE_KEY] attributes:@{NSFontAttributeName: [UIFont proximaNovaLightFontOfSize:20]}];
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:[AppDelegate presentationTimeframeFromStartDate:[_event objectForKey:EVENT_START_DATE_KEY] endDate:[_event objectForKey:EVENT_END_DATE_KEY]] attributes:@{NSFontAttributeName: [UIFont proximaNovaSemiboldFontOfSize:14]}]];
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:[_event objectForKey:EVENT_DESCRIPTION_KEY] attributes:@{NSFontAttributeName: [UIFont proximaNovaRegularFontOfSize:16]}]];
            
            cell.textLabel.attributedText = att;
            cell.textLabel.numberOfLines = 0;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            
        } else if (indexPath.row == EventSectionRSVP && !_isCreator) {
            
            EventResponse response = [[_rsvpDictionary objectForKey:[AppDelegate keyFromEmail:[AppDelegate user].email]] integerValue];
            RadioCell *cell = (RadioCell *)[tableView dequeueReusableCellWithIdentifier:RADIO_CELL_IDENTIFIER];
            cell.segments.selectedSegmentIndex = response;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.segmentsLeadingConstraint.constant = cell.separatorInset.left;
            return cell;
            
        } else {
            
            InviteesCell *cell = (InviteesCell *)[tableView dequeueReusableCellWithIdentifier:INVITEES_CELL_IDENTIFIER forIndexPath:indexPath];
            cell.userInvitees = [_event objectForKey:EVENT_INVITEES_KEY];
            cell.rsvpDictionary = _rsvpDictionary;
            [cell prepareCell];
            return cell;
            
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
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
    [[AppDelegate user].protoEvent submitEvent];
}

#pragma mark - RSVP

- (IBAction)rsvpChanged:(UISegmentedControl *)control
{
    [_rsvpDictionary setValue:@(control.selectedSegmentIndex) forKey:[AppDelegate keyFromEmail:[AppDelegate user].email]];
    _event[EVENT_RSVP_KEY] = _rsvpDictionary;
    [_event saveInBackground];
}

- (IBAction)cancel:(id)sender
{
    [AppDelegate user].protoEvent = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/* SAVED EVENT IMAGE CODE:
 
 [_eventCoverButton setTitle:@"Tap to add event cover photo." forState:UIControlStateNormal];
 [_eventCoverButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
 [_eventCoverButton addTarget:self action:@selector(accessImagePicker:) forControlEvents:UIControlEventTouchUpInside];

 if ([_event objectForKey:EVENT_COVER_IMAGE_KEY]) {
 PFImageView *coverImageView = [[PFImageView alloc] init];
 coverImageView.file = (PFFile *)[_event objectForKey:EVENT_COVER_IMAGE_KEY];
 [coverImageView loadInBackground:^(UIImage *image, NSError *error) {
 [_eventCoverButton setImage:image forState:UIControlStateNormal];
 }];
 }

 [_eventCoverButton.imageView setContentMode:UIViewContentModeScaleAspectFill];

 if (_eventCoverButton.imageView.image) {
 [AppDelegate user].protoEvent.coverImage = _eventCoverButton.imageView.image;
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

 */

@end
