//
//  TimeframeViewController.m
//  Invite
//
//  Created by Ryan Jennings on 2/19/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "TimeframeViewController.h"

#import "AppDelegate.h"
#import "BusyDetails.h"
#import "Event.h"
#import "StringConstants.h"
#import "Timeframe.h"

@interface TimeframeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *monthsView;
@property (nonatomic, weak) IBOutlet UICollectionView *daysView;
@property (nonatomic, weak) IBOutlet UITableView *hoursView;

@property (nonatomic, strong) Timeframe *timeframe;
@property (nonatomic, strong) NSMutableArray *busyTimes;
@end

@implementation TimeframeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Find event times that friends have committed to...
    // Buddy up friend with event name and time
    
    // Only check for busy times if the user has friends
    if ([AppDelegate user].friends) {
    
        _busyTimes = [NSMutableArray array];
        for (unsigned i = 0; i < 24; i++) {
            [_busyTimes addObject:[NSNull null]];
        }
        
        PFQuery *query = [PFQuery queryWithClassName:CLASS_EVENT_KEY];
        [query whereKey:EVENT_EMAILS_KEY containedIn:[AppDelegate user].friendEmails];
        [query includeKey:EVENT_INVITEES_KEY]; // Include invitees so that we can get their name and email
        [query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
            
            [events enumerateObjectsUsingBlock:^(PFObject *event, NSUInteger idx, BOOL *stop) {
                
                [[event objectForKey:EVENT_INVITEES_KEY] enumerateObjectsUsingBlock:^(PFObject *invitee, NSUInteger idx, BOOL *stop) {

                    if ([[AppDelegate user].protoEvent.inviteeEmails containsObject:[invitee objectForKey:EMAIL_KEY]]) {
                        
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"H"];
                        NSDate *startDate = [event objectForKey:EVENT_STARTDATE_KEY];
                        NSDate *endDate = [event objectForKey:EVENT_ENDDATE_KEY];
                        NSInteger startHour = [[formatter stringFromDate:startDate] integerValue];
                        NSTimeInterval length = [endDate timeIntervalSinceDate:startDate];
                        length = (length / 3600) + 1; // length in hours

                        for (NSInteger i = startHour; i < startHour + length; i++) {
                            if ([_busyTimes[i] isEqual:[NSNull null]]) {
                                _busyTimes[i] = [NSMutableDictionary dictionary];
                            }
                            [((NSMutableDictionary *)_busyTimes[i]) setValue:[BusyDetails busyDetailsWithPersonName:[invitee objectForKey:FULL_NAME_KEY] eventName:@"Event Name"] forKey:[invitee objectForKey:EMAIL_KEY]];
                        }
                    }
                }];
            }];
            [_hoursView reloadData];
        }];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventSuccessfullyCreated:) name:EVENT_CREATED_NOTIFICATION object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 24;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TIMEFRAME_HOUR_CELL_IDENTIFIER];
    long hour = indexPath.row % 12;
    if (hour == 0) hour = 12;
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", hour];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    if (_timeframe) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"H"];
        NSInteger start = [[formatter stringFromDate:_timeframe.start] integerValue];
        NSInteger end = [[formatter stringFromDate:_timeframe.end] integerValue];
        if (indexPath.row >= start && indexPath.row <= end) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    if (_busyTimes && ![_busyTimes[indexPath.row] isEqual:[NSNull null]]) {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    [components setDay:19];
    [components setMonth:2];
    [components setHour:indexPath.row];
    NSDate *date = [calendar dateFromComponents:components];
    
    // If no times have been selected yet...
    if (!_timeframe) {
        _timeframe = [Timeframe timeframe];
        _timeframe.start = date;
        _timeframe.end = date;
        [_hoursView reloadData];
        return;
    }
    
    // If only one time was selected, and we're reselecting that time...
    if ([date isEqualToDate:_timeframe.start] && [date isEqualToDate:_timeframe.end]) {
        _timeframe = nil;
        [_hoursView reloadData];
        return;
    }
    
    // If the time selected is already the set start time, move start time forward by an hour...
    if (![_timeframe.start isEqualToDate:_timeframe.end] && [date isEqualToDate:_timeframe.start]) {
        _timeframe.start = [_timeframe.start dateByAddingTimeInterval:3600]; // 3600 = 60 x 60
        [_hoursView reloadData];
        return;
    }
    
    // If the time selected is already the set end time, move end time back by an hour...
    if (![_timeframe.start isEqualToDate:_timeframe.end] && [date isEqualToDate:_timeframe.end]) {
        _timeframe.end = [_timeframe.end dateByAddingTimeInterval:-3600]; // 3600 = 60 x 60
        [_hoursView reloadData];
        return;
    }
    
    // If the time selected is earlier than the set start time...
    if ([[_timeframe.start earlierDate:date] isEqualToDate:date]) {
        _timeframe.start = date;
        [_hoursView reloadData];
        return;
    }
    
    // If the time selected is later than the set end time...
    if ([[_timeframe.end laterDate:date] isEqualToDate:date]) {
        _timeframe.end = date;
        [_hoursView reloadData];
        return;
    }
    
    // If the time selected is somewhere between the set start and end time...
    if ([[_timeframe.start earlierDate:date] isEqualToDate:_timeframe.start] && [[_timeframe.end laterDate:date] isEqualToDate:_timeframe.end]) {
        NSTimeInterval startInterval = [date timeIntervalSinceDate:_timeframe.start];
        NSTimeInterval endInterval = [_timeframe.end timeIntervalSinceDate:date];
        if (startInterval > endInterval) {
            _timeframe.end = date;
        } else {
            _timeframe.start = date;
        }
        [_hoursView reloadData];
        return;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString:SEGUE_TO_TIMEFRAME]) {
//        [AppDelegate user].eventPrototype = [Event createPrototype];
//    }
}

- (IBAction)createEvent:(id)sender
{
    [AppDelegate user].protoEvent.timeframe = _timeframe;
    [[AppDelegate user].protoEvent submitEvent];
}

#pragma mark - Notifications

- (void)eventSuccessfullyCreated:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Add event to local user
    if (![AppDelegate user].events) {
        [AppDelegate user].events = [NSArray array];
    }
    NSMutableArray *events = [[AppDelegate user].events mutableCopy];
    [events addObject:[AppDelegate user].protoEvent];
    [AppDelegate user].events = events;
    
    [AppDelegate user].protoEvent = nil;
}

@end
