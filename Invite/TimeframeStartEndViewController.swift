////
////  TimeframeStartEndViewController.swift
////  Invite
////
////  Created by Ryan Jennings on 4/13/15.
////  Copyright (c) 2015 Appuous. All rights reserved.
////
//
//import UIKit
//
//@objc(TimeframeStartEndViewController) class TimeframeStartEndViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
//{
//    @IBOutlet weak var headerView: UIView!
//    @IBOutlet weak var monthView: UICollectionView!
//    @IBOutlet weak var dayView: UICollectionView!
//    @IBOutlet weak var hourView: UICollectionView!
//    
//    var day: NSInteger!
//    var month: NSInteger!
//    var year: NSInteger!
//    
//    var selectedDay: NSInteger!
//    var selectedMonth: NSInteger!
//    var selectedYear: NSInteger!
//    
//    var monthForIndexPath: NSInteger!
//    var yearForIndexPath: NSInteger!
//    var lastMonth: NSInteger!
//    
//    var dayBeforeScroll: NSInteger!
//    var monthBeforeScroll: NSInteger!
//    var yearBeforeScroll: NSInteger!
//    
//    var firstDayIndexPaths: [AnyObject]!
//    
//    var highlightMonthsCenterCell = true
//    var highlightDaysCenterCell = true
//    var shouldScrollDays = true
//    var shouldScrollMonths = true
//    var autoScrollingMonths = false
//
//    var label: UILabel!
//    
//    var questionText: String! {
//        didSet {
//            label.text = questionText
//        }
//    }
//    
//    override func viewDidLoad()
//    {
//        super.viewDidLoad()
//        
//        let today = NSDate()
//        let twoDaysAgo = NSDate(timeIntervalSinceNow: -172800)
//        let calendar = NSCalendar.currentCalendar()
//        let todayComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: today)
//        let twoDaysAgoComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: twoDaysAgo)
//        
//        day = twoDaysAgoComponents.day
//        month = twoDaysAgoComponents.month
//        year = twoDaysAgoComponents.year
//        
//        createFirstDayIndexPaths()
//        
//        selectedDay = todayComponents.day
//        selectedMonth = todayComponents.month
//        selectedYear = todayComponents.year
//        
//        lastMonth = selectedMonth
//        dayBeforeScroll = selectedDay
//        monthBeforeScroll = selectedMonth
//        yearBeforeScroll = selectedYear
//        
//        monthView.backgroundColor = UIColor.clearColor()
//        dayView.backgroundColor = UIColor.clearColor()
//        
//        configureHeaderView()
//        
//        let screenRect = UIScreen.mainScreen().bounds
//        let daysCellWidth = (screenRect.size.width - 4) / 5
//        let monthsCellWidth = (screenRect.size.width - 2) / 3
//        
//        (monthView.collectionViewLayout as! TimeframeCollectionLayout).itemSize = CGSizeMake(daysCellWidth, 50.0)
//        (dayView.collectionViewLayout as! TimeframeCollectionLayout).itemSize = CGSizeMake(daysCellWidth, 50.0)
//        (hourView.collectionViewLayout as! TimeframeCollectionLayout).itemSize = CGSizeMake(daysCellWidth, 50.0)
//    }
//    
//    override func viewDidDisappear(animated: Bool)
//    {
//        super.viewDidDisappear(animated)
//        monthView.delegate = nil
//        dayView.delegate = nil
//        hourView.delegate = nil
//    }
//    
//    func configureHeaderView()
//    {
//        label = UILabel()
//        label.setTranslatesAutoresizingMaskIntoConstraints(false)
//        label.backgroundColor = UIColor.clearColor()
//        label.textColor = UIColor.inviteQuestionColor()
//        label.textAlignment = .Center
//        label.numberOfLines = 0
//        label.font = UIFont.inviteQuestionFont()
//        
//        headerView.addSubview(label)
//        headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[label]-15-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["label": label]))
//        headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["label": label]))
//    }
//    
//    func createFirstDayIndexPaths()
//    {
//        firstDayIndexPaths = [AnyObject](count: 12, repeatedValue: NSNull())
//        var thisMonth = month
//        
//        for i in 0..<365 {
//            let indexPath = NSIndexPath(forItem: i, inSection: 0)
//            if (i == 0 && day != 1) {
//                firstDayIndexPaths[month - 1] = indexPath
//                continue
//            }
////            if (dayForIndexPath(indexPath) == 1) {
////                month = (month + 1) % 12
////                firstDayIndexPaths[month - 1] = indexPath
////            }
//        }
//    }
//    
//    func month(m: Int) -> String
//    {
//        switch m {
//        case 1: return "January"
//        case 2: return "Februrary"
//        case 3: return "March"
//        case 4: return "April"
//        case 5: return "May"
//        case 6: return "June"
//        case 7: return "July"
//        case 8: return "August"
//        case 9: return "September"
//        case 10: return "October"
//        case 11: return "November"
//        default: return "December"
//        }
//    }
//    
//    func daysInMonth(m: Int, forYear y: Int) -> Int
//    {
//        switch m {
//        case 1: return 31
//        case 2:
//            let calendar = NSCalendar.currentCalendar()
//            var components = NSDateComponents()
//            components.year = y
//            components.month = 2
//            components.day = 1
//            let februaryDate = calendar.dateFromComponents(components)
////            return calendar.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: februaryDate).length
//        case 3: return 31
//        case 4: return 30
//        case 5: return 31
//        case 6: return 30
//        case 7: return 31
//        case 8: return 31
//        case 9: return 30
//        case 10: return 31
//        case 11: return 30
//        default: return 31
//        }
//    }
//    
//    func showingEarlierMonth() -> Bool
//    {
////        return day < daysInMonth(month forYear:year) - 1
//    }
//    
//    func turnAutoScrollingMonthsOff()
//    {
//        dispatch_after(
//            dispatch_time(
//                DISPATCH_TIME_NOW,
//                Int64(0.5 * Double(NSEC_PER_SEC))
//            ),
//            dispatch_get_main_queue()) {
//                self.autoScrollingMonths = false
//        }
//    }
//    
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
//    {
//        return 1
//    }
//    
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
//    {
//        switch collectionView {
//        case monthView:
//            return 14
//        case dayView:
//            return 365
//        case hourView:
//            return 48
//        }
//    }
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
//    {
//        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(TIMEFRAME_CELL_IDENTIFIER, forIndexPath: indexPath) as! TimeframeCollectionCell
//        cell.label.alpha = 1
//        cell.label.textColor = UIColor.inviteDarkBlueColor()
//        
//        if (collectionView === monthView) {
//            var item = indexPath.item
//            
//            if (showingEarlierMonth()) {
//                item--
//            }
//            
//// FINISH!!!!!!!            month =
//        }
//    }
//    
//    func scrollViewIsCollectionView(scrollView: UIScrollView) -> Bool
//    {
//        return scrollView === monthView || scrollView === dayView || scrollView === hourView
//    }
//    
//    func daysSelectedValue() -> Int
//    {
//        var i = 0
//        for cell in dayView.visibleCells() {
//            let thisCell = cell as! TimeframeCollectionCell
//            let screenRect = UIScreen.mainScreen().bounds
//            let viewCenter = CGPointMake((screenRect.size.width / 2) + dayView.contentOffset.x, cell.frame.origin.y + (cell.frame.size.height / 2))
//            if (cell.center.x > viewCenter.x - 5 &&
//                cell.center.x < viewCenter.x + 5 &&
//                cell.center.y == viewCenter.y) {
////                    let text = cell.label.text as String
////                    i = text.toInt()
//            }
//        }
//        return i
//    }
//    
//    // MARK: - UIScrollViewDelegate
//    
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
//    {
//        if (scrollViewIsCollectionView(scrollView)) {
//        }
//    }
//    
////    func dayForIndexPath(indexPath: NSIndexPath)
//}
