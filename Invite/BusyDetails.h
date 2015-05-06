//
//  BusyDetails.h
//  Invite
//
//  Created by Ryan Jennings on 2/21/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BusyDetailsCircle) {
    BusyDetailsCircleRedGreen,
    BusyDetailsCircleRed,
    BusyDetailsCircleGreenRed,
    BusyDetailsCircleGreen
};

@interface BusyDetails : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *eventTitle;
@property (nonatomic, assign) NSInteger eventResponse;
@property (nonatomic, strong) NSDate *startBaseDate;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *endBaseDate;
@property (nonatomic, strong) NSDate *end;

@property (nonatomic, assign) BusyDetailsCircle circle;

+ (BusyDetails *)busyDetailsWithName:(NSString *)name
                               email:(NSString *)email
                          eventTitle:(NSString *)eventTitle
                       eventResponse:(NSInteger)eventResponse
                               start:(NSDate *)start
                       startBaseDate:(NSDate *)startBaseDate
                                 end:(NSDate *)end
                         endBaseDate:(NSDate *)endBaseDate;

@end
