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
#import "StringConstants.h"
#import "Timeframe.h"
#import "TimeframeCollectionCell.h"
#import "TimeframeCollectionLayout.h"

// Convert GMT to systemTimeZone
// NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
// [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss Z"];
// [formatter setTimeZone:[NSTimeZone systemTimeZone]];
// NSLog(@"systemTimeZone %@", [formatter stringFromDate:date]);

NSString *const TimeframeCollectionCellId = @"TimeframeCollectionCellId";

@interface TimeframeViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *monthsView;
@property (nonatomic, weak) IBOutlet UICollectionView *daysView;
@property (nonatomic, weak) IBOutlet UITableView *hoursView;

@property (nonatomic, strong) Timeframe *timeframe;

@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger year;

@property (nonatomic, assign) NSInteger selectedDay;
@property (nonatomic, assign) NSInteger selectedMonth;
@property (nonatomic, assign) NSInteger selectedYear;

@property (nonatomic, assign) NSInteger monthForIndexPath;
@property (nonatomic, assign) NSInteger yearForIndexPath;
@property (nonatomic, assign) NSInteger lastMonth;

@property (nonatomic, assign) NSInteger dayBeforeScroll;
@property (nonatomic, assign) NSInteger monthBeforeScroll;
@property (nonatomic, assign) NSInteger yearBeforeScroll;

@property (nonatomic, strong) NSMutableArray *firstDayIndexPaths;

@property (nonatomic, assign) BOOL highlightMonthsCenterCell;
@property (nonatomic, assign) BOOL highlightDaysCenterCell;
@property (nonatomic, assign) BOOL shouldScrollDays;
@property (nonatomic, assign) BOOL shouldScrollMonths;
@property (nonatomic, assign) BOOL autoScrollingMonths;

@end

@implementation TimeframeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;

    NSDate *today = [NSDate date];
    NSDate *twoDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-172800];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:today];
    NSDateComponents *twoDaysAgoComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:twoDaysAgo];
    
    _day = twoDaysAgoComponents.day;
    _month = twoDaysAgoComponents.month;
    _year = twoDaysAgoComponents.year;
    
    [self createFirstDayIndexPaths];
    
    _selectedDay = todayComponents.day;
    _selectedMonth = todayComponents.month;
    _selectedYear = todayComponents.year;
    
    _lastMonth = _selectedMonth;
    _dayBeforeScroll = _selectedDay;
    _monthBeforeScroll = _selectedMonth;
    _yearBeforeScroll = _selectedYear;
    
    _highlightMonthsCenterCell = YES;
    _highlightDaysCenterCell = YES;
    _shouldScrollDays = YES;
    _shouldScrollMonths = YES;
    _autoScrollingMonths = NO;
    
    _daysView.backgroundColor = [UIColor clearColor];
    _monthsView.backgroundColor = [UIColor clearColor];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat daysCellWidth = (screenRect.size.width - 4) / 5;
    CGFloat monthsCellWidth = (screenRect.size.width - 2) / 3;
    ((TimeframeCollectionLayout *)_daysView.collectionViewLayout).itemSize = CGSizeMake(daysCellWidth, 50.0);
    ((TimeframeCollectionLayout *)_monthsView.collectionViewLayout).itemSize = CGSizeMake(monthsCellWidth, 50.0);    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _monthsView.delegate = nil;
    _daysView.delegate = nil;
    _hoursView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers

- (void)createFirstDayIndexPaths
{
    _firstDayIndexPaths = [NSMutableArray array];
    for (unsigned i = 0; i < 12; i++) {
        [_firstDayIndexPaths addObject:[NSNull null]];
    }
    NSInteger month = _month;
    for (unsigned i = 0; i < 365; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        if (i == 0 && _day != 1) {
            [_firstDayIndexPaths replaceObjectAtIndex:(month - 1) withObject:indexPath];
            NSLog(@"%ld %ld", (month - 1), (long)indexPath.item);
            continue;
        }
        if ([self dayForIndexPath:indexPath] == 1) {
            month++;
            if (month > 12) {
                month = 1;
            }
            [_firstDayIndexPaths replaceObjectAtIndex:(month - 1) withObject:indexPath];
            NSLog(@"%ld %ld", (month - 1), (long)indexPath.item);
        }
    }
}

- (NSString *)month:(NSInteger)m
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

- (NSInteger)daysInMonth:(NSInteger)m forYear:(NSInteger)y
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

- (BOOL)showingEarlierMonth
{
    return _day < [self daysInMonth:_month forYear:_year] - 1;
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
    NSMutableString *labelText = [[NSMutableString alloc] init];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TIMEFRAME_HOUR_CELL_IDENTIFIER];
    long hour = indexPath.row % 12;
    if (hour == 0) hour = 12;
    [labelText appendFormat:@"%ld", hour];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    bool (^withinHour)(id startEnd) = ^bool(Timeframe *startEnd) {
        NSDate *thisHour = [self dateFromDay:_selectedDay month:_selectedMonth year:_selectedYear hour:indexPath.row];
        return (([[startEnd.start earlierDate:thisHour] isEqualToDate:startEnd.start] && [[startEnd.end laterDate:thisHour] isEqualToDate:startEnd.end]) ||
                [startEnd.start isEqualToDate:thisHour] ||
                [startEnd.end isEqualToDate:thisHour]);
    };
    
    if (_timeframe && withinHour(_timeframe)) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    NSSet *relavantBusyTimes = [[AppDelegate user].busyTimes objectsPassingTest:^BOOL(BusyDetails *busy, BOOL *stop) {
        return [busy.startBaseDate isEqualToDate:[self dateForSelectedComponents]] || [busy.endBaseDate isEqualToDate:[self dateForSelectedComponents]];
    }];

    for (BusyDetails *busyDetail in relavantBusyTimes) {
        [[AppDelegate user].protoEvent.invitees enumerateObjectsUsingBlock:^(PFObject *person, BOOL *stop) {
            if ([busyDetail.email isEqualToString:[person objectForKey:EMAIL_KEY]] && withinHour(busyDetail)) {
                cell.backgroundColor = [UIColor lightGrayColor];
                [labelText appendFormat:@" %@", busyDetail.email];
            }
        }];
    }

    cell.textLabel.text = labelText;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = [self dateFromDay:_selectedDay month:_selectedMonth year:_selectedYear hour:indexPath.row];
    NSDate *baseDate = [self dateForSelectedComponents];
    
    NSLog(@"%@", date);

    // If no times have been selected yet...
    if (!_timeframe) {
        _timeframe = [Timeframe timeframe];
        [self saveStartDate:date withBaseDate:baseDate];
        [self saveEndDate:date withBaseDate:baseDate];
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
        [self saveStartDate:[_timeframe.start dateByAddingTimeInterval:3600] withBaseDate:baseDate];
        [_hoursView reloadData];
        return;
    }
    
    // If the time selected is already the set end time, move end time back by an hour...
    if (![_timeframe.start isEqualToDate:_timeframe.end] && [date isEqualToDate:_timeframe.end]) {
        [self saveEndDate:[_timeframe.end dateByAddingTimeInterval:-3600] withBaseDate:baseDate];
        [_hoursView reloadData];
        return;
    }
    
    // If the time selected is earlier than the set start time...
    if ([[_timeframe.start earlierDate:date] isEqualToDate:date]) {
        [self saveStartDate:date withBaseDate:baseDate];
        [_hoursView reloadData];
        return;
    }
    
    // If the time selected is later than the set end time...
    if ([[_timeframe.end laterDate:date] isEqualToDate:date]) {
        [self saveEndDate:date withBaseDate:baseDate];
        [_hoursView reloadData];
        return;
    }
    
    // If the time selected is somewhere between the set start and end time...
    if ([[_timeframe.start earlierDate:date] isEqualToDate:_timeframe.start] && [[_timeframe.end laterDate:date] isEqualToDate:_timeframe.end]) {
        NSTimeInterval startInterval = [date timeIntervalSinceDate:_timeframe.start];
        NSTimeInterval endInterval = [_timeframe.end timeIntervalSinceDate:date];
        if (startInterval > endInterval) {
            [self saveEndDate:date withBaseDate:baseDate];
        } else {
            [self saveStartDate:date withBaseDate:baseDate];
        }
        [_hoursView reloadData];
        return;
    }
}

- (void)turnAutoScrollingMonthsOff
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _autoScrollingMonths = NO;
    });
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_TO_EVENT]) {
        [AppDelegate user].protoEvent.timeframe = _timeframe;
    }
}

#pragma mark - IBActions

- (IBAction)cancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:_monthsView]) {
        return 14;
    } else {
        return 365;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TimeframeCollectionCell *cell = (TimeframeCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TimeframeCollectionCellId forIndexPath:indexPath];
    
    cell.label.alpha = 1;
    
    if ([collectionView isEqual:_monthsView]) {
        
        NSInteger item = indexPath.item;
        
        if ([self showingEarlierMonth]) {
            item--;
        }
        
        NSInteger month = [self monthForIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
        NSInteger year = [self yearForIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
        
        cell.label.text = [NSString stringWithFormat:@"%@ %ld", [self month:month], (long)year];
        
        cell.day = 1;
        cell.month = month;
        cell.year = year;
        
        if (indexPath.item == 0 || indexPath.item == 13) {
            cell.label.alpha = 0.1;
        } else if (_highlightMonthsCenterCell && indexPath.item == 1) {
            _highlightMonthsCenterCell = NO;
            cell.label.textColor = [UIColor redColor];
        }
        
    } else {
        
        NSInteger day = [self dayForIndexPath:indexPath];
        
        cell.label.text = [NSString stringWithFormat:@"%lu", (unsigned long)day];
        
        cell.day = day;
        cell.month = _monthForIndexPath;
        cell.year = _yearForIndexPath;
        
        if (indexPath.item < 2 || indexPath.item > 362) {
            cell.label.alpha = 0.1;
        } else if (_highlightDaysCenterCell && indexPath.item == 2) {
            _highlightDaysCenterCell = NO;
            cell.label.textColor = [UIColor redColor];
        }
        
    }
    return cell;
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//}

- (void)highlightCenteredCellInCollectionView:(UICollectionView *)view
{
    [[view visibleCells] enumerateObjectsUsingBlock:^(TimeframeCollectionCell *cell, NSUInteger idx, BOOL *stop) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGPoint viewCenter = CGPointMake((screenRect.size.width / 2) + view.contentOffset.x, cell.frame.origin.y + (cell.frame.size.height / 2));
        
        if (cell.center.x > viewCenter.x - 5 &&
            cell.center.x < viewCenter.x + 5 &&
            cell.center.y == viewCenter.y) {
            
            if (_selectedDay != cell.day || _selectedMonth != cell.month) {
                
                if (!_autoScrollingMonths) {
                    _selectedDay = cell.day;
                    _selectedMonth = cell.month;
                    _selectedYear = cell.year;
                    NSLog(@"%ld/%ld/%ld", (long)_selectedMonth, (long)_selectedDay, (long)_selectedYear);
                }
                
            }
            
            cell.label.textColor = [UIColor redColor];
        } else {
            cell.label.textColor = [UIColor blackColor];
        }
    }];
}

#pragma mark - IndexPath Methods

- (NSInteger)dayForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger day = indexPath.item;
    NSInteger remainingDays = [self daysInMonth:_month forYear:_year] - _day;
    
    if (day > remainingDays) {
        
        day -= remainingDays;
        
        NSArray *(^nextMonth)(NSInteger add) = ^NSArray *(NSInteger add) {
            NSInteger nextMonth = _month + add;
            NSInteger yearForNextMonth = _year;
            if (nextMonth > 12) {
                nextMonth -= 12;
                yearForNextMonth = _year + 1;
            }
            return [NSArray arrayWithObjects:@(nextMonth), @(yearForNextMonth), @([self daysInMonth:nextMonth forYear:yearForNextMonth]), nil];
        };
        
        unsigned add;
        NSArray *monthYearDays;
        for (add = 1, monthYearDays = nextMonth(add);
             day > [monthYearDays[2] integerValue];
             add++, monthYearDays = nextMonth(add)) {
            
            day -= [monthYearDays[2] integerValue];
            
        }

        _monthForIndexPath = [monthYearDays[0] integerValue];
        _yearForIndexPath = [monthYearDays[1] integerValue];

        return day;
        
    } else {
        
        _monthForIndexPath = _month;
        _yearForIndexPath = _year;
        
        return day + _day;
        
    }
}

- (NSInteger)monthForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger month = _month + indexPath.item;
    if (month > 12) {
        month -= 12;
    }
    return month;
}

- (NSIndexPath *)indexPathForMonth:(NSInteger)month year:(NSInteger)year
{
    for (unsigned i = 0; i < 12; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        if (month == [self monthForIndexPath:indexPath]) {
            return [self showingEarlierMonth] ? [NSIndexPath indexPathForItem:(i + 1) inSection:0] : indexPath;
        }
    }
    return [NSIndexPath indexPathForItem:0 inSection:0];
}

- (NSInteger)yearForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger month = _month + indexPath.item;
    NSInteger year = _year;
    if (month > 12) {
        year++;
    }
    return year;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

#pragma mark - UIScrollViewDelegate

- (BOOL)scrollViewIsCollectionView:(UIScrollView *)scrollView
{
    return [scrollView isEqual:_monthsView] || [scrollView isEqual:_daysView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self scrollViewIsCollectionView:scrollView]) {
        [self highlightCenteredCellInCollectionView:([scrollView isEqual:_daysView] ? _daysView : _monthsView)];
    }
}

- (NSInteger)daysSelectedValue
{
    __block NSInteger i = 0;
    
    [[_daysView visibleCells] enumerateObjectsUsingBlock:^(TimeframeCollectionCell *cell, NSUInteger idx, BOOL *stop) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGPoint viewCenter = CGPointMake((screenRect.size.width / 2) + _daysView.contentOffset.x, cell.frame.origin.y + (cell.frame.size.height / 2));
        
        if (cell.center.x > viewCenter.x - 5 &&
            cell.center.x < viewCenter.x + 5 &&
            cell.center.y == viewCenter.y) {
            i = [cell.label.text integerValue];
        }
    }];
    
    return i;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self scrollViewIsCollectionView:scrollView]) {
        
        NSInteger daysSelectedValue = [self daysSelectedValue];
        if (_dayBeforeScroll == daysSelectedValue &&
            _monthBeforeScroll == _selectedMonth &&
            _yearBeforeScroll == _selectedYear) {
            _selectedDay = daysSelectedValue;
            NSLog(@"%ld/%ld/%ld", (long)_selectedMonth, (long)_selectedDay, (long)_selectedYear);
            return;
        }
        
        _shouldScrollDays = _lastMonth != _selectedMonth;
        _shouldScrollMonths = _lastMonth != _selectedMonth;
        _lastMonth = _selectedMonth;
        
        _dayBeforeScroll = _selectedDay;
        _monthBeforeScroll = _selectedMonth;
        _yearBeforeScroll = _selectedYear;

        if ([scrollView isEqual:_monthsView]) {
            if (_shouldScrollDays) {
                [_hoursView reloadData];
                [_daysView scrollToItemAtIndexPath:_firstDayIndexPaths[_selectedMonth - 1] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            }
        } else {
            if (_shouldScrollMonths) {
                _autoScrollingMonths = YES;
                [self turnAutoScrollingMonthsOff];
                [_hoursView reloadData];
                [_monthsView scrollToItemAtIndexPath:[self indexPathForMonth:_selectedMonth year:_selectedYear] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            }
        }
        
        if (!_shouldScrollDays && !_shouldScrollMonths) {
            [_hoursView reloadData];
        }
    }
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

- (NSDate *)dateForSelectedComponents
{
    return [self dateFromDay:_selectedDay month:_selectedMonth year:_selectedYear hour:0];
}

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
