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
#import "TimeframeCollectionCell.h"

NSString *const TimeframeCollectionCellId = @"TimeframeCollectionCellId";

@interface TimeframeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *monthsView;
@property (nonatomic, weak) IBOutlet UICollectionView *daysView;
@property (nonatomic, weak) IBOutlet UITableView *hoursView;

@property (nonatomic, strong) Timeframe *timeframe;
@property (nonatomic, strong) NSMutableArray *busyTimes;

@property (nonatomic, assign) NSUInteger day;
@property (nonatomic, assign) NSUInteger month;
@property (nonatomic, assign) NSUInteger year;
@property (nonatomic, assign) NSUInteger hour;
@property (nonatomic, assign) NSUInteger quarter;

@end

@implementation TimeframeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    
    _day = components.day;
    _month = components.month;
    _year = components.year;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventSuccessfullyCreated:) name:EVENT_CREATED_NOTIFICATION object:nil];
}

- (NSString *)month:(NSUInteger)m
{
    switch (m) {
        case 1: return @"January";
        case 2: return @"Februrary";
        case 3: return @"March";
        case 4: return @"April";
        case 5: return @"May";
        case 6: return @"June";
        case 7: return @"July";
        case 8: return @"August";
        case 9: return @"September";
        case 10: return @"October";
        case 11: return @"November";
        default: return @"December";
    }
}

- (NSUInteger)daysInMonth:(NSUInteger)m forYear:(NSUInteger)y
{
    switch (m) {
        case 1: return 31;
        case 2:
        {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.year = y;
            components.month = 2;
            components.day = 1;
            NSDate *februaryDate = [calendar dateFromComponents:components];
            return [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:februaryDate].length;
        }
        case 3: return 31;
        case 4: return 30;
        case 5: return 31;
        case 6: return 30;
        case 7: return 31;
        case 8: return 31;
        case 9: return 30;
        case 10: return 31;
        case 11: return 30;
        default: return 31;
    }
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

- (IBAction)cancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications

- (void)eventSuccessfullyCreated:(NSNotification *)notification
{
    [AppDelegate user].protoEvent = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:_monthsView]) {
        return 12;
    } else {
        return 365;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TimeframeCollectionCell *cell = (TimeframeCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TimeframeCollectionCellId forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self dayForIndexPath:indexPath]];
    return cell;
}

- (NSUInteger)dayForIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger item = indexPath.item;
    NSUInteger remainingDays = [self daysInMonth:_month forYear:_year] - _day;
    
    if (item > remainingDays) {
        item -= remainingDays;
        
        unsigned i = 1;
        NSUInteger daysInMonth = [self daysInMonth:_month + i forYear:_year];
        while (item > daysInMonth) {
            item -= daysInMonth;
            i++;
        }
    } else {
        return item + _day;
    }

    return item;
}

@end
