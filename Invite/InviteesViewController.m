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
#import "EventEditCell.h"
#import "Invite-Swift.h"
#import "StringConstants.h"

#define kEventCellFont [UIFont systemFontOfSize:17]

typedef NS_ENUM(NSUInteger, InviteesSection) {
    InviteesSectionFriends,
    InviteesSectionEmail,
    InviteesSectionCount
};

@interface InviteesViewController () <UITableViewDataSource, UITableViewDelegate, EventEditCellDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSMutableSet *invitees;
@property (nonatomic, strong) NSMutableArray *textViewText;
@end

@implementation InviteesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    _invitees = [NSMutableSet set];
    _friends = [AppDelegate user].friends;
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return InviteesSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case InviteesSectionFriends:
            return _friends.count;
        default:
            return 1;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AppDelegate insetGroupedTableView:tableView cell:cell indexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == InviteesSectionFriends) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:INVITEE_CELL_IDENTIFIER forIndexPath:indexPath];
        
        PFObject *friend = (PFObject *)_friends[indexPath.row];

        if ([friend objectForKey:FULL_NAME_KEY]) {
        
            cell.textLabel.text = [friend objectForKey:FULL_NAME_KEY];
            
        } else {
            
            cell.textLabel.text = [friend objectForKey:EMAIL_KEY];

        }
        
        return cell;
    } else {
        EventEditCell *cell = (EventEditCell *)[tableView dequeueReusableCellWithIdentifier:EVENT_EDIT_CELL_IDENTIFIER forIndexPath:indexPath];
        cell.delegate = self;
        cell.placeholderLabel.text = @"Email";
        cell.placeholderLabel.hidden = cell.textView.text.length;
        cell.textView.tag = indexPath.row;
        cell.textView.text = _textViewText[indexPath.row];
        cell.textView.font = kEventCellFont;
        cell.textView.textContainer.lineFragmentPadding = 0;
        cell.textView.textContainerInset = UIEdgeInsetsMake(1, 0, 0, 0);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case InviteesSectionFriends:
            return @"Invite Friends";
        default:
            return @"Email Addresses";
    }
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
        
        if (_emailTextField.text.length) {
            NSArray *components = [_emailTextField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *string = [components componentsJoinedByString:@""];
            NSArray *emailAddresses = [string componentsSeparatedByString:@","];
            if (emailAddresses.count) {
                [AppDelegate user].protoEvent.emails = emailAddresses;
            }
        }
        
        [AppDelegate user].protoEvent.invitees = _invitees;
        
        NSMutableArray *inviteeEmails = [NSMutableArray array];
        for (PFObject *invitee in _invitees) {
            [inviteeEmails addObject:[invitee objectForKey:EMAIL_KEY]];
        }
        if (inviteeEmails.count) {
            [AppDelegate user].protoEvent.inviteeEmails = inviteeEmails;
        }
        
    }
}

- (IBAction)cancel:(id)sender
{
    [AppDelegate user].protoEvent = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
