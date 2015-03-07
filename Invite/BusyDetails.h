//
//  BusyDetails.h
//  Invite
//
//  Created by Ryan Jennings on 2/21/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusyDetails : NSObject

@property (nonatomic, strong) NSString *personName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSDate *startBaseDate;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *endBaseDate;
@property (nonatomic, strong) NSDate *end;

+ (BusyDetails *)busyDetailsWithPersonName:(NSString *)personName
                                     email:(NSString *)email
                                 eventName:(NSString *)eventName
                                     start:(NSDate *)start
                             startBaseDate:(NSDate *)startBaseDate
                                       end:(NSDate *)end
                               endBaseDate:(NSDate *)endBaseDate;

@end
