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

#import <MapKit/MapKit.h>

typedef NS_ENUM(NSUInteger, EventMode) {
    EventModePreviewing,
    EventModeViewing
};

typedef NS_ENUM(NSUInteger, EventSection) {
    // EventSectionLocation is in the table header
    EventSectionMessage,
    EventSectionDetails, // Title, timeframe, description
    EventSectionInvitees,
    EventSectionCount
};

@interface EventViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIScrollView *mapScrollView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
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
    
    if (_event) {
        _isCreator = [((PFObject *)[_event objectForKey:EVENT_CREATOR_KEY]).objectId isEqualToString:[AppDelegate parseUser].objectId];
        _rsvpDictionary = [_event objectForKey:EVENT_RSVP_KEY];
    } else {
        NSMutableDictionary *rsvp = [NSMutableDictionary dictionary];
        for (PFObject *invitee in [AppDelegate user].protoEvent.invitees) {
            NSString *email = [invitee objectForKey:EMAIL_KEY];
            if (email && email.length > 0) {
                [rsvp setValue:@(EventResponseNoResponse) forKey:[AppDelegate keyFromEmail:email]];
            }
        }
        for (NSString *email in [AppDelegate user].protoEvent.emails) {
            [rsvp setValue:@(EventResponseNoResponse) forKey:[AppDelegate keyFromEmail:email]];
        }
        _rsvpDictionary = rsvp;
    }
    
    _createEventButton.layer.cornerRadius = kCornerRadius;
    _createEventButton.clipsToBounds = YES;
    _createEventButton.titleLabel.font = [UIFont proximaNovaRegularFontOfSize:18];
    
    _tableView.estimatedRowHeight = 100;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _mapScrollView.backgroundColor = [UIColor inviteBackgroundSlateColor];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:((NSString *)[[AppDelegate user].protoEvent.location objectForKey:LOCATION_LATITUDE_KEY]).doubleValue
                                                      longitude:((NSString *)[[AppDelegate user].protoEvent.location objectForKey:LOCATION_LONGITUDE_KEY]).doubleValue];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:placemarks[0]];
        [_mapView addAnnotation:placemark];
        [_mapView showAnnotations:@[placemark] animated:YES];
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.textColor = [UIColor inviteTableHeaderColor];
    headerView.textLabel.font = [UIFont inviteTableHeaderFont];
    headerView.contentView.backgroundColor = [UIColor inviteBackgroundSlateColor];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *footerView = (UITableViewHeaderFooterView *)view;
    footerView.textLabel.font = [UIFont inviteTableFooterFont];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case EventSectionDetails:
            return @"Event Details";
        case EventSectionInvitees:
            return @"Invited Friends";
        default:
            return @"";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return EventSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mode == EventModePreviewing) {
        
        if (indexPath.section == EventSectionMessage) {
            
            BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];
            cell.textLabel.text = @"Alright, we're ready to send this invite off! Please review, and if everything looks alright, tap the button below!";
            cell.textLabel.font = [UIFont inviteQuestionFont];
            cell.textLabel.textColor = [UIColor inviteQuestionColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.numberOfLines = 0;
            return cell;
            
        } else if (indexPath.section == EventSectionDetails) {
        
            BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];
            
            NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[AppDelegate user].protoEvent.title attributes:@{NSFontAttributeName: [UIFont proximaNovaLightFontOfSize:28], NSForegroundColorAttributeName: [UIColor inviteBlueColor]}];
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:[AppDelegate presentationTimeframeFromStartDate:[AppDelegate user].protoEvent.startDate endDate:[AppDelegate user].protoEvent.endDate] attributes:@{NSFontAttributeName: [UIFont proximaNovaSemiboldFontOfSize:14], NSForegroundColorAttributeName: [UIColor lightGrayColor]}]];
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:[AppDelegate user].protoEvent.eventDescription attributes:@{NSFontAttributeName: [UIFont proximaNovaRegularFontOfSize:20], NSForegroundColorAttributeName: [UIColor inviteTableLabelColor]}]];
            
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
//            cell.backgroundColor = [UIColor inviteAccentLineGrayColor];
//            cell.contentView.backgroundColor = [UIColor inviteAccentLineGrayColor];
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
            
//        } else if (indexPath.row == EventSectionRSVP && !_isCreator) {
//            
//            EventResponse response = [[_rsvpDictionary objectForKey:[AppDelegate keyFromEmail:[AppDelegate user].email]] integerValue];
//            RadioCell *cell = (RadioCell *)[tableView dequeueReusableCellWithIdentifier:RADIO_CELL_IDENTIFIER];
//            cell.segments.selectedSegmentIndex = response;
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            cell.segmentsLeadingConstraint.constant = cell.separatorInset.left;
//            return cell;
            
        } else {
            
            InviteesCell *cell = (InviteesCell *)[tableView dequeueReusableCellWithIdentifier:INVITEES_CELL_IDENTIFIER forIndexPath:indexPath];
            cell.userInvitees = [_event objectForKey:EVENT_INVITEES_KEY];
            cell.rsvpDictionary = _rsvpDictionary;
            [cell prepareCell];
//            cell.backgroundColor = [UIColor inviteAccentLineGrayColor];
//            cell.contentView.backgroundColor = [UIColor inviteAccentLineGrayColor];
            return cell;
            
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
