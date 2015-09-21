//
//  EventViewController.h
//  Invite
//
//  Created by Ryan Jennings on 3/6/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface EventViewController : UIViewController

@property (nonatomic, strong) PFObject *parseEvent;

@end
