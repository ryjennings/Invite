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
    EventViewRowTitle, // contains Date
    EventViewRowHost,
    EventViewRowTimeframe,
    EventViewRowLocation,
    EventViewRowBottomPadding,
    EventViewRowCount
};

typedef NS_ENUM(NSUInteger, EventPreviewSection) {
    EventPreviewSectionMessage,
    EventPreviewSectionDetails,
    EventPreviewSectionButton,
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
@property (nonatomic, strong) OBGradientView *gradientView;

@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@property (nonatomic) EventMode mode;
@property (nonatomic, strong) Event *event;

// Invitees section
@property (nonatomic, strong) NSMutableDictionary *rsvpDictionary;
@property (nonatomic, strong) InviteesSectionViewController *inviteesSectionViewController;

// Response
@property (nonatomic, strong) PickerView *pickerView;
@property (nonatomic, strong) NSLayoutConstraint *pickerViewBottomConstraint;
@property (nonatomic, assign) NSInteger response;
@property (nonatomic, assign) BOOL showResponseHasBeenSaved;

// Title
@property (nonatomic, strong) NSString *textViewText;
@property (nonatomic, strong) NumberedInputCell *titleInputCell;

@property (nonatomic, assign) BOOL isCreator;
@property (nonatomic, assign) BOOL alreadyMappedLocationPlacemark;

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
    
    _isCreator = [_event.creator.objectId isEqualToString:[AppDelegate parseUser].objectId];
    _alreadyMappedLocationPlacemark = NO;

    self.view.backgroundColor = [UIColor inviteLightSlateColor];

    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 100;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _mapView.delegate = self;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self configureGradientView];
    }
    [self configureForMode];
}

- (void)configureGradientView
{
    _gradientView = [[OBGradientView alloc] init];
    _gradientView.colors = @[[UIColor inviteLightSlateClearColor], [UIColor inviteLightSlate66Color]];
    _gradientView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:_gradientView aboveSubview:_mapView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[gradientView]|" options:0 metrics:nil views:@{@"gradientView": _gradientView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[gradientView]|" options:0 metrics:nil views:@{@"gradientView": _gradientView}]];
}

- (void)configureForMode
{
    [self configureNavigationBar];
    
    if (_mode == EventModeView)
    {
        if (_event.invitees || _event.emails) {
            [self createRSVPDictionary];
        }
        // Response
        if (!_isCreator) {
            _showResponseHasBeenSaved = NO;
            _response = [[_event.rsvp objectForKey:[AppDelegate keyFromEmail:[AppDelegate user].email]] integerValue];
            [self configureResponsePicker];
        }
        
        if (_event.invitees) {
            _inviteesSectionViewController.userInvitees = _event.invitees;
        }
        if (_rsvpDictionary) {
            _inviteesSectionViewController.rsvpDictionary = _rsvpDictionary;
        }
        if (_event.emails) {
            _inviteesSectionViewController.emailInvitees = _event.emails;
        }

        [_inviteesSectionViewController buildInviteesDictionary];

        _inviteesSectionViewController.view.alpha = 1;
    }
    else
    {
        _inviteesSectionViewController.view.alpha = 0;
    }
    
    [UIView animateWithDuration:0.33 animations:^{
        if (_mode == EventModeView)
        {
            if (_event.location) {
                _mapView.alpha = 1;
            }
        }
        else
        {
            _mapView.alpha = 1;
        }
    }];

    if (_event.location && !_alreadyMappedLocationPlacemark) {
        _alreadyMappedLocationPlacemark = YES;
        CLLocationDegrees latitude = ((NSString *)[_event.location objectForKey:LOCATION_LATITUDE_KEY]).doubleValue;
        CLLocationDegrees longitude = ((NSString *)[_event.location objectForKey:LOCATION_LONGITUDE_KEY]).doubleValue;
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
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

- (void)createRSVPDictionary
{
    NSMutableDictionary *rsvp = [NSMutableDictionary dictionary];
    for (PFObject *invitee in _event.invitees) {
        NSString *email = [invitee objectForKey:EMAIL_KEY];
        if (email && email.length > 0) {
            [rsvp setValue:@(EventResponseNoResponse) forKey:[AppDelegate keyFromEmail:email]];
        }
    }
    for (NSString *email in _event.emails) {
        [rsvp setValue:@(EventResponseNoResponse) forKey:[AppDelegate keyFromEmail:email]];
    }
    _rsvpDictionary = rsvp;
}

- (void)configureNavigationBar
{
    if (_mode == EventModeView)
    {
        if ([AppDelegate user].protoEvent) {
            _rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(preview:)];
        } else {
            _rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
        }
        self.navigationItem.rightBarButtonItem = _rightBarButtonItem;
        self.navigationItem.title = _event.title ? _event.title : @"New Event";
    } else {
        _leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = _leftBarButtonItem;
        _rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Preview" style:UIBarButtonItemStylePlain target:self action:@selector(preview:)];
        self.navigationItem.rightBarButtonItem = _rightBarButtonItem;
        self.navigationItem.title = @"New Event";
    }
}

//- (void)addMoreInvitees:(UITapGestureRecognizer *)tap
//{
//    InviteesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:INVITEES_VIEW_CONTROLLER];
//    
//    NSMutableArray *inviteesEmails = [NSMutableArray array];
//    for (PFObject *invitee in _event.invitees) {
//        [inviteesEmails addObject:[invitee objectForKey:EMAIL_KEY]];
//    }
//    vc.preInviteesEmails = inviteesEmails;
//    
//    [self.navigationController pushViewController:vc animated:YES];
//}

- (void)configureResponsePicker
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
    if (_event.title) {
        _textViewText = _event.title;
    }
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
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;

    footerView.contentView.backgroundColor = [UIColor whiteColor];
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:@"Tap \"Preview\" above to see how this event will look when finished.\n " attributes:@{NSFontAttributeName: [UIFont inviteTableFooterFont], NSParagraphStyleAttributeName: style}];
    
    footerView.textLabel.textAlignment = NSTextAlignmentCenter;
    footerView.textLabel.attributedText = att;
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

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    if (_mode == EventModePreview && section == EventPreviewSectionMessage) {
//        return @"Tap \"Preview\" above to see how this event will look when finished.\n ";
//    }
//    return nil;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _mode == EventModePreview ? EventPreviewSectionCount : EventViewSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((_mode == EventModePreview && section == EventPreviewSectionMessage) ||
        (_mode == EventModePreview && section == EventPreviewSectionButton) ||
        (_mode == EventModeView && section == EventViewSectionResponse)) {
        return 1;
    }
    return _mode == EventModePreview ? EventPreviewRowCount : EventViewRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mode == EventModePreview && indexPath.section == EventPreviewSectionButton)
    {
        ButtonCell *cell = (ButtonCell *)[tableView dequeueReusableCellWithIdentifier:BUTTON_CELL_IDENTIFIER forIndexPath:indexPath];
        BOOL readyToSend = _event.title && (_event.invitees || _event.emails) && _event.timeframe && _event.location;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.button.enabled = readyToSend;
        cell.button.alpha = readyToSend ? 1 : 0.5;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    if (_mode == EventModeView && indexPath.section == EventViewSectionResponse && (_isCreator || [AppDelegate user].protoEvent))
    {
        PaddingCell *cell = (PaddingCell *)[tableView dequeueReusableCellWithIdentifier:NO_CELL_IDENTIFIER forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.heightConstraint.constant = 15;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    if ((_mode == EventModePreview && indexPath.section == EventPreviewSectionDetails && (indexPath.row == EventPreviewRowTopPadding || indexPath.row == EventPreviewRowBottomPadding)) ||
        (_mode == EventModeView && indexPath.section == EventViewSectionDetails && indexPath.row == EventViewRowBottomPadding))
    {
        PaddingCell *cell = (PaddingCell *)[tableView dequeueReusableCellWithIdentifier:PADDING_CELL_IDENTIFIER forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.heightConstraint.constant = 15;
        return cell;
    }
    
    if (_mode == EventModeView && indexPath.section == EventViewSectionResponse && !_isCreator && ![AppDelegate user].protoEvent)
    {
        BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.attributedText = [self attributedTextForReponse];
        cell.backgroundColor = [UIColor inviteBlueColor];
        return cell;
    }
    
    if (_mode == EventModePreview && indexPath.section == EventPreviewSectionMessage)
    {
        BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 2;
        style.alignment = NSTextAlignmentCenter;
        
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] init];
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"To create a new event, follow the steps below." attributes:@{NSFontAttributeName: [UIFont inviteQuestionFont], NSForegroundColorAttributeName: [UIColor inviteQuestionColor]}]];
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n \n" attributes:@{NSFontAttributeName: [UIFont proximaNovaRegularFontOfSize:10]}]];
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"Tap \"Preview\" above to see how this event will look when finished." attributes:@{NSFontAttributeName: [UIFont inviteTableFooterFont], NSParagraphStyleAttributeName: style}]];
        cell.textLabel.attributedText = att;
        
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    
    if (_mode == EventModeView && indexPath.section == EventViewSectionDetails && indexPath.row == EventViewRowTitle) {
        
        NSDate *startDate = _event.startDate;
        
        TitleDateCell *cell = (TitleDateCell *)[tableView dequeueReusableCellWithIdentifier:TITLE_DATE_CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    
    if (_mode == EventModePreview && indexPath.section != EventPreviewSectionMessage)
    {
        BOOL isTitle = indexPath.row == EventPreviewRowTitle;
        NumberedInputCell *cell = (NumberedInputCell *)[tableView dequeueReusableCellWithIdentifier:NUMBERED_INPUT_CELL_IDENTIFIER forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (isTitle) {
            _titleInputCell = cell;
            cell.delegate = self;
            [self addAccessoryViewToKeyboardForTextView:cell.textView];
            cell.textView.hidden = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.textView.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        switch (indexPath.row) {
            case EventPreviewRowTitle:
            {
                if (_event.title) {
                    cell.textView.text = _textViewText;
                    cell.guidance.text = @"";
                    cell.guidance.textColor = [self valueColor];
                } else {
                    cell.guidance.text = @"Give this event a title";
                    cell.guidance.textColor = [self defaultColor];
                }
                break;
            }
            case EventPreviewRowInvitees:
            {
                cell.guidance.hidden = NO;
                NSUInteger inviteeCount = 0;
                if (_event.emails && _event.emails.count) {
                    inviteeCount += _event.emails.count;
                }
                if (_event.invitees && _event.invitees.count) {
                    inviteeCount += _event.invitees.count;
                }
                if (inviteeCount > 0) {
                    cell.guidance.text = [NSString stringWithFormat:@"%lu people invited", (unsigned long)inviteeCount];
                    cell.guidance.textColor = [self valueColor];
                    [cell showCheckmark];
                } else {
                    cell.guidance.text = @"Invite people";
                    cell.guidance.textColor = [self defaultColor];
                    [cell hideCheckmark];
                }
                break;
            }
            case EventPreviewRowTimeframe:
            {
                cell.guidance.hidden = NO;
                cell.guidance.attributedText = [_event timeframe];
                if (_event.startDate && _event.endDate) {
                    cell.guidance.textColor = [self valueColor];
                    [cell showCheckmark];
                } else {
                    cell.guidance.textColor = [self defaultColor];
                    [cell hideCheckmark];
                }
                break;
            }
            case EventPreviewRowLocation:
            {
                cell.guidance.hidden = NO;
                if (_event.location) {
                    cell.guidance.attributedText = [self attributedTextForLocation];
                    cell.guidance.textColor = [self valueColor];
                    [cell showCheckmark];
                } else {
                    cell.guidance.text = @"Choose a location";
                    cell.guidance.textColor = [self defaultColor];
                    [cell hideCheckmark];
                }
                break;
            }
            default:
                break;
        }
        cell.indexPath = indexPath;
        
        return cell;
    }
    
    if (_mode == EventModeView && indexPath.row == EventViewRowTimeframe)
    {
        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:LABEL_CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellLabel.text = @"Time";
        cell.cellText.text = [self textForRow:EventRowTimeframe];
        cell.accessoryType = _mode == EventModePreview ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        return cell;
    }
    
    if (_mode == EventModeView && indexPath.row == EventViewRowLocation)
    {
        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:LABEL_CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellLabel.text = @"Location";
        cell.cellText.attributedText = [self attributedTextForLocation];
        cell.accessoryType = _mode == EventModePreview ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        return cell;
    }
    
    if (_mode == EventModeView && indexPath.row == EventViewRowHost)
    {
        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:LABEL_CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellLabel.text = @"Host";
        cell.cellText.text = [self textForRow:EventRowHost];
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }

    BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"";
    return cell;
}

- (UIColor *)defaultColor
{
    return [UIColor inviteBlueColor];
}

- (UIColor *)valueColor
{
    return [UIColor inviteTableHeaderColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_mode == EventModeView) {
        return;
    }

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
    if ([AppDelegate user].eventToDisplay) {
        [AppDelegate user].eventToDisplay = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel:(id)sender
{
    [AppDelegate user].protoEvent = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)preview:(id)sender
{
    _mode = _mode == EventModePreview ? EventModeView : EventModePreview;
    [self configureForMode];
//    [_tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationFade];
    [_tableView reloadData];
}

- (IBAction)createEvent:(id)sender
{
    [[AppDelegate user].protoEvent submitEvent];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_TO_INVITEES_SECTION])
    {
        _inviteesSectionViewController = (InviteesSectionViewController *)segue.destinationViewController;
    }
}

#pragma mark - RSVP

- (void)responseChanged:(EventResponse)response
{
    [_rsvpDictionary setValue:@(response) forKey:[AppDelegate keyFromEmail:[AppDelegate user].email]];
    _event.rsvp = _rsvpDictionary;
    [_event saveToParse];
}

#pragma mark - Cell Text

- (NSString *)textForRow:(EventRow)row
{
    switch (row) {
        case EventRowMessage:
        {
            if (_mode == EventModePreview) {
                if (_event.title && (_event.invitees || _event.emails) && _event.timeframe && _event.location) {
                    return @"Alright, we're ready to send this invite off! Please review, and if everything looks good, tap the button below!";
                } else {
                    return @"";
                }
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
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:locationNickname attributes:@{NSForegroundColorAttributeName: [UIColor inviteTableHeaderColor], NSFontAttributeName: [UIFont inviteTableSmallFont], NSParagraphStyleAttributeName: style}]];
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    
    if (locationAddress) {
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:locationAddress attributes:@{NSForegroundColorAttributeName: [UIColor inviteTableHeaderColor], NSFontAttributeName: [UIFont inviteTableSmallFont], NSParagraphStyleAttributeName: style}]];
    }
    
    if (!location) {
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"Choose a location for the event" attributes:@{NSForegroundColorAttributeName: [UIColor inviteTableHeaderColor], NSFontAttributeName: [UIFont inviteTableSmallFont], NSParagraphStyleAttributeName: style}]];
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
        _event.title = nil;
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
