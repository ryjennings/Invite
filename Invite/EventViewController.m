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

typedef NS_ENUM(NSUInteger, EventMode)
{
    EventModePreview,
    EventModeView
};

typedef NS_ENUM(NSUInteger, EventRow)
{
    EventRowMessage,
    EventRowTitle,
    EventRowHost,
    EventRowResponse,
    EventRowTimeframe,
    EventRowLocation
};

typedef NS_ENUM(NSUInteger, EventPreviewRow)
{
    // Map in background
    EventPreviewRowTopPadding,
    EventPreviewRowTitle,
    EventPreviewRowInvitees,
    EventPreviewRowTimeframe,
    EventPreviewRowLocation,
    EventPreviewRowBottomPadding,
    EventPreviewRowCount
};

typedef NS_ENUM(NSUInteger, EventViewRow)
{
    // Map in background
    EventViewRowTitle, // contains Date
    EventViewRowHost,
    EventViewRowResponse,
    EventViewRowTimeframe,
    EventViewRowLocation,
    EventViewRowBottomPadding,
    EventViewRowCount
};

typedef NS_ENUM(NSUInteger, EventPreviewSection)
{
    EventPreviewSectionMessage,
    EventPreviewSectionDetails,
    EventPreviewSectionButton,
    EventPreviewSectionCount
};

typedef NS_ENUM(NSUInteger, EventViewSection)
{
    EventViewSectionDetails,
    EventViewSectionCount
};

#define kPickerViewHeight 314.0

@interface EventViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, NumberedInputCellDelegate>

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
@property (nonatomic, assign) NSInteger response;
@property (nonatomic, strong) TitleDateCell *titleCell;
@property (nonatomic, strong) LabelCell *responseCell;
@property (nonatomic, assign) BOOL showingResponseSelection;

// Title
@property (nonatomic, strong) NSString *textViewText;
@property (nonatomic, strong) NumberedInputCell *titleInputCell;

@property (nonatomic, assign) BOOL isCreator;

@property (nonatomic, strong) MKPlacemark *lastPlacemark;

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

    self.view.backgroundColor = [UIColor inviteLightSlateColor];

    _tableView.tableHeaderView = [self tableHeaderView];
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 44;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.sectionHeaderHeight = 38;
    
    _mapView.delegate = self;
    _showingResponseSelection = NO;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self configureGradientView];
    }
}

- (UIView *)tableHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 130)];
    view.backgroundColor = [UIColor clearColor];
    return view;
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
        if (![AppDelegate user].protoEvent) {
            // Clear navigation bar
            [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            self.navigationController.navigationBar.shadowImage = [UIImage new];
            self.navigationController.navigationBar.translucent = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }
        
        if (_event.invitees || _event.emails) {
            [self createRSVPDictionary];
        }
        // Response
        if (!_isCreator)
        {
            PFObject *event = [[AppDelegate user] eventToDisplay];
            NSDictionary *rsvp = event[EVENT_RSVP_KEY];
            
            _response = [rsvp[[AppDelegate keyFromEmail:[AppDelegate user].email]] integerValue];
        }
        else
        {
            _response = EventResponseHost;
        }
        
        if (_event.invitees) {
            _inviteesSectionViewController.userInvitees = _event.invitees;
        }
        if (_rsvpDictionary) {
            _inviteesSectionViewController.rsvpDictionary = _rsvpDictionary;
        }
        if (_event.emails && [[AppDelegate user] protoEvent]) {
            _inviteesSectionViewController.emailInvitees = _event.emails;
        }

        [_inviteesSectionViewController buildInviteesDictionary];

        _inviteesSectionViewController.view.alpha = 1;
        if ([[AppDelegate user] eventToDisplay]) {
            _inviteesSectionViewController.event = [[AppDelegate user] eventToDisplay];
        }
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

    if (_event.location || _event.protoLocation) {
        CLLocationDegrees latitude;
        CLLocationDegrees longitude;
        if (_event.location) {
            latitude = ((NSString *)[_event.location objectForKey:LOCATION_LATITUDE_KEY]).doubleValue;
            longitude = ((NSString *)[_event.location objectForKey:LOCATION_LONGITUDE_KEY]).doubleValue;
        } else {
            latitude = _event.protoLocation.latitude;
            longitude = _event.protoLocation.longitude;
        }
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:placemarks[0]];
            if (_lastPlacemark) {
                [_mapView removeAnnotation:_lastPlacemark];
            }
            [_mapView addAnnotation:placemark];
            [_mapView showAnnotations:@[placemark] animated:NO];
            CLLocationCoordinate2D center = self.mapView.region.center;
            center.latitude -= self.mapView.region.span.latitudeDelta * 0.485;
            [self.mapView setCenterCoordinate:center animated:NO];
            _lastPlacemark = placemark;
        }];
    }
}

- (void)createRSVPDictionary
{
    if ([AppDelegate user].eventToDisplay) {
        _rsvpDictionary = [AppDelegate user].eventToDisplay[EVENT_RSVP_KEY];
        return;
    }
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
            _rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close:)];
            _rightBarButtonItem.tintColor = [UIColor blackColor];
        }
        self.navigationItem.rightBarButtonItem = _rightBarButtonItem;
    } else {
        _leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = _leftBarButtonItem;
        _rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Preview" style:UIBarButtonItemStylePlain target:self action:@selector(preview:)];
        self.navigationItem.rightBarButtonItem = _rightBarButtonItem;
        self.navigationItem.title = @"New Event";
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_event.title) {
        _textViewText = _event.title;
    }
    [self configureForMode];
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
        (_mode == EventModePreview && section == EventPreviewSectionButton)) {
        return 1;
    }
    return _mode == EventModePreview ? EventPreviewRowCount : EventViewRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mode == EventModePreview && indexPath.section == EventPreviewSectionButton)
    {
        ButtonCell *cell = (ButtonCell *)[tableView dequeueReusableCellWithIdentifier:BUTTON_CELL_IDENTIFIER forIndexPath:indexPath];
        BOOL readyToSend = _event.title && (_event.invitees || _event.emails) && _event.editTimeframe && (_event.location || _event.protoLocation);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.button.enabled = readyToSend;
        cell.button.alpha = readyToSend ? 1 : 0.5;
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
        self.titleCell = cell;

        if (startDate)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMMM"];
            NSString *month = [[formatter stringFromDate:startDate] uppercaseString];
            [formatter setDateFormat:@"dd"];
            NSString *day = [formatter stringFromDate:startDate];
            
            NSMutableAttributedString *dateAtt = [[NSMutableAttributedString alloc] init];
            [dateAtt appendAttributedString:[[NSAttributedString alloc] initWithString:month attributes:@{NSFontAttributeName: [UIFont proximaNovaSemiboldFontOfSize:9], NSForegroundColorAttributeName: [UIColor inviteTableHeaderColor]}]];
            [dateAtt appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName: [UIFont proximaNovaLightFontOfSize:0]}]];
            [dateAtt appendAttributedString:[[NSAttributedString alloc] initWithString:day attributes:@{NSFontAttributeName: [UIFont proximaNovaLightFontOfSize:22], NSForegroundColorAttributeName: [UIColor inviteTableHeaderColor]}]];
            cell.dateLabel.attributedText = dateAtt;
            cell.attributedDate = dateAtt;
            cell.dateLabel.layer.borderWidth = 4;
            cell.dateLabel.layer.borderColor = [self colorForResponse:_response].CGColor;
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
                cell.guidance.attributedText = [_event editTimeframe];
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
                if (_event.location || _event.protoLocation) {
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
    
    if (_mode == EventModeView && indexPath.section == EventViewSectionDetails && indexPath.row == EventViewRowResponse)
    {
        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:LABEL_CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellLabel.text = @"Response";
        cell.cellText.attributedText = [self attributedTextForReponse];
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.responseCell = cell;
        return cell;
    }

    if (_mode == EventModeView && indexPath.row == EventViewRowTimeframe)
    {
        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:LABEL_CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellLabel.text = @"Time";

        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4;
        
        NSAttributedString *att = [[NSAttributedString alloc] initWithString:[_event viewTimeframe] attributes:@{NSForegroundColorAttributeName: [UIColor inviteTableHeaderColor], NSFontAttributeName: [UIFont inviteTableSmallFont], NSParagraphStyleAttributeName: style}];
        
        cell.cellText.attributedText = att;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    
    if (_mode == EventModeView && indexPath.row == EventViewRowLocation)
    {
        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:LABEL_CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellLabel.text = @"Location";
        cell.cellText.attributedText = [self attributedTextForLocation];
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    
    if (!_isCreator && _mode == EventModeView && indexPath.row == EventViewRowResponse && indexPath.section == EventViewSectionDetails)
    {
        if (_showingResponseSelection) {
            [self cancelResponseView];
        } else {
            [self showResponseView];
        }
    }
    
    if (_mode == EventModeView) {
        return;
    }

    if (_mode == EventModePreview && indexPath.section == EventPreviewSectionMessage) {
        
        return;
        
    } else if (_mode == EventModePreview && indexPath.row == EventPreviewRowTimeframe) {
        
        [self performSegueWithIdentifier:SEGUE_TO_TIMEFRAME sender:self];
                
    } else if (_mode == EventModePreview && indexPath.row == EventPreviewRowLocation) {
        
        [self performSegueWithIdentifier:SEGUE_TO_LOCATION sender:self];
        
    } else if (_mode == EventModePreview && indexPath.row == EventPreviewRowInvitees) {
        
        [self performSegueWithIdentifier:SEGUE_TO_INVITEES sender:self];
        
    }
}

#pragma mark - ResponseView

- (void)showResponseView
{
    _showingResponseSelection = YES;
    [self.titleCell showResponseButtons:_response];
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] init];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"Cancel" attributes:@{NSForegroundColorAttributeName: [UIColor inviteGrayColor], NSFontAttributeName: [UIFont inviteTableSmallFont]}]];
    
    self.responseCell.cellText.attributedText = att;
}

- (void)cancelResponseView
{
    _showingResponseSelection = NO;
    [self.titleCell cancelResponseButtons:_response];
    self.responseCell.cellText.attributedText = [self attributedTextForReponse];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CLOSED_NOTIFICATION object:nil];
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

#pragma mark - Cell Text

- (NSString *)textForRow:(EventRow)row
{
    switch (row) {
        case EventRowMessage:
        {
            if (_mode == EventModePreview) {
                if (_event.title && (_event.invitees || _event.emails) && _event.editTimeframe && _event.location) {
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

    NSString *locationName;
    NSString *locationAddress;

    if (_event.location) {
        locationName = [_event.location objectForKey:LOCATION_NAME_KEY];
        locationAddress = [_event.location objectForKey:LOCATION_ADDRESS_KEY];
    } else {
        locationName = _event.protoLocation.name;
        locationAddress = _event.protoLocation.formattedAddress;
    }
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] init];
    
    if (locationName) {
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:locationName attributes:@{NSForegroundColorAttributeName: [UIColor inviteTableHeaderColor], NSFontAttributeName: [UIFont inviteTableSmallFont], NSParagraphStyleAttributeName: style}]];
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    
    if (locationAddress) {
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:locationAddress attributes:@{NSForegroundColorAttributeName: [UIColor inviteTableHeaderColor], NSFontAttributeName: [UIFont inviteTableSmallFont], NSParagraphStyleAttributeName: style}]];
    }
    
    if (!locationName && !locationAddress) {
        att = nil;
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
        case EventResponseHost:
            return kHostText;
    }
}

- (UIColor *)colorForResponse:(EventResponse)response
{
    switch (response) {
        case EventResponseGoing:
            return [UIColor inviteGreenColor];
        case EventResponseMaybe:
            return [UIColor inviteYellowColor];
        case EventResponseSorry:
            return [UIColor inviteRedColor];
        case EventResponseNoResponse:
            return [UIColor inviteLightSlateColor];
        case EventResponseHost:
            return [UIColor inviteBlueColor];
    }
}

- (UIColor *)backgroundColorForResponse:(EventResponse)response
{
    switch (response) {
        case EventResponseGoing:
            return [UIColor colorWithRed:0.10 green:0.69 blue:0.12 alpha:1.0];
        case EventResponseMaybe:
            return [UIColor inviteYellowColor];
        case EventResponseSorry:
            return [UIColor inviteRedColor];
        case EventResponseNoResponse:
            return [UIColor inviteLightSlateColor];
        case EventResponseHost:
            return [UIColor inviteBlueColor];
    }
}

- (NSAttributedString *)attributedTextForReponse
{
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] init];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:[self textForResponse:_response] attributes:@{NSForegroundColorAttributeName: [self colorForResponse:_response], NSFontAttributeName: [UIFont proximaNovaSemiboldFontOfSize:16]}]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" Change" attributes:@{NSForegroundColorAttributeName: [UIColor inviteGrayColor], NSFontAttributeName: [UIFont inviteTableSmallFont]}]];
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
