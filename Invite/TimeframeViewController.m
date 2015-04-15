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
#import "EventViewController.h"
#import "Invite-Swift.h"
#import "StringConstants.h"
#import "Timeframe.h"
#import "TimeframeDateViewController.h"
#import "TimeframeCollectionCell.h"
#import "TimeframeCollectionLayout.h"

// Convert GMT to systemTimeZone
// NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
// [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss Z"];
// [formatter setTimeZone:[NSTimeZone systemTimeZone]];
// NSLog(@"systemTimeZone %@", [formatter stringFromDate:date]);

@interface TimeframeViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) TimeframeDateViewController *startDateViewController;
@property (nonatomic, strong) TimeframeDateViewController *endDateViewController;
@property (nonatomic, weak) IBOutlet UITableView *conflictView;

@property (nonatomic, weak) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) Timeframe *timeframe;


@end

@implementation TimeframeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.navigationItem.titleView = [[ProgressView alloc] initWithFrame:CGRectMake(0, 0, 150, 15) step:3 steps:5];

    _nextButton.layer.cornerRadius = kCornerRadius;
    _nextButton.clipsToBounds = YES;
    _nextButton.titleLabel.font = [UIFont inviteButtonTitleFont];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_TO_START_DATE]) {
        _startDateViewController = (TimeframeDateViewController *)[segue destinationViewController];
        _startDateViewController.questionString = @"When will the event start?";
    } else if  ([segue.identifier isEqualToString:SEGUE_TO_END_DATE]) {
        _endDateViewController = (TimeframeDateViewController *)[segue destinationViewController];
        _endDateViewController.questionString = @"When will it end?";
    }
}

#pragma mark - UITableView

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.textColor = [UIColor inviteTableHeaderColor];
    headerView.textLabel.font = [UIFont inviteTableHeaderFont];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *footerView = (UITableViewHeaderFooterView *)view;
    footerView.textLabel.font = [UIFont inviteTableFooterFont];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        default:
            return @"Select Time";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        default:
            return @"Note: To have an event span multiple days, simply switch days, then select the end time.";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeframeHourCell *cell = (TimeframeHourCell *)[tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER];

//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    cell.backgroundColor = [UIColor whiteColor];
//    
//    bool (^withinHour)(id startEnd) = ^bool(Timeframe *startEnd) {
//        NSDate *thisHour = [self dateFromDay:_selectedDay month:_selectedMonth year:_selectedYear hour:indexPath.row];
//        return (([[startEnd.start earlierDate:thisHour] isEqualToDate:startEnd.start] && [[startEnd.end laterDate:thisHour] isEqualToDate:startEnd.end]) ||
//                [startEnd.start isEqualToDate:thisHour] ||
//                [startEnd.end isEqualToDate:thisHour]);
//    };
//    
//    if (_timeframe && withinHour(_timeframe)) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
//    
//    NSSet *relavantBusyTimes = [[AppDelegate user].busyTimes objectsPassingTest:^BOOL(BusyDetails *busy, BOOL *stop) {
//        return [busy.startBaseDate isEqualToDate:[self dateForSelectedComponents]] || [busy.endBaseDate isEqualToDate:[self dateForSelectedComponents]];
//    }];
//
//    NSMutableArray *unavailablePersons = [[NSMutableArray alloc] init];
//    for (BusyDetails *busyDetail in relavantBusyTimes) {
//        [[AppDelegate user].protoEvent.invitees enumerateObjectsUsingBlock:^(PFObject *person, BOOL *stop) {
//            if ([busyDetail.email isEqualToString:[person objectForKey:EMAIL_KEY]] && withinHour(busyDetail)) {
//                [unavailablePersons addObject:busyDetail.name];
//            }
//        }];
//    }
//    
//    if (unavailablePersons.count) {
//        cell.label.text = @"Someone is unavailable.";
//        cell.label.textColor = [UIColor inviteTableLabelColor];
//        cell.circleColor = [UIColor inviteLightSlateColor];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    } else if ([AppDelegate user].protoEvent.invitees.count && unavailablePersons.count == [AppDelegate user].protoEvent.invitees.count) {
//        cell.label.text = @"All Invite guests are unavailable!";
//        cell.label.textColor = [UIColor inviteRedColor];
//        cell.circleColor = [UIColor redColor];
//    } else {
//        cell.label.text = @"Everyone is available.";
//        cell.label.textColor = [UIColor inviteGreenColor];
//        cell.circleColor = [UIColor inviteGreenColor];
//    }
//
//    cell.label.font = [UIFont inviteTimeframeTableLabelFont];
//
//    long hour = indexPath.row % 12;
//    if (hour == 0) hour = 12;
//    cell.hourLabel.text = [NSString stringWithFormat:@"%ld", hour];
//    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSDate *date = [self dateFromDay:_selectedDay month:_selectedMonth year:_selectedYear hour:indexPath.row];
//    NSDate *baseDate = [self dateForSelectedComponents];
//    
//    NSLog(@"%@", date);
//
//    // If no times have been selected yet...
//    if (!_timeframe) {
//        _timeframe = [Timeframe timeframe];
//        [self saveStartDate:date withBaseDate:baseDate];
//        [self saveEndDate:date withBaseDate:baseDate];
//        [_hoursView reloadData];
//        return;
//    }
//    
//    // If only one time was selected, and we're reselecting that time...
//    if ([date isEqualToDate:_timeframe.start] && [date isEqualToDate:_timeframe.end]) {
//        _timeframe = nil;
//        [_hoursView reloadData];
//        return;
//    }
//    
//    // If the time selected is already the set start time, move start time forward by an hour...
//    if (![_timeframe.start isEqualToDate:_timeframe.end] && [date isEqualToDate:_timeframe.start]) {
//        [self saveStartDate:[_timeframe.start dateByAddingTimeInterval:3600] withBaseDate:baseDate];
//        [_hoursView reloadData];
//        return;
//    }
//    
//    // If the time selected is already the set end time, move end time back by an hour...
//    if (![_timeframe.start isEqualToDate:_timeframe.end] && [date isEqualToDate:_timeframe.end]) {
//        [self saveEndDate:[_timeframe.end dateByAddingTimeInterval:-3600] withBaseDate:baseDate];
//        [_hoursView reloadData];
//        return;
//    }
//    
//    // If the time selected is earlier than the set start time...
//    if ([[_timeframe.start earlierDate:date] isEqualToDate:date]) {
//        [self saveStartDate:date withBaseDate:baseDate];
//        [_hoursView reloadData];
//        return;
//    }
//    
//    // If the time selected is later than the set end time...
//    if ([[_timeframe.end laterDate:date] isEqualToDate:date]) {
//        [self saveEndDate:date withBaseDate:baseDate];
//        [_hoursView reloadData];
//        return;
//    }
//    
//    // If the time selected is somewhere between the set start and end time...
//    if ([[_timeframe.start earlierDate:date] isEqualToDate:_timeframe.start] && [[_timeframe.end laterDate:date] isEqualToDate:_timeframe.end]) {
//        NSTimeInterval startInterval = [date timeIntervalSinceDate:_timeframe.start];
//        NSTimeInterval endInterval = [_timeframe.end timeIntervalSinceDate:date];
//        if (startInterval > endInterval) {
//            [self saveEndDate:date withBaseDate:baseDate];
//        } else {
//            [self saveStartDate:date withBaseDate:baseDate];
//        }
//        [_hoursView reloadData];
//        return;
//    }
}

#pragma mark - IBActions

- (IBAction)cancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)next:(id)sender
{
    [AppDelegate user].protoEvent.timeframe = _timeframe;
    [self performSegueWithIdentifier:SEGUE_TO_LOCATION sender:self];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

#pragma mark - NSDate

- (void)saveStartDate:(NSDate *)date withBaseDate:(NSDate *)baseDate
{
    _timeframe.start = date;
    _timeframe.startBaseDate = baseDate;
}

- (void)saveEndDate:(NSDate *)date withBaseDate:(NSDate *)baseDate
{
    _timeframe.end = date;
    _timeframe.endBaseDate = baseDate;
}

//- (NSDate *)dateForSelectedComponents
//{
//    return [self dateFromDay:_selectedDay month:_selectedMonth year:_selectedYear hour:0];
//}

- (NSDate *)dateFromDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year hour:(NSInteger)hour
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    if (hour > 0) {
        [components setHour:hour];
    }
    return [calendar dateFromComponents:components];
}

@end
