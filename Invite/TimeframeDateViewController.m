//
//  TimeframeDateViewController.m
//  Invite
//
//  Created by Ryan Jennings on 4/13/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "TimeframeDateViewController.h"

#import "AppDelegate.h"
#import "BusyDetails.h"
#import "Event.h"
#import "EventViewController.h"
#import "Invite-Swift.h"
#import "StringConstants.h"
#import "Timeframe.h"
#import "TimeframeCollectionCell.h"
#import "TimeframeCollectionLayout.h"

@interface TimeframeDateViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *monthsView;
@property (nonatomic, weak) IBOutlet UICollectionView *daysView;
@property (nonatomic, weak) IBOutlet UICollectionView *hoursView;
@property (nonatomic, weak) IBOutlet UIView *headerView;

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

@implementation TimeframeDateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    _hoursView.backgroundColor = [UIColor clearColor];
    
    [self configureHeaderView];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat daysCellWidth = (screenRect.size.width - 4) / 5;
    CGFloat monthsCellWidth = (screenRect.size.width - 2) / 3;
    ((TimeframeCollectionLayout *)_daysView.collectionViewLayout).itemSize = CGSizeMake(daysCellWidth, 50.0);
    ((TimeframeCollectionLayout *)_monthsView.collectionViewLayout).itemSize = CGSizeMake(monthsCellWidth, 50.0);
    ((TimeframeCollectionLayout *)_hoursView.collectionViewLayout).itemSize = CGSizeMake(monthsCellWidth, 50.0);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _monthsView.delegate = nil;
    _daysView.delegate = nil;
    _hoursView.delegate = nil;
}

- (void)configureHeaderView
{
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor inviteQuestionColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.font = [UIFont inviteQuestionFont];
    label.text = _questionString;
    [_headerView addSubview:label];
    [_headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[label]-15-|" options:0 metrics:nil views:@{@"label": label}]];
    [_headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|" options:0 metrics:nil views:@{@"label": label}]];
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

- (void)turnAutoScrollingMonthsOff
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _autoScrollingMonths = NO;
    });
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
    } else if ([collectionView isEqual:_daysView]) {
        return 365;
    } else {
        return 48;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TimeframeCollectionCell *cell = (TimeframeCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TIMEFRAME_CELL_IDENTIFIER forIndexPath:indexPath];
    
    cell.label.alpha = 1;
    cell.label.textColor = [UIColor inviteDarkBlueColor];
    
    if ([collectionView isEqual:_monthsView]) {
        
        NSInteger item = indexPath.item;
        
        if ([self showingEarlierMonth]) {
            item--;
        }
        
        NSInteger month = [self monthForIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
        NSInteger year = [self yearForIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
        
        cell.label.font = [UIFont inviteTimeframeMonthFont];
        cell.label.text = [NSString stringWithFormat:@"%@ %ld", [self month:month], (long)year];
        
        cell.day = 1;
        cell.month = month;
        cell.year = year;
        
        if (indexPath.item == 0 || indexPath.item == 13) {
            cell.label.alpha = 0.1;
        } else if (_highlightMonthsCenterCell && indexPath.item == 1) {
            _highlightMonthsCenterCell = NO;
            cell.label.textColor = [UIColor inviteBlueColor];
        }
        
    } else if ([collectionView isEqual:_daysView]) {
        
        NSInteger day = [self dayForIndexPath:indexPath];
        
        cell.label.font = [UIFont inviteTimeframeDayFont];
        cell.label.text = [NSString stringWithFormat:@"%lu", (unsigned long)day];
        
        cell.day = day;
        cell.month = _monthForIndexPath;
        cell.year = _yearForIndexPath;
        
        if (indexPath.item < 2 || indexPath.item > 362) {
            cell.label.alpha = 0.1;
        } else if (_highlightDaysCenterCell && indexPath.item == 2) {
            _highlightDaysCenterCell = NO;
            cell.label.textColor = [UIColor inviteBlueColor];
        }
        
    } else {
        
        cell.label.font = [UIFont inviteTimeframeHourFont];
        cell.label.text = @"9:00 AM";
        
//        if (indexPath.item == 0 || indexPath.item == 13) {
//            cell.label.alpha = 0.1;
//        } else if (_highlightMonthsCenterCell && indexPath.item == 1) {
//            _highlightMonthsCenterCell = NO;
//            cell.label.textColor = [UIColor inviteBlueColor];
//        }
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
            
            cell.label.textColor = [UIColor inviteBlueColor];
        } else {
            cell.label.textColor = [UIColor inviteDarkBlueColor];
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
    return [scrollView isEqual:_monthsView] || [scrollView isEqual:_daysView] || [scrollView isEqual:_hoursView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self scrollViewIsCollectionView:scrollView]) {
        if ([scrollView isEqual:_monthsView]) {
            [self highlightCenteredCellInCollectionView:_monthsView];
        } else if ([scrollView isEqual:_daysView]) {
            [self highlightCenteredCellInCollectionView:_daysView];
        } else {
            [self highlightCenteredCellInCollectionView:_hoursView];
        }
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
    if ([self scrollViewIsCollectionView:scrollView] && ![scrollView isEqual:_hoursView]) {
        
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
