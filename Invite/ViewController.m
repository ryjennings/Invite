//
//  ViewController.m
//  Invite
//
//  Created by Ryan Jennings on 2/9/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "ViewController.h"

#import <FacebookSDK/FacebookSDK.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    FBLoginView *loginView = [[FBLoginView alloc] init];
    loginView.center = self.view.center;
    [self.view addSubview:loginView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
