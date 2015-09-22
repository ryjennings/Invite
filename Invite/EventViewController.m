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
#import "InviteesViewController.h"
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
    EventRowInvitees,
    EventRowLocation
};

typedef NS_ENUM(NSUInteger, EventPreviewRow) {
    // Map in background
    EventPreviewRowTopPadding,
    EventPreviewRowTitle,
    EventPreviewRowInvitees,
    EventPreviewRowTimeframe,
    EventPreviewRowLocation,
    EventPreviewRowBottomPadding,
    EventPreviewRowCount
};

typedef NS_ENUM(NSUInteger, EventViewRow) {
    // Map in background
    EventViewRowPadding1,
    EventViewRowTitle, // contains Date
    EventViewRowHost,
    EventViewRowTimeframe,
    EventViewRowLocation,
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

@interface EventViewController () <UITableViewDataSource, UITableViewDelegate, PickerViewDelegate, MKMapViewDelegate, NumberedInputCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIButton *bottomButton;
@property (nonatomic, weak) IBOutlet UIView *inviteesContainerView;

@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@property (nonatomic, strong) UITapGestureRecognizer *inviteesTap;

@property (nonatomic, strong) PickerView *pickerView;
@property (nonatomic, strong) NSLayoutConstraint *pickerViewBottomConstraint;
@property (nonatomic, assign) NSInteger response;
@property (nonatomic, assign) BOOL showResponseHasBeenSaved;

@property (nonatomic) EventMode mode;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSMutableDictionary *rsvpDictionary;

@property (nonatomic, strong) NSString *textViewText;
@property (nonatomic, strong) NumberedInputCell *titleInputCell;

@end

@implementation EventViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        if ([AppDelegate user].eventToDisplay) {
            _event = [Event eventFromPFObject:[AppDelegate user].eventToDisplay];
            _mode = EventModeView;
        } else {
            if (![AppDelegate user].protoEvent) {
                [AppDelegate user].protoEvent = [Event createEvent];
            }
            _event = [AppDelegate user].protoEvent;
            _mode = EventModePreview;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CLLocationDegrees latitude = 0;
    CLLocationDegrees longitude = 0;
    
    _showResponseHasBeenSaved = NO;
    
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 100;
    
    if (_mode == EventModeView)
    {
        BOOL isCreator = [_event.creator.objectId isEqualToString:[AppDelegate parseUser].objectId];
        
        _response = [[_event.rsvp objectForKey:[AppDelegate keyFromEmail:[AppDelegate user].email]] integerValue];

        _rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
        self.navigationItem.rightBarButtonItem = _rightBarButtonItem;
        self.navigationItem.title = _event.title;
        
        longitude = ((NSString *)[_event.location objectForKey:LOCATION_LONGITUDE_KEY]).doubleValue;
        latitude = ((NSString *)[_event.location objectForKey:LOCATION_LATITUDE_KEY]).doubleValue;
        
        _bottomButton.hidden = YES;
        
        _inviteesTap = [[UITapGestureRecognizer alloc] init];
        [_inviteesTap addTarget:self action:@selector(addMoreInvitees:)];
        [_inviteesContainerView addGestureRecognizer:_inviteesTap];

        // For invitees section
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
        
        [self configurePickerView];
    }
    else
    {
        self.navigationItem.title = @"New Event";

        _leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = _leftBarButtonItem;
        
        _rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Preview" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        self.navigationItem.rightBarButtonItem = _rightBarButtonItem;
        
        _inviteesContainerView.alpha = 0;
        
        if ([AppDelegate user].protoEvent.location) {
            longitude = ((NSString *)[[AppDelegate user].protoEvent.location objectForKey:LOCATION_LONGITUDE_KEY]).doubleValue;
            latitude = ((NSString *)[[AppDelegate user].protoEvent.location objectForKey:LOCATION_LATITUDE_KEY]).doubleValue;
        }
    
        _bottomButton.layer.cornerRadius = kCornerRadius;
        _bottomButton.clipsToBounds = YES;
        _bottomButton.titleLabel.font = [UIFont proximaNovaRegularFontOfSize:18];
        
        _mapView.alpha = 0.33;
        self.view.backgroundColor = [UIColor inviteLightSlateColor];
    }
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _mapView.delegate = self;
    
    if (latitude && longitude) {
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
    }
}

- (void)addMoreInvitees:(UITapGestureRecognizer *)tap
{
    InviteesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:INVITEES_VIEW_CONTROLLER];
    
    NSMutableArray *inviteesEmails = [NSMutableArray array];
    for (PFObject *invitee in _event.invitees) {
        [inviteesEmails addObject:[invitee objectForKey:EMAIL_KEY]];
    }
    vc.preInviteesEmails = inviteesEmails;
    
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([AppDelegate user].protoEvent.title) {
        _textViewText = [AppDelegate user].protoEvent.title;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addNotifications];
    [_tableView reloadData];
}

- (void)addNotifications
{
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mode == EventModeView && indexPath.section == EventViewSectionResponse)
    {
        BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];
        cell.textLabel.attributedText = [self attributedTextForReponse];
        cell.backgroundColor = [UIColor inviteBlueColor];
        return cell;
    }
    
    if (_mode == EventModePreview && indexPath.section == EventPreviewSectionMessage)
    {
        BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];
        cell.textLabel.text = [self textForRow:EventRowMessage];
        cell.textLabel.font = [UIFont inviteQuestionFont];
        cell.textLabel.textColor = [UIColor inviteQuestionColor];
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    
    if (_mode == EventModeView && indexPath.section == EventViewSectionDetails && indexPath.row == EventViewRowTitle) {
        
        NSDate *startDate = _event.startDate;
        
        TitleDateCell *cell = (TitleDateCell *)[tableView dequeueReusableCellWithIdentifier:TITLE_DATE_CELL_IDENTIFIER];
        cell.label.text = [self textForRow:EventRowTitle];
        cell.accessoryType = _mode == EventModePreview ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;

        if (startDate)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMMM"];
            NSString *month = [[formatter stringFromDate:startDate] uppercaseString];
            [formatter setDateFormat:@"dd"];
            NSString *day = [formatter stringFromDate:startDate];
            
            NSMutableAttributedString *dateAtt = [[NSMutableAttributedString alloc] init];
            [dateAtt appendAttributedString:[[NSAttributedString alloc] initWithString:month attributes:@{NSFontAttributeName: [UIFont proximaNovaSemiboldFontOfSize:9], NSForegroundColorAttributeName: [UIColor whiteColor]}]];
            [dateAtt appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName: [UIFont proximaNovaLightFontOfSize:0]}]];
            [dateAtt appendAttributedString:[[NSAttributedString alloc] initWithString:day attributes:@{NSFontAttributeName: [UIFont proximaNovaLightFontOfSize:22], NSForegroundColorAttributeName: [UIColor whiteColor]}]];
            cell.dateLabel.attributedText = dateAtt;
        }
        
        return cell;
        
    }
    
    // Make sure this check is before NumberedInputCell
    
    if (_mode == EventModePreview && indexPath.section == EventPreviewSectionDetails && (indexPath.row == EventPreviewRowTopPadding || indexPath.row == EventPreviewRowBottomPadding))
    {
        PaddingCell *cell = (PaddingCell *)[tableView dequeueReusableCellWithIdentifier:PADDING_CELL_IDENTIFIER forIndexPath:indexPath];
        cell.heightConstraint.constant = 15;
        return cell;
    }

    if (_mode == EventModePreview && indexPath.section != EventPreviewSectionMessage)
    {
        BOOL isTitle = indexPath.row == EventPreviewRowTitle;
        
        NumberedInputCell *cell = (NumberedInputCell *)[tableView dequeueReusableCellWithIdentifier:INPUT_CELL_IDENTIFIER forIndexPath:indexPath];
        
        if (isTitle) {
            _titleInputCell = cell;
            cell.delegate = self;
            cell.textView.text = _textViewText;
            [self addAccessoryViewToKeyboardForTextView:cell.textView];
            cell.textView.hidden = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.textView.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        switch (indexPath.row) {
            case EventPreviewRowTitle:
                cell.guidance.text = @"Give this event a title";
                break;
            case EventPreviewRowInvitees:
                cell.guidance.text = @"Invite people";
                break;
            case EventPreviewRowTimeframe:
                cell.guidance.text = @"Set a time";
                break;
            case EventPreviewRowLocation:
                cell.guidance.text = @"Choose a location";
                break;
            default:
                break;
        }
        cell.indexPath = indexPath;
        
        return cell;
    }
    
    if (_mode == EventModeView && indexPath.row == EventViewRowTimeframe)
    {
        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:LABEL_CELL_IDENTIFIER];
        cell.cellLabel.text = @"Time";
        cell.cellText.text = [self textForRow:EventRowTimeframe];
        cell.accessoryType = _mode == EventModePreview ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        return cell;
    }
    
    if (_mode == EventModeView && indexPath.row == EventViewRowLocation)
    {
        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:LABEL_CELL_IDENTIFIER];
        cell.cellLabel.text = @"Location";
        cell.cellText.attributedText = [self attributedTextForLocation];
        cell.accessoryType = _mode == EventModePreview ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        return cell;
    }
    
    BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];
    cell.textLabel.text = @"";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (_mode == EventModeView && indexPath.section == EventViewSectionResponse) {
        
        [self showPickerView:YES];
        
    }
    
    if (_mode == EventModePreview && indexPath.section == EventPreviewSectionMessage) {
        
        return;
        
    } else if ((_mode == EventModeView && indexPath.row == EventViewRowTimeframe) ||
               (_mode == EventModePreview && indexPath.row == EventPreviewRowTimeframe)) {
        
        [self performSegueWithIdentifier:SEGUE_TO_TIMEFRAME sender:self];
                
    } else if ((_mode == EventModeView && indexPath.row == EventViewRowLocation) ||
               (_mode == EventModePreview && indexPath.row == EventPreviewRowLocation)) {
        
        [self performSegueWithIdentifier:SEGUE_TO_LOCATION sender:self];
        
    } else if (_mode == EventModePreview && indexPath.row == EventPreviewRowInvitees) {
        
        [self performSegueWithIdentifier:SEGUE_TO_INVITEES sender:self];
        
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
        _showResponseHasBeenSaved = YES;
    }

    _response = response;

    [self responseChanged:response];
    
    BasicCell *cell = (BasicCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:EventViewSectionResponse]];

    cell.textLabel.attributedText = [self attributedTextForReponse];

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
            ((InviteesSectionViewController *)segue.destinationViewController).userInvitees = _event.invitees;
        }
        ((InviteesSectionViewController *)segue.destinationViewController).rsvpDictionary = _rsvpDictionary;
        
    }
}

#pragma mark - RSVP

- (void)responseChanged:(EventResponse)response
{
    [_rsvpDictionary setValue:@(response) forKey:[AppDelegate keyFromEmail:[AppDelegate user].email]];
    _event.rsvp = _rsvpDictionary;
    [_event saveToParse];
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
                return @"Alright, we're ready to send this invite off! Please review, and if everything looks good, tap the button below!";
            } else {
                return @"Since you created this event, you can make changes at any time. Just tap on a row to edit those details.";
            }
        }
        case EventRowTitle:
        {
            return _event.title;
        }
        case EventRowHost:
        {
            return [_event host];
        }
        case EventRowTimeframe:
        {
            return [_event timeframe];
        }
        default:
            return nil;
    }
}

- (NSAttributedString *)attributedTextForLocation
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;

    PFObject *location = _event.location;
    
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
    
    if (!location) {
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"Choose a location for the event" attributes:@{NSForegroundColorAttributeName: [UIColor inviteTableLabelColor], NSFontAttributeName: [UIFont inviteTableSmallFont], NSParagraphStyleAttributeName: style}]];
    }
    
    return att;
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

- (NSAttributedString *)attributedTextForReponse
{
    NSString *lastLine = _showResponseHasBeenSaved ? @"Your response has been saved." : @"Change";
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] init];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n \n" attributes:@{NSFontAttributeName: [UIFont proximaNovaRegularFontOfSize:4]}]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:[self textForResponse:_response] attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont inviteQuestionFont]}]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n \n" attributes:@{NSFontAttributeName: [UIFont proximaNovaRegularFontOfSize:4]}]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:lastLine attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.85], NSFontAttributeName: [UIFont proximaNovaRegularFontOfSize:11]}]];
    
    return att;
}

#pragma mark - Map

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:@"PinIdentifier"];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PinIdentifier"];
        pinView.animatesDrop = YES;
    }
    return pinView;
}

#pragma mark - InputCellDelegate

- (void)numberedTextViewDidChange:(UITextView *)textView
{
    _textViewText = textView.text;
    
    if (textView.text.length > 0) {
        _event.title = textView.text;
    } else {
        _titleInputCell.number.text = @"1";
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - UITextView Accessory View

- (void)addAccessoryViewToKeyboardForTextView:(UITextView *)textView
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 50)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Dismiss Keyboard" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)],
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         nil];
    [toolbar sizeToFit];
    textView.inputAccessoryView = toolbar;
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

@end
