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
#import <MessageUI/MessageUI.h>

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
    EventRowLocation,
    EventRowRemindMe,
    EventRowButton
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
    EventPreviewRowButton,
    EventPreviewRowCount
};

typedef NS_ENUM(NSUInteger, EventViewRow)
{
    // Map in background
    EventViewRowTitle, // contains Date
    EventViewRowHost,
    EventViewRowResponse,
    EventViewRowRemindMe,
    EventViewRowTimeframe,
    EventViewRowLocation,
    EventViewRowBottomPadding,
    EventViewRowCount
};

typedef NS_ENUM(NSUInteger, EventPreviewSection)
{
    EventPreviewSectionMessage,
    EventPreviewSectionDetails,
    EventPreviewSectionCount
};

typedef NS_ENUM(NSUInteger, EventViewSection)
{
    EventViewSectionDetails,
    EventViewSectionCount
};

@interface EventViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, NumberedInputCellDelegate, TitleDateCellDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIView *inviteesContainerView;
@property (nonatomic, weak) IBOutlet UIView *blueView;

@property (nonatomic, strong) OBGradientView *gradientView;

@property (nonatomic) EventMode mode;
@property (nonatomic, strong) Event *event;

@property (nonatomic, strong) UIButton *modeButton;

// Invitees section
@property (nonatomic, strong) NSMutableDictionary *rsvpDictionary;
@property (nonatomic, strong) InviteesSectionViewController *inviteesSectionViewController;

// Response
@property (nonatomic, assign) NSInteger response;
@property (nonatomic, strong) TitleDateCell *titleCell;
@property (nonatomic, strong) LabelCell *responseCell;
@property (nonatomic, assign) EventResponse startingResponse;
@property (nonatomic, assign) BOOL showingResponseSelection;

// Title
@property (nonatomic, strong) NSString *textViewText;
@property (nonatomic, strong) NumberedInputCell *titleInputCell;

@property (nonatomic, assign) BOOL isCreator;
@property (nonatomic, assign) BOOL isOld;
@property (nonatomic, assign) BOOL isUpdating;
@property (nonatomic, assign) BOOL isCreating;

@property (nonatomic, strong) MKPlacemark *lastPlacemark;
@property (nonatomic, strong) UIAlertController *alert;

@end

@implementation EventViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        if ([AppDelegate user].eventToDisplay) {
            _isCreator = [((PFObject *)[AppDelegate user].eventToDisplay[EVENT_CREATOR_KEY]).objectId isEqualToString:[AppDelegate parseUser].objectId];
        }

        if (_isCreator) {
            [AppDelegate user].protoEvent = [Event eventFromPFObject:[AppDelegate user].eventToDisplay];
            [AppDelegate user].eventToDisplay = nil;
            _event = [AppDelegate user].protoEvent;
            _mode = EventModeView;
            _isUpdating = YES;
            _isCreating = NO;
        } else if ([AppDelegate user].eventToDisplay) {
            _event = [Event eventFromPFObject:[AppDelegate user].eventToDisplay];
            _mode = EventModeView;
            _isUpdating = NO;
            _isCreating = NO;
        } else {
            if (![AppDelegate user].protoEvent) {
                [AppDelegate user].protoEvent = [Event createEvent];
            }
            _event = [AppDelegate user].protoEvent;
            _mode = EventModePreview;
            _isUpdating = NO;
            _isCreating = YES;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor inviteLightSlateColor];

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, 90.0, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;

    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 44;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.sectionHeaderHeight = 38;
    
    _mapView.delegate = self;
    _showingResponseSelection = NO;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self configureGradientView];
    }
    
    if ([AppDelegate user].protoEvent.isParseEvent) {
        NSDate *now = [NSDate date];
        NSDate *end = [AppDelegate user].protoEvent.parseEvent[EVENT_END_DATE_KEY];
        _isOld = [[now earlierDate:end] isEqualToDate:end];
    } else {
        _isOld = NO;
    }
    
    if (!_isCreating && !_event.parseEvent[EVENT_RESPONSES_KEY]) {
        [self recreateResponses];
    }
}

- (void)recreateResponses
{
    // Responses are empty for some reason. Recreate.
    NSMutableArray *responses = [NSMutableArray array];
    for (PFObject *invitee in _event.parseEvent[EVENT_INVITEES_KEY]) {
        NSString *email = [invitee objectForKey:EMAIL_KEY];
        if (email && email.length > 0) {
            [responses addObject:[NSString stringWithFormat:@"%@:%@", email, @(EventResponseNoResponse)]];
        }
    }
    _event.parseEvent[EVENT_RESPONSES_KEY] = responses;
    [_event.parseEvent saveInBackground];
}

- (UIView *)tableHeaderView
{
    _tableView.tableHeaderView = nil;
    CGFloat deviceHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat headerHeight = deviceHeight - [_tableView contentSize].height - (_mode == EventModeView ? 102 : 0);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, headerHeight < 0 ? 0 : headerHeight)];
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
        // Response
        if (!_isCreator)
        {
            PFObject *event = [AppDelegate user].eventToDisplay;
            
            EventResponse eventResponse = 0;
            
            for (NSString *response in event[EVENT_RESPONSES_KEY]) {
                NSArray *com = [response componentsSeparatedByString:@":"];
                if ([com[0] isEqualToString:[AppDelegate user].email]) {
                    eventResponse = ((NSString *)com[1]).integerValue;
                    break;
                }
            }

            _response = eventResponse;
            _startingResponse = _response;
        }
        else
        {
            _response = EventResponseHost;
            _startingResponse = _response;
        }
        
        if ([AppDelegate user].protoEvent.parseEvent) {
            _inviteesSectionViewController.responses = [[AppDelegate user].protoEvent.parseEvent[EVENT_RESPONSES_KEY] mutableCopy];
        } else {
            _inviteesSectionViewController.responses = [[AppDelegate user].eventToDisplay[EVENT_RESPONSES_KEY] mutableCopy];
        }
        _inviteesSectionViewController.event = _event;
        [_inviteesSectionViewController buildInviteesDictionary];
        _inviteesContainerView.hidden = NO;
    }
    else
    {
        _inviteesContainerView.hidden = YES;
    }
    
    if (_event.location || _event.protoLocation) {
        _blueView.hidden = YES;
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
    } else {
        _blueView.hidden = NO;
        _blueView.backgroundColor = [UIColor inviteBackgroundSlateColor];
    }

    [_tableView reloadData];
    [_tableView layoutIfNeeded]; // http://stackoverflow.com/questions/16071503/how-to-tell-when-uitableview-has-completed-reloaddata
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _tableView.tableHeaderView = [self tableHeaderView];
//    });
}

- (void)configureNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    _modeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _modeButton.frame = CGRectMake(0, 0, 60, 26);
    _modeButton.titleLabel.font = [UIFont inviteTableFooterFont];
    _modeButton.layer.cornerRadius = 5;
    _modeButton.clipsToBounds = YES;
    _modeButton.backgroundColor = [UIColor inviteBlueColor];
    [_modeButton addTarget:self action:@selector(preview:) forControlEvents:UIControlEventTouchUpInside];
    [_modeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_modeButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];

    if (_mode == EventModeView)
    {
        UIBarButtonItem *left;

        if ([AppDelegate user].protoEvent && !_isUpdating)
        {
            left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(preview:)];
        }
        else
        {
            if ((_isUpdating && !_isOld) || (!_isCreating && !_isUpdating && !_isOld)) {
                UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actions:)];
                right.tintColor = [UIColor inviteTableHeaderColor];
                self.navigationItem.rightBarButtonItem = right;
            } else {
                self.navigationItem.rightBarButtonItem = nil;
            }
            
            left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close:)];
        }
        left.tintColor = [UIColor inviteTableHeaderColor];
        self.navigationItem.leftBarButtonItem = left;
    }
    else
    {
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancel:)];
        cancel.tintColor = [UIColor inviteTableHeaderColor];

        _modeButton.enabled = _isUpdating || (!_isUpdating && [self readyToSend]);
        _modeButton.backgroundColor = [[UIColor inviteBlueColor] colorWithAlphaComponent:_modeButton.enabled ? 1 : 0.5];

        if (_isCreator) {
            UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(preview:)];
            right.tintColor = [UIColor inviteTableHeaderColor];
            
            self.navigationItem.rightBarButtonItem = right;
            self.navigationItem.leftBarButtonItem = cancel;
        } else {
            [_modeButton setTitle:@"Preview" forState:UIControlStateNormal];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_modeButton];
            self.navigationItem.rightBarButtonItem = cancel;
        }
    }
}

- (void)actions:(UIBarButtonItem *)barButton
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (!_isCreating && !_isUpdating && !_isOld) {
        UIAlertAction *flagEventAction = [UIAlertAction actionWithTitle:@"Flag This Event" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self flagEventAlert];
        }];
        [actionSheet addAction:flagEventAction];
    } else if (_isUpdating && !_isOld) {
        UIAlertAction *cancelEventAction = [UIAlertAction actionWithTitle:@"Cancel This Event" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self cancelEventAlert];
        }];
        [actionSheet addAction:cancelEventAction];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [actionSheet addAction:cancelAction];

    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)flagEventAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Flag This Event" message:@"Does this event have an inappropriate title? Let us know." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *flagEventAction = [UIAlertAction actionWithTitle:@"Flag Event" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self flagEvent];
    }];
    [alert addAction:flagEventAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)flagEvent
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:[NSString stringWithFormat:@"Flagged Event %@", [AppDelegate user].eventToDisplay.objectId]];
        [mail setMessageBody:[NSString stringWithFormat:@"Event %@ has been flagged. Please check the title for improper language.", [AppDelegate user].eventToDisplay.objectId] isHTML:NO];
        [mail setToRecipients:@[@"flag@appuous.com"]];
        [self presentViewController:mail animated:YES completion:nil];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (void)cancelEventAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cancel This Event" message:@"Are you sure you want to cancel this event? This action cannot be undone." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelEventAction = [UIAlertAction actionWithTitle:@"Cancel Event" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self cancelEvent];
    }];
    [alert addAction:cancelEventAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)cancelEvent
{
    _event.parseEvent[EVENT_CANCELLED_KEY] = [NSNumber numberWithBool:YES];
    [_event.parseEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CLOSED_NOTIFICATION object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_event.title) {
        _textViewText = _event.title;
    }
    [self addNotifications];
    [self configureForMode];
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventCreated:) name:EVENT_CREATED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventCreated:) name:EVENT_UPDATED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(step1CreatedError:) name:STEP1_CREATED_ERROR_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(step1CreatedError:) name:STEP2_CREATED_ERROR_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(step1UpdatedError:) name:STEP1_UPDATED_ERROR_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(step1UpdatedError:) name:STEP2_UPDATED_ERROR_NOTIFICATION object:nil];
}

- (void)step1CreatedError:(NSNotification *)note
{
    [_alert dismissViewControllerAnimated:YES completion:^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was a problem creating this event. Please try again." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)step1UpdatedError:(NSNotification *)note
{
    [_alert dismissViewControllerAnimated:YES completion:^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was a problem updating this event. Please try again." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 38;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _mode == EventModePreview ? EventPreviewSectionCount : EventViewSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_mode == EventModePreview && section == EventPreviewSectionMessage) {
        return 1;
    }
    return _mode == EventModePreview ? EventPreviewRowCount : EventViewRowCount;
}

- (BOOL)readyToSend
{
    return (!_isUpdating && _event.title && (_event.invitees || _event.emails) && ![_event.editTimeframe.string isEqualToString:@"Set a time"] && (_event.location || _event.protoLocation)) ||
    (_isUpdating && (_event.updatedTitle || _event.updatedInvitees || _event.updatedEmails || _event.updatedTimeframe || _event.updatedLocation));
}

- (BOOL)newDetails
{
    if (!_isUpdating && !_event.title && !_event.invitees && !_event.emails && [_event.editTimeframe.string isEqualToString:@"Set a time"] && !_event.location && !_event.protoLocation) {
        return NO;
    } else if (_isUpdating) {
        return _event.updatedTitle || _event.updatedInvitees || _event.updatedEmails || _event.updatedTimeframe || _event.updatedLocation;
    } else {
        return YES;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mode == EventModePreview && indexPath.section == EventPreviewSectionDetails && indexPath.row == EventPreviewRowButton)
    {
        ButtonCell *cell = (ButtonCell *)[tableView dequeueReusableCellWithIdentifier:BUTTON_CELL_IDENTIFIER forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        _modeButton.enabled = _isUpdating || (!_isUpdating && [self readyToSend]);
        _modeButton.backgroundColor = [[UIColor inviteBlueColor] colorWithAlphaComponent:_modeButton.enabled ? 1 : 0.5];
        cell.button.enabled = [self readyToSend];
        cell.button.alpha = [self readyToSend] ? 1 : 0.5;
        cell.backgroundColor = [UIColor clearColor];
        [cell.button setTitle:_isUpdating ? @"Update this event!" : @"Create this event!" forState:UIControlStateNormal];
        [cell.button addTarget:self action:_isUpdating ? @selector(updateEvent:) : @selector(createEvent:) forControlEvents:UIControlEventTouchUpInside];
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
        if (!_isUpdating) {
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"To create a new event, follow the steps below." attributes:@{NSFontAttributeName: [UIFont inviteQuestionFont], NSForegroundColorAttributeName: [UIColor inviteQuestionColor]}]];
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n \n" attributes:@{NSFontAttributeName: [UIFont proximaNovaRegularFontOfSize:10]}]];
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"After setting all of the event details, tap \"Preview\" above to see how this event will look to others." attributes:@{NSFontAttributeName: [UIFont inviteTableFooterFont], NSParagraphStyleAttributeName: style}]];
        } else {
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"You may edit any of the event details." attributes:@{NSFontAttributeName: [UIFont inviteQuestionFont], NSForegroundColorAttributeName: [UIColor inviteQuestionColor]}]];
        }
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
        cell.delegate = self;

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
                    [cell showCheckmark];
                } else {
                    cell.guidance.text = @"Give this event a title";
                    cell.guidance.textColor = [self defaultColor];
                    [cell hideCheckmark];
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
                if (_event.addedEmails && _event.addedEmails.count) {
                    inviteeCount += _event.addedEmails.count;
                }
                if (_event.addedInvitees && _event.addedInvitees.count) {
                    inviteeCount += _event.addedInvitees.count;
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
    
    if (_mode == EventModeView && indexPath.row == EventViewRowRemindMe)
    {
        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:LABEL_CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellLabel.text = @"Remind";
        cell.cellText.text = _isCreating ? @"15 minutes before" : [self textForObjectId:_event.parseEvent.objectId];
        cell.cellText.textColor = [UIColor inviteBlueColor];
        cell.cellText.font = [UIFont proximaNovaSemiboldFontOfSize:16];
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    
    if (_mode == EventModeView && indexPath.row == EventViewRowHost)
    {
        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:LABEL_CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellLabel.text = @"Host";
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4;
        if ([_event host]) {
            NSAttributedString *att = [[NSAttributedString alloc] initWithString:[_event host] attributes:@{NSForegroundColorAttributeName: [UIColor inviteTableHeaderColor], NSFontAttributeName: [UIFont inviteTableSmallFont], NSParagraphStyleAttributeName: style}];
            cell.cellText.attributedText = att;
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }

    BasicCell *cell = (BasicCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"";
    return cell;
}

- (NSTimeInterval)timeIntervalForObjectId:(NSString *)objectId
{
    switch ([UserDefaults integerForKey:objectId]) {
        case 1: return 0;
        case 2: return 5 * 60 * -1;
        case 3: return 15 * 60 * -1;
        case 4: return 30 * 60 * -1;
        case 5: return 60 * 60 * -1;
        case 6: return 120 * 60 * -1;
        default: return 0;
    }
}

- (NSString *)textForObjectId:(NSString *)objectId
{
    switch ([UserDefaults integerForKey:objectId]) {
        case 0: return [self textForDefaultRemindMe];
        case 1: return @"At time of event";
        case 2: return @"5 minutes before";
        case 3: return @"15 minutes before";
        case 4: return @"30 minutes before";
        case 5: return @"1 hour before";
        case 6: return @"2 hours before";
        default: return @"Uh oh...";
    }
}

- (NSString *)textForDefaultRemindMe
{
    if (![UserDefaults objectForKey:@"DefaultRemindMe"]) {
        [UserDefaults setInteger:3 key:@"DefaultRemindMe"]; // 15 minutes before
    }
    switch ([UserDefaults integerForKey:@"DefaultRemindMe"]) {
        case 1: return @"At time of event";
        case 2: return @"5 minutes before";
        case 3: return @"15 minutes before";
        case 4: return @"30 minutes before";
        case 5: return @"1 hour before";
        case 6: return @"2 hours before";
        default: return @"Uh oh";
    }
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

    if (_isCreating && _mode == EventModeView && indexPath.section == EventViewSectionDetails && indexPath.row == EventViewRowRemindMe) {
        return;
    }

    if (_mode == EventModeView && indexPath.section == EventViewSectionDetails && indexPath.row == EventViewRowRemindMe) {

        NSUInteger val = [UserDefaults integerForKey:_event.parseEvent.objectId] ? [UserDefaults integerForKey:_event.parseEvent.objectId] : [UserDefaults integerForKey:@"DefaultRemindMe"];
        val++;
        if (val > 6) {
            val = 1;
        }
        [UserDefaults setInteger:val key:_event.parseEvent.objectId];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }
    
    if (!_isCreator && _mode == EventModeView && indexPath.row == EventViewRowTitle && indexPath.section == EventViewSectionDetails)
    {
        if ([AppDelegate user].eventToDisplay && !_showingResponseSelection && !_isOld) {
            [self showResponseView];
        }
    }
    
    if (_mode == EventModeView && indexPath.row == EventViewRowResponse && indexPath.section == EventViewSectionDetails)
    {
        if (_isCreating) {
            // Creating the event
            return;
        }
        if (!_isOld) {
            if (_isCreator) {
                // Updating the event
                [self preview:nil];
                return;
            }
            // Responding to the event
            if (_showingResponseSelection) {
                [self cancelResponseView];
            } else {
                [self showResponseView];
            }
        }
    }
    
    if ([AppDelegate user].protoEvent && _mode == EventModeView && indexPath.section == EventViewSectionDetails && indexPath.row == EventViewRowLocation)
    {
        return;
    }

    if (_mode == EventModeView && indexPath.section == EventViewSectionDetails && indexPath.row == EventViewRowLocation)
    {
        [self launchMapsWithAddress:_event.location[LOCATION_ADDRESS_KEY]];
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
    if (!_showingResponseSelection) {
        _showingResponseSelection = YES;
        [self.titleCell showResponseButtons:_response];
        
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] init];
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"Cancel" attributes:@{NSForegroundColorAttributeName: [UIColor inviteGrayColor], NSFontAttributeName: [UIFont inviteTableSmallFont]}]];
        
        self.responseCell.cellText.attributedText = att;
    }
}

- (void)cancelResponseView
{
    [_titleCell hideResponseButtons:_response];
    _responseCell.cellText.attributedText = [self attributedTextForReponse];
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
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, 90.0, 0.0);
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    } completion:nil];
}

#pragma mark - IBActions

- (IBAction)close:(id)sender
{
    if (_startingResponse != _response) {
                
        // Send new response to parse
        [[AppDelegate user].eventToDisplay removeObject:[NSString stringWithFormat:@"%@:%ld", [AppDelegate user].email, (long)_startingResponse] forKey:EVENT_RESPONSES_KEY];
        [[AppDelegate user].eventToDisplay saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [[AppDelegate user].eventToDisplay addUniqueObject:[NSString stringWithFormat:@"%@:%ld", [AppDelegate user].email, (long)_response] forKey:EVENT_RESPONSES_KEY];
            [[AppDelegate user].eventToDisplay saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CLOSED_NOTIFICATION object:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }];
    } else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CLOSED_NOTIFICATION object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are your sure you want to close?" message:@"You are creating a new event and will loose everything if you close. Be careful." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [AppDelegate user].protoEvent = nil;
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alert addAction:cancelAction];
    [alert addAction:closeAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)cancel:(id)sender
{
    if ([self newDetails]) {
        [self showAlert];
    } else {
        [AppDelegate user].protoEvent = nil;
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)preview:(id)sender
{
    _mode = _mode == EventModePreview ? EventModeView : EventModePreview;
    [self configureForMode];
    [UIView transitionWithView:self.navigationController.view duration:0.5 options:_mode == EventModePreview ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft animations:^{
    } completion:nil];
}

- (void)eventCreated:(NSNotification *)note
{
    [_alert dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DISMISS_EVENT_CONTROLLER_NOTIFICATION object:nil];
    }];
}

- (IBAction)createEvent:(id)sender
{
    BOOL alert = NO;
    
    for (PFObject *invitee in [AppDelegate user].protoEvent.invitees) {
        if (!invitee[FACEBOOK_ID_KEY]) {
            alert = YES;
            break;
        }
    }
    
    if ([AppDelegate user].protoEvent.invitees.count) {
        [self createSendEmailAlert];
    } else {
        [self actuallyCreateEvent];
    }
}

- (void)actuallyCreateEvent
{
    _alert = [UIAlertController alertControllerWithTitle:@"Creating your new event!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:_alert animated:YES completion:nil];
    
    [[AppDelegate user].protoEvent submitEvent];
}

- (void)createSendEmailAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Event Email" message:@"An event email will automatically be sent to guests who have not previously used this app. Do you also want to send the event email to you're other guests?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [AppDelegate user].protoEvent.sendEmails = NO;
        [self actuallyCreateEvent];
    }];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [AppDelegate user].protoEvent.sendEmails = YES;
        [self actuallyCreateEvent];
    }];
    [alert addAction:noAction];
    [alert addAction:yesAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateSendEmailAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Event Email" message:@"An event email will automatically be sent to guests who have not previously used this app. Do you also want to send an update to you're other guests?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [AppDelegate user].protoEvent.sendEmails = NO;
        [self actuallyUpdateEvent];
    }];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [AppDelegate user].protoEvent.sendEmails = YES;
        [self actuallyUpdateEvent];
    }];
    [alert addAction:noAction];
    [alert addAction:yesAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)updateEvent:(id)sender
{
    BOOL breakAllLoops = NO;
    int count = 0;
    
    NSMutableArray *remove = [NSMutableArray array];
    for (PFObject *old in [AppDelegate user].protoEvent.invitees) {
        for (PFObject *new in [AppDelegate user].protoEvent.existingInvitees) {
            if ([old.objectId isEqualToString:new.objectId]) {
                [remove addObject:old];
                count++;
                if (count == [AppDelegate user].protoEvent.existingInvitees.count) {
                    breakAllLoops = YES;
                }
                break;
            }
        }
        if (breakAllLoops) {
            break;
        }
    }
    
    if (remove.count) {
        NSMutableArray *mut = [[AppDelegate user].protoEvent.invitees mutableCopy];
        [mut removeObjectsInArray:remove];
        [AppDelegate user].protoEvent.addedInvitees = mut;
    }

    if ([AppDelegate user].protoEvent.invitees.count &&
        ([AppDelegate user].protoEvent.updatedEmails ||
         [AppDelegate user].protoEvent.updatedInvitees ||
         [AppDelegate user].protoEvent.updatedLocation ||
         [AppDelegate user].protoEvent.updatedTimeframe)) {
            [self updateSendEmailAlert];
        } else {
            [self actuallyUpdateEvent];
        }
}

- (void)actuallyUpdateEvent
{
    _alert = [UIAlertController alertControllerWithTitle:@"Updating your event!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:_alert animated:YES completion:nil];
    
    [[AppDelegate user].protoEvent updateEvent];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_TO_INVITEES_SECTION])
    {
        _inviteesSectionViewController = (InviteesSectionViewController *)segue.destinationViewController;
    }
    else if ([segue.identifier isEqualToString:SEGUE_TO_INVITEES])
    {
        ((InviteesViewController *)segue.destinationViewController).isUpdating = self.isUpdating;
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

    if (_event.protoLocation) {
        locationName = _event.protoLocation.name;
        locationAddress = _event.protoLocation.formattedAddress;
    } else {
        locationName = [_event.location objectForKey:LOCATION_NAME_KEY];
        locationAddress = [_event.location objectForKey:LOCATION_ADDRESS_KEY];
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
    if (_isCreating) {
        return @"Respond to this event!";
    }
    switch (response) {
        case EventResponseGoing:
            return @"Going";
        case EventResponseMaybe:
            return @"Maybe";
        case EventResponseSorry:
            return @"Sorry";
        case EventResponseNoResponse:
            return @"Respond to this event!";
        case EventResponseHost:
            return @"You are the host";
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
            return [UIColor inviteBlueColor];
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
    if (_isOld) {
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:@"This event is over" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSFontAttributeName: [UIFont proximaNovaSemiboldFontOfSize:16]}]];
    } else {
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:[self textForResponse:_response] attributes:@{NSForegroundColorAttributeName: [self colorForResponse:_response], NSFontAttributeName: [UIFont proximaNovaSemiboldFontOfSize:16]}]];
        if (_response != EventResponseNoResponse && _response != EventResponseHost) {
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" / Change" attributes:@{NSForegroundColorAttributeName: [UIColor inviteGrayColor], NSFontAttributeName: [UIFont inviteTableSmallFont]}]];
        } else if (_response == EventResponseHost && _isUpdating && !_isOld) {
            [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" / Edit" attributes:@{NSForegroundColorAttributeName: [UIColor inviteGrayColor], NSFontAttributeName: [UIFont inviteTableSmallFont]}]];
        }
    }
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

- (void)launchMapsWithAddress:(NSString *)address
{
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:address
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         
                         // Convert the CLPlacemark to an MKPlacemark
                         // Note: There's no error checking for a failed geocode
                         CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc]
                                                   initWithCoordinate:geocodedPlacemark.location.coordinate
                                                   addressDictionary:geocodedPlacemark.addressDictionary];
                         
                         // Create a map item for the geocoded address to pass to Maps app
                         MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                         [mapItem setName:geocodedPlacemark.name];
                         
                         // Set the directions mode to "Driving"
                         // Can use MKLaunchOptionsDirectionsModeWalking instead
                         NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                         
                         // Get the "Current User Location" MKMapItem
                         MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                         
                         // Pass the current location and destination map items to the Maps app
                         // Set the direction mode in the launchOptions dictionary
                         [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
                         
                     }];
    }
}

#pragma mark - InputCellDelegate

- (void)numberedTextViewDidChange:(UITextView *)textView
{
    _textViewText = textView.text;
    
    [AppDelegate user].protoEvent.updatedTitle = [AppDelegate user].protoEvent.existingTitle && ![_event.title isEqualToString:[AppDelegate user].protoEvent.existingTitle];
    
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
    [_tableView reloadData];
}

#pragma mark - TitleDateCellDelegate

- (void)titleDateCell:(TitleDateCell *)cell selectedResponse:(EventResponse)response
{
    NSMutableArray *responses = [[AppDelegate user].eventToDisplay[EVENT_RESPONSES_KEY] mutableCopy];
    NSString *objectToRemove;
    for (NSString *response in responses) {
        if ([response containsString:[AppDelegate user].email]) {
            objectToRemove = response;
        }
    }
    if (objectToRemove) {
        [responses removeObject:objectToRemove];
    }
    
    _response = response;

    [responses addObject:[NSString stringWithFormat:@"%@:%@", [AppDelegate user].email, @(_response)]];
    
    _inviteesSectionViewController.responses = responses;
    [_inviteesSectionViewController buildInviteesDictionary];
    [_inviteesSectionViewController.collectionView reloadData];
    
    [cell hideResponseButtons:_response];
    _responseCell.cellText.attributedText = [self attributedTextForReponse];
}

- (void)titleDateCellFinishedHideAnimation:(TitleDateCell *)cell
{
    _showingResponseSelection = NO;
}

@end
