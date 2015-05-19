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
#import "InviteesSectionViewController.h"
#import "StringConstants.h"
#import "User.h"

#import <MapKit/MapKit.h>

// Facebook:
// Date
// Title
// Host
// RSVP
// Timeframe
// Location
// Invitees
// Description

typedef NS_ENUM(NSUInteger, EventMode) {
    EventModePreview,
    EventModeView
};

typedef NS_ENUM(NSUInteger, EventRow) {
    EventRowMessage,
    EventRowTitle,
    EventRowHost,
    EventRowTimeframe,
    EventRowLocation,
    EventRowDescription
};

typedef NS_ENUM(NSUInteger, EventPreviewRow) {
    // Map in background
    EventPreviewRowTitle, // contains Date
    EventPreviewRowHost,
    EventPreviewRowTimeframe,
    EventPreviewRowLocation,
    EventPreviewRowPadding1,
    EventPreviewRowDescription,
    EventPreviewRowPadding2,
    EventPreviewRowCount
};

typedef NS_ENUM(NSUInteger, EventViewRow) {
    // Map in background
    EventViewRowTitle, // contains Date
    EventViewRowHost,
    EventViewRowTimeframe,
    EventViewRowLocation,
    EventViewRowPadding1,
    EventViewRowDescription,
    EventViewRowPadding2,
    EventViewRowCount
};

typedef NS_ENUM(NSUInteger, EventPreviewSection) {
    EventPreviewSectionMessage,
    EventPreviewSectionDetails,
    EventPreviewSectionCount
};

typedef NS_ENUM(NSUInteger, EventViewSection) {
    EventViewSectionResponse,
    EventViewSectionDetails,
    EventViewSectionCount
};

#define kPickerViewHeight 314.0

@interface EventViewController () <UITableViewDataSource, UITableViewDelegate, PickerViewDelegate, MKMapViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIScrollView *mapScrollView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIButton *createEventButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *closeButton;

@property (nonatomic, strong) PickerView *pickerView;
@property (nonatomic, strong) NSLayoutConstraint *pickerViewBottomConstraint;
@property (nonatomic, strong) NSString *responseText;
@property (nonatomic, assign) NSInteger response;
@property (nonatomic, assign) BOOL showResponseSavedText;

@property (nonatomic) EventMode mode;
@property (nonatomic, assign) BOOL isCreator;
@property (nonatomic, assign) BOOL showRSVP;

@property (nonatomic, strong) NSMutableDictionary *rsvpDictionary;
@property (nonatomic, strong) PFObject *event;
@end

@implementation EventViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _event = [AppDelegate user].eventToDisplay;
        _rsvpDictionary = [_event objectForKey:EVENT_RSVP_KEY];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CLLocationDegrees latitude;
    CLLocationDegrees longitude;
    
    _showResponseSavedText = NO;
    
    if (_event) {
        
        _isCreator = [((PFObject *)[_event objectForKey:EVENT_CREATOR_KEY]).objectId isEqualToString:[AppDelegate parseUser].objectId];

        _mode = _isCreator ? EventModePreview : EventModeView;
        
        if (_mode == EventModeView) {
            _response = [[_rsvpDictionary objectForKey:[AppDelegate keyFromEmail:[AppDelegate user].email]] integerValue];
        }

        [_closeButton setTitle:@"Close"];
        
        self.navigationItem.title = [_event objectForKey:EVENT_TITLE_KEY];
        
        PFObject *location = [_event objectForKey:EVENT_LOCATION_KEY];
        longitude = ((NSString *)[location objectForKey:LOCATION_LONGITUDE_KEY]).doubleValue;
        latitude = ((NSString *)[location objectForKey:LOCATION_LATITUDE_KEY]).doubleValue;
        
        _createEventButton.hidden = YES;
        
    } else {
        
        _mode = EventModePreview;
        
        self.navigationItem.titleView = [[ProgressView alloc] initWithFrame:CGRectMake(0, 0, 150, 15) step:5 steps:5];

        [_closeButton setTitle:@"Cancel"];

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
        
        longitude = ((NSString *)[[AppDelegate user].protoEvent.location objectForKey:LOCATION_LONGITUDE_KEY]).doubleValue;
        latitude = ((NSString *)[[AppDelegate user].protoEvent.location objectForKey:LOCATION_LATITUDE_KEY]).doubleValue;
    
        _createEventButton.layer.cornerRadius = kCornerRadius;
        _createEventButton.clipsToBounds = YES;
        _createEventButton.titleLabel.font = [UIFont proximaNovaRegularFontOfSize:18];
        
    }
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mapScrollView.backgroundColor = [UIColor inviteBackgroundSlateColor];
    
    _mapView.delegate = self;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude
                                                      longitude:longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:placemarks[0]];
        [_mapView addAnnotation:placemark];
        [_mapView showAnnotations:@[placemark] animated:NO];
        CLLocationCoordinate2D center = self.mapView.region.center;
        center.latitude -= self.mapView.region.span.latitudeDelta * 0.385;
        [self.mapView setCenterCoordinate:center animated:NO];
    }];
    
    [self configurePickerView];
}

- (void)configurePickerView
{
    EventResponse response = [[_rsvpDictionary objectForKey:[AppDelegate keyFromEmail:[AppDelegate user].email]] integerValue];
    _pickerView = [[PickerView alloc] init];
    _pickerView.translatesAutoresizingMaskIntoConstraints = NO;
    _pickerView.delegate = self;
    _pickerView.initialOption = response == EventResponseNoResponse ? 0 : response;
    [self.view addSubview:_pickerView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[picker]|" options:0 metrics:nil views:@{@"picker": _pickerView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[picker(height)]" options:0 metrics:@{@"height": @(kPickerViewHeight)} views:@{@"picker": _pickerView}]];
    _pickerViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_pickerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:kPickerViewHeight];
    [self.view addConstraint:_pickerViewBottomConstraint];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [_tableView reloadData];
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
    if ((_mode == EventModePreview && section == EventPreviewSectionDetails) ||
        (_mode == EventModeView && section == EventViewSectionDetails)) {
        return @"Event Details";
    } else {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _mode == EventModePreview ? EventPreviewSectionCount : EventViewSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((_mode == EventModePreview && section == EventPreviewSectionMessage) ||
        (_mode == EventModeView && section == EventViewSectionResponse)) {
        return 1;
    }
    return _mode == EventModePreview ? EventPreviewRowCount : EventViewRowCount;
}

- (NSString *)textForResponse:(EventResponse)response
{
    switch (response) {
        case EventResponseGoing:
            return kGoingText;
        case EventResponseMaybe:
            return kMaybeText;
        case EventResponseSorry:
            return kSorryText;
        case EventResponseNoResponse:
            return kNoResponseText;
    }
}

- (NSAttributedString *)attributedStringForReponse
{
    NSString *lastLine = _showResponseSavedText ? @"Your response has been saved." : @"Change";
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] init];
//    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"Your current response is" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.85], NSFontAttributeName: [UIFont proximaNovaRegularFontOfSize:11]}]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n \n" attributes:@{NSFontAttributeName: [UIFont proximaNovaRegularFontOfSize:4]}]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:[self textForResponse:_response] attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont inviteQuestionFont]}]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n \n" attributes:@{NSFontAttributeName: [UIFont proximaNovaRegularFontOfSize:4]}]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:lastLine attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.85], NSFontAttributeName: [UIFont proximaNovaRegularFontOfSize:11]}]];
    
    return att;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mode == EventModeView && indexPath.section == EventViewSectionResponse) {
        
        BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];
        
        
        cell.textLabel.attributedText = [self attributedStringForReponse];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.backgroundColor = [UIColor inviteBlueColor];
        
        return cell;
        
    }
    
    if (_mode == EventModePreview && indexPath.section == EventPreviewSectionMessage) {
        
        BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];
        cell.textLabel.text = [self textForRow:EventRowMessage];
        cell.textLabel.font = [UIFont inviteQuestionFont];
        cell.textLabel.textColor = [UIColor inviteQuestionColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.numberOfLines = 0;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
        
    }
    
    if ((_mode == EventModeView && indexPath.section == EventViewSectionDetails && indexPath.row == EventViewRowTitle) ||
        (_mode == EventModePreview && indexPath.section == EventPreviewSectionDetails && indexPath.row == EventPreviewRowTitle)) {
        
        NSDate *startDate = _mode == EventModePreview && [AppDelegate user].protoEvent ? [AppDelegate user].protoEvent.startDate : [_event objectForKey:EVENT_START_DATE_KEY];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMMM"];
        NSString *month = [[formatter stringFromDate:startDate] uppercaseString];
        [formatter setDateFormat:@"dd"];
        NSString *day = [formatter stringFromDate:startDate];
        
        NSMutableAttributedString *dateAtt = [[NSMutableAttributedString alloc] init];
        [dateAtt appendAttributedString:[[NSAttributedString alloc] initWithString:month attributes:@{NSFontAttributeName: [UIFont proximaNovaSemiboldFontOfSize:9], NSForegroundColorAttributeName: [UIColor whiteColor]}]];
        [dateAtt appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName: [UIFont proximaNovaLightFontOfSize:0]}]];
        [dateAtt appendAttributedString:[[NSAttributedString alloc] initWithString:day attributes:@{NSFontAttributeName: [UIFont proximaNovaLightFontOfSize:22], NSForegroundColorAttributeName: [UIColor whiteColor]}]];
        
        TitleDateCell *cell = (TitleDateCell *)[tableView dequeueReusableCellWithIdentifier:TITLE_DATE_CELL_IDENTIFIER];
        cell.label.text = [self textForRow:EventRowTitle];
        cell.dateLabel.attributedText = dateAtt;
        cell.accessoryType = _mode == EventModePreview ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        cell.dateLabelLeadingConstraint.constant = [SDiPhoneVersion deviceSize] == iPhone55inch ? 20 : 15;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
        
    }
    
    if ((_mode == EventModeView && indexPath.row == EventViewRowHost) ||
        (_mode == EventModePreview && indexPath.row == EventPreviewRowHost)) {
        
        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:LABEL_CELL_IDENTIFIER];
        cell.label.text = @"Host";
        cell.cellText.text = [self textForRow:EventRowHost];
        cell.labelLeadingConstraint.constant = [SDiPhoneVersion deviceSize] == iPhone55inch ? 20 : 15;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
        
    }
    
    if ((_mode == EventModeView && indexPath.row == EventViewRowTimeframe) ||
        (_mode == EventModePreview && indexPath.row == EventPreviewRowTimeframe)) {

        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:LABEL_CELL_IDENTIFIER];
        cell.label.text = @"Time";
        cell.cellText.text = [self textForRow:EventRowTimeframe];
        cell.accessoryType = _mode == EventModePreview ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        cell.labelLeadingConstraint.constant = [SDiPhoneVersion deviceSize] == iPhone55inch ? 20 : 15;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor whiteColor];
        return cell;

    }
    
    if ((_mode == EventModeView && indexPath.row == EventViewRowLocation) ||
        (_mode == EventModePreview && indexPath.row == EventPreviewRowLocation)) {
        
        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:LABEL_CELL_IDENTIFIER];
        cell.label.text = @"Location";
        cell.cellText.attributedText = [self attributedTextForLocation];
        cell.cellText.numberOfLines = 0;
        cell.accessoryType = _mode == EventModePreview ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        cell.labelLeadingConstraint.constant = [SDiPhoneVersion deviceSize] == iPhone55inch ? 20 : 15;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
        
    }
    
    if ((_mode == EventModeView && indexPath.row == EventViewRowDescription) ||
        (_mode == EventModePreview && indexPath.row == EventPreviewRowDescription)) {
        
        BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER forIndexPath:indexPath];
        
        cell.textLabel.attributedText = [self attributedTextForDescription];
        cell.textLabel.numberOfLines = 0;
        cell.accessoryType = _mode == EventModePreview ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor whiteColor];
        
        return cell;
        
    }
    
    BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];
    cell.textLabel.text = @"";
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = @"";
    CGFloat width = self.view.bounds.size.width;
    NSDictionary *attributes = @{};
    CGFloat padding = 0;
    CGFloat leftSeparator = [SDiPhoneVersion deviceSize] == iPhone55inch ? 20 : 15;
    
    if (_mode == EventModeView && indexPath.section == EventViewSectionResponse) {
        
        return 80;
        
    }
    
    if (_mode == EventModePreview && indexPath.section == EventPreviewSectionMessage) {
        
        text = [self textForRow:EventRowMessage];
        width -= leftSeparator * 2;
        attributes = @{NSFontAttributeName: [UIFont inviteQuestionFont]};
        padding = 20;
        
    } else if ((_mode == EventModeView && indexPath.section == EventViewSectionDetails && indexPath.row == EventViewRowTitle) ||
               (_mode == EventModePreview && indexPath.section == EventPreviewSectionDetails && indexPath.row == EventPreviewRowTitle)) {
        
        text = [self textForRow:EventRowTitle];
        width -= (leftSeparator * 2) + 80 + 8 + (_mode == EventModePreview ? 33 : 0);
        attributes = @{NSFontAttributeName: [UIFont inviteTitleFont]};
        padding = 15;
        
    } else if ((_mode == EventModeView && indexPath.row == EventViewRowHost) ||
               (_mode == EventModePreview && indexPath.row == EventPreviewRowHost)) {
        
        text = [self textForRow:EventRowHost];
        width -= (leftSeparator * 2) + 80 + 8 + (_mode == EventModePreview ? 33 : 0);
        attributes = @{NSFontAttributeName: [UIFont inviteTableSmallFont]};
        padding = 11;
        
    } else if ((_mode == EventModeView && indexPath.row == EventViewRowTimeframe) ||
               (_mode == EventModePreview && indexPath.row == EventPreviewRowTimeframe)) {
        
        text = [self textForRow:EventRowTimeframe];
        width -= (leftSeparator * 2) + 80 + 8 + (_mode == EventModePreview ? 33 : 0);
        attributes = @{NSFontAttributeName: [UIFont inviteTableSmallFont]};
        padding = 11;
        
    } else if ((_mode == EventModeView && indexPath.row == EventViewRowLocation) ||
               (_mode == EventModePreview && indexPath.row == EventPreviewRowLocation)) {
        
        NSAttributedString *att = [self attributedTextForLocation];
        width -= (leftSeparator * 2) + 80 + 8 + (_mode == EventModePreview ? 33 : 0);
        padding = 11;
        CGRect frame = CGRectIntegral([att boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                        options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                        context:nil]);
        return frame.size.height + (padding * 2);
        
    } else if ((_mode == EventModeView && indexPath.row == EventViewRowDescription) ||
               (_mode == EventModePreview && indexPath.row == EventPreviewRowDescription)) {
        
        NSAttributedString *att = [self attributedTextForDescription];
        width -= (leftSeparator * 2) + (_mode == EventModePreview ? 33 : 0);
        CGRect frame = CGRectIntegral([att boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                        options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                        context:nil]);
        return frame.size.height + (padding * 2);
        
    } else if ((_mode == EventModeView && indexPath.row == EventViewRowPadding1) ||
               (_mode == EventModePreview && indexPath.row == EventPreviewRowPadding1)) {
        
        return 10;
        
    } else if ((_mode == EventModeView && indexPath.row == EventViewRowPadding2) ||
               (_mode == EventModePreview && indexPath.row == EventPreviewRowPadding2)) {
        
        return 25;
        
    }
    
    CGRect frame = CGRectIntegral([text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                     options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                  attributes:attributes
                                                     context:nil]);
    CGFloat height = frame.size.height + (padding * 2);
    
    if ((_mode == EventModeView && indexPath.section == EventViewSectionDetails && indexPath.row == EventViewRowTitle) ||
        (_mode == EventModePreview && indexPath.section == EventPreviewSectionDetails && indexPath.row == EventPreviewRowTitle)) {
        height = MAX(height, 111);
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (_mode == EventModeView && indexPath.section == EventViewSectionResponse) {
        
        [self showPickerView:YES];
        
    }
    
    if (_mode == EventModePreview && indexPath.section == EventPreviewSectionMessage) {
        
        return;
        
    } else if ((_mode == EventModeView && indexPath.section == EventViewSectionDetails && indexPath.row == EventViewRowTitle) ||
               (_mode == EventModePreview && indexPath.section == EventPreviewSectionDetails && indexPath.row == EventPreviewRowTitle)) {
        
        TitleViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:TITLE_VIEW_CONTROLLER];
        vc.preTitle = [self textForRow:EventRowTitle];
        vc.preDescription = [self textForRow:EventRowDescription];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if ((_mode == EventModeView && indexPath.row == EventViewRowHost) ||
               (_mode == EventModePreview && indexPath.row == EventPreviewRowHost)) {
        
    } else if ((_mode == EventModeView && indexPath.row == EventViewRowTimeframe) ||
               (_mode == EventModePreview && indexPath.row == EventPreviewRowTimeframe)) {
        
    } else if ((_mode == EventModeView && indexPath.row == EventViewRowLocation) ||
               (_mode == EventModePreview && indexPath.row == EventPreviewRowLocation)) {
        
    } else if ((_mode == EventModeView && indexPath.row == EventViewRowDescription) ||
               (_mode == EventModePreview && indexPath.row == EventPreviewRowDescription)) {
        
    }
}

- (void)showPickerView:(BOOL)show
{
    _pickerViewBottomConstraint.constant = show ? 0 : kPickerViewHeight;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

#pragma mark - PickerViewDelegate

- (void)pickerView:(PickerView *)pickerView hasSelectedResponse:(EventResponse)response text:(NSString *)text
{
    if (response != _response) {
        _showResponseSavedText = YES;
    }

    _responseText = text;
    _response = response;

    [self responseChanged:response];
    
    BasicCell *cell = (BasicCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:EventViewSectionResponse]];

    cell.textLabel.attributedText = [self attributedStringForReponse];

    [self showPickerView:NO];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_TO_INVITEES_SECTION]) {
        
        if (_mode == EventModePreview && [AppDelegate user].protoEvent) {
            ((InviteesSectionViewController *)segue.destinationViewController).userInvitees = [AppDelegate user].protoEvent.invitees;
            ((InviteesSectionViewController *)segue.destinationViewController).emailInvitees = [AppDelegate user].protoEvent.emails;
        } else {
            ((InviteesSectionViewController *)segue.destinationViewController).userInvitees = [_event objectForKey:EVENT_INVITEES_KEY];
        }
        ((InviteesSectionViewController *)segue.destinationViewController).rsvpDictionary = _rsvpDictionary;
        
    }
}

#pragma mark - RSVP

- (void)responseChanged:(EventResponse)response
{
    [_rsvpDictionary setValue:@(response) forKey:[AppDelegate keyFromEmail:[AppDelegate user].email]];
    _event[EVENT_RSVP_KEY] = _rsvpDictionary;
    [_event saveInBackground];
}

- (IBAction)cancel:(id)sender
{
    [AppDelegate user].protoEvent = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Cell Text

- (NSString *)textForRow:(EventRow)row
{
    switch (row) {
        case EventRowMessage:
        {
            if ([AppDelegate user].protoEvent) {
                return @"Alright, we're ready to send this invite off! Please review, and if everything looks alright, tap the button below!";
            } else {
                return @"Since you created this event, you can make changes at any time. Just tap on a row to edit those details.";
            }
        }
        case EventRowTitle:
        {
            return _mode == EventModePreview && [AppDelegate user].protoEvent ? [AppDelegate user].protoEvent.title : [_event objectForKey:EVENT_TITLE_KEY];
        }
        case EventRowHost:
        {
            NSString *host;
            if (_mode == EventModePreview) {
                host = [AppDelegate user].fullName;
            } else {
                host = [[_event objectForKey:EVENT_CREATOR_KEY] objectForKey:FULL_NAME_KEY];
            }
            return host;
        }
        case EventRowTimeframe:
        {
            NSDate *startDate;
            NSDate *endDate;
            if (_mode == EventModePreview && [AppDelegate user].protoEvent) {
                startDate = [AppDelegate user].protoEvent.startDate;
                endDate = [AppDelegate user].protoEvent.endDate;
            } else {
                startDate = [_event objectForKey:EVENT_START_DATE_KEY];
                endDate = [_event objectForKey:EVENT_END_DATE_KEY];
            }
            return [AppDelegate presentationTimeframeFromStartDate:startDate endDate:endDate];
        }
        case EventRowDescription:
        {
            return _mode == EventModePreview && [AppDelegate user].protoEvent ? [AppDelegate user].protoEvent.eventDescription : [_event objectForKey:EVENT_DESCRIPTION_KEY];
        }
        default:
            return nil;
    }
}

- (NSAttributedString *)attributedTextForLocation
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;

    PFObject *location;
    if (_mode == EventModePreview && [AppDelegate user].protoEvent) {
        location = [AppDelegate user].protoEvent.location;
    } else {
        location = [_event objectForKey:EVENT_LOCATION_KEY];
    }
    
    NSString *locationNickname = [location objectForKey:LOCATION_NICKNAME_KEY];
    NSString *locationAddress = [location objectForKey:LOCATION_ADDRESS_KEY];
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] init];
    
    if (locationNickname) {
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:locationNickname attributes:@{NSForegroundColorAttributeName: [UIColor inviteTableLabelColor], NSFontAttributeName: [UIFont inviteTableSmallFont], NSParagraphStyleAttributeName: style}]];
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    
    if (locationAddress) {
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:locationAddress attributes:@{NSForegroundColorAttributeName: [UIColor inviteTableLabelColor], NSFontAttributeName: [UIFont inviteTableSmallFont], NSParagraphStyleAttributeName: style}]];
    }
    
    return att;
}

- (NSAttributedString *)attributedTextForDescription
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;
    
    NSString *eventDescription;
    if (_mode == EventModePreview && [AppDelegate user].protoEvent) {
        eventDescription = [AppDelegate user].protoEvent.eventDescription;
    } else {
        eventDescription = [_event objectForKey:EVENT_DESCRIPTION_KEY];
    }
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:eventDescription attributes:@{NSForegroundColorAttributeName: [UIColor inviteTableLabelColor], NSFontAttributeName: [UIFont proximaNovaRegularFontOfSize:20], NSParagraphStyleAttributeName: style}];
    return att;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:@"PinIdentifier"];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PinIdentifier"];
        pinView.animatesDrop = YES;
    }
    return pinView;
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
