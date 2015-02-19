//
//  InviteesViewController.m
//  Invite
//
//  Created by Ryan Jennings on 2/17/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "InviteesViewController.h"

#import "Event.h"
#import "StringConstants.h"

@interface InviteesViewController ()
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@end

@implementation InviteesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:INVITEE_CELL_IDENTIFIER];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:INVITEE_CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
//    cell.textLabel.text = self.justCourseNamesArray[indexPath.row];
    
    return cell;
}

- (IBAction)addNewEvent:(id)sender
{
    [Event createEventWithInvitees:_emailTextField.text];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
