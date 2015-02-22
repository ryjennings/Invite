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
@property (nonatomic, strong) NSString *eventName;

+ (BusyDetails *)busyDetailsWithPersonName:(NSString *)personName eventName:(NSString *)eventName;

@end
