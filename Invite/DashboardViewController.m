//
//  DashboardViewController.m
//  Invite
//
//  Created by Ryan Jennings on 2/11/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "DashboardViewController.h"

#import "AppDelegate.h"
#import "Event.h"

@interface DashboardViewController ()
@property (nonatomic, weak) IBOutlet UIButton *addNewEventButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *settingsButton;
@end

@implementation DashboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_addNewEventButton setTitle:NSLocalizedString(@"dashboard_button_addnewevent", nil) forState:UIControlStateNormal];
    [_settingsButton setTitle:NSLocalizedString(@"navigation_button_settings", nil)];
}

- (IBAction)settings:(id)sender
{
    
}

- (IBAction)addNewEvent:(id)sender
{
    [Event addEventToUser:[AppDelegate app].inviteUser];
}

@end
