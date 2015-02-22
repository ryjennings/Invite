//
//  InviteesViewController.m
//  Invite
//
//  Created by Ryan Jennings on 2/17/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "InviteesViewController.h"

#import "AppDelegate.h"
#import "Event.h"
#import "StringConstants.h"

@interface InviteesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSMutableSet *invitees;
@end

@implementation InviteesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _friends = [NSArray array];
    _invitees = [NSMutableSet set];

    PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
    [[query whereKey:EMAIL_KEY equalTo:[AppDelegate user].email] includeKey:FRIENDS_KEY];
    
    // Return all friends
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        _friends = [user objectForKey:FRIENDS_KEY];
        [_tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:INVITEE_CELL_IDENTIFIER];
    
    PFObject *friend = (PFObject *)_friends[indexPath.row];

    if ([friend objectForKey:FULL_NAME_KEY]) {
    
        cell.textLabel.text = [friend objectForKey:FULL_NAME_KEY];
        
    } else {
        
        cell.textLabel.text = [friend objectForKey:EMAIL_KEY];

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    PFObject *friend = _friends[indexPath.row];
    
    if ([_invitees containsObject:friend]) {
        [_invitees removeObject:friend];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [_invitees addObject:friend];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_TO_TIMEFRAME]) {
        
        // Add email addresses to invitees
        
        NSArray *components = [_emailTextField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *string = [components componentsJoinedByString:@""];
        NSArray *emailAddresses = [string componentsSeparatedByString:@","];
        
        [AppDelegate user].protoEvent.invitees = _invitees;
        
        NSMutableArray *inviteeEmails = [NSMutableArray array];
        for (PFObject *invitee in _invitees) {
            [inviteeEmails addObject:[invitee objectForKey:EMAIL_KEY]];
        }
        [AppDelegate user].protoEvent.inviteeEmails = inviteeEmails;
        
        [AppDelegate user].protoEvent.emails = emailAddresses;
    }
}

@end
