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
#import "Invite-Swift.h"
#import "StringConstants.h"

#import "UIImageView+WebCache.h"

#define kNoPreviousFriendsFont [UIFont proximaNovaRegularFontOfSize:16]
#define kFooterPadding 20

typedef NS_ENUM(NSUInteger, InviteesSection) {
    InviteesSectionFriends,
    InviteesSectionContacts,
    InviteesSectionEmail,
    InviteesSectionCount
};

@interface InviteesViewController () <UITableViewDataSource, UITableViewDelegate, InputCellDelegate, ContactsViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSMutableArray *selectedFriends;

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;

@property (nonatomic, strong) NSString *textViewText;
@property (nonatomic, assign) BOOL noPreviousFriends;
@end

@implementation InviteesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _textViewText = @"";
    
    self.navigationItem.titleView = [[ProgressView alloc] initWithFrame:CGRectMake(0, 0, 150, 15) step:2 steps:5];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    _friends = [AppDelegate user].friends;
    _selectedFriends = [NSMutableArray array];
    _contacts = [NSMutableArray array];
    _selectedContacts = [NSMutableArray array];
    
    _noPreviousFriends = !_friends.count;

    _nextButton.layer.cornerRadius = kCornerRadius;
    _nextButton.clipsToBounds = YES;
    _nextButton.titleLabel.font = [UIFont proximaNovaRegularFontOfSize:18];

    _tableView.tableHeaderView = [self tableHeaderView];

    if (_noPreviousFriends) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (UIView *)tableHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor inviteQuestionColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.font = [UIFont inviteQuestionFont];
    label.text = @"Who would you like to invite to this event?";
    [view addSubview:label];
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[label]-50-|" options:0 metrics:nil views:@{@"label": label}]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-34-[label]" options:0 metrics:nil views:@{@"label": label}]];
    
    return view;
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
            return _noPreviousFriends ? 1 : _friends.count;
        case InviteesSectionContacts:
            return _contacts.count ? _contacts.count + 1 : 1;
        default:
            return 1;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.textColor = [UIColor inviteTableHeaderColor];
    headerView.textLabel.font = [UIFont inviteTableHeaderFont];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *footerView = (UITableViewHeaderFooterView *)view;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;

    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"invitees_newfriends_footer", nil) attributes:@{NSFontAttributeName: [UIFont inviteTableFooterFont], NSParagraphStyleAttributeName: style}];
    
    footerView.textLabel.attributedText = att;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == InviteesSectionEmail) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4;
        return [NSLocalizedString(@"invitees_newfriends_footer", nil) boundingRectWithSize:CGSizeMake(self.view.frame.size.width - (_tableView.separatorInset.left * 2), CGFLOAT_MAX)
                                                                                   options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                                                attributes:@{NSFontAttributeName: [UIFont inviteTableFooterFont], NSParagraphStyleAttributeName: style}
                                                                                   context:nil].size.height + kFooterPadding;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == InviteesSectionFriends) {
        
        if (_noPreviousFriends) {
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER forIndexPath:indexPath];

            NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"invitees_nopreviousfriends", nil) attributes:@{NSFontAttributeName: kNoPreviousFriendsFont}];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 6;
            [att addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [att.string length])];
            
            cell.textLabel.numberOfLines = 0;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor inviteTableHeaderColor];
            cell.textLabel.attributedText = att;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        
        } else {
        
            ProfileCell *cell = (ProfileCell *)[tableView dequeueReusableCellWithIdentifier:PROFILE_CELL_IDENTIFIER forIndexPath:indexPath];
            PFObject *friend = (PFObject *)_friends[indexPath.row];
            
            cell.label.textColor = [UIColor inviteTableLabelColor];
            cell.label.font = [UIFont inviteTableSmallFont];
            cell.accessoryView = [[UIImageView alloc] initWithImage:([_selectedFriends containsObject:friend] ? [UIImage imageNamed:@"list_selected"] : [UIImage imageNamed:@"list_select"])];
            cell.profileImageViewLeadingConstraint.constant = cell.separatorInset.left;
            
            if ([friend objectForKey:FULL_NAME_KEY]) {
            
                cell.label.text = [friend objectForKey:FULL_NAME_KEY];
                
            } else {
                
                cell.label.text = [friend objectForKey:EMAIL_KEY];

            }
            
            if ([friend objectForKey:FACEBOOK_ID_KEY]) {
                [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square&width=150&height=150", [friend objectForKey:FACEBOOK_ID_KEY]]] placeholderImage:nil];
            } else {
                [cell.profileImageView prepareLabelForPerson:friend];
            }
            return cell;
            
        }
        
    } else if (indexPath.section == InviteesSectionEmail) {
        
        InputCell *cell = (InputCell *)[tableView dequeueReusableCellWithIdentifier:INPUT_CELL_IDENTIFIER forIndexPath:indexPath];
        cell.delegate = self;
        cell.placeholderLabel.text = @"Tap to enter your friends' email addresses";
        cell.placeholderLabel.font = [UIFont inviteTableSmallFont];
        cell.placeholderLabel.textColor = [UIColor inviteTableLabelColor];
        cell.textView.tag = indexPath.row;
        cell.textView.text = _textViewText;
        cell.textView.textColor = [UIColor inviteTableLabelColor];
        cell.textView.font = [UIFont inviteTableSmallFont];
        cell.textView.textContainer.lineFragmentPadding = 0;
        cell.textView.textContainerInset = UIEdgeInsetsMake(4, 0, 0, 0);
        cell.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self addDoneToolBarToKeyboard:cell.textView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textViewLeadingConstraint.constant = cell.separatorInset.left;
        cell.labelLeadingConstraint.constant = cell.separatorInset.left;
        return cell;
        
    } else {
        
        if (!_contacts.count || indexPath.row == 0) {
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BASIC_CELL_IDENTIFIER forIndexPath:indexPath];
            cell.textLabel.textColor = [UIColor inviteTableLabelColor];
            cell.textLabel.text = !_contacts.count ? @"Choose invitees from your Contacts" : @"Choose more invitees from your Contacts";
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        } else {
            
            ProfileCell *cell = (ProfileCell *)[tableView dequeueReusableCellWithIdentifier:PROFILE_CELL_IDENTIFIER forIndexPath:indexPath];
            NSString *contact = _contacts[indexPath.row - 1];

            cell.label.textColor = [UIColor inviteTableLabelColor];
            cell.label.font = [UIFont inviteTableSmallFont];
            cell.accessoryView = [[UIImageView alloc] initWithImage:([_selectedContacts containsObject:contact] ? [UIImage imageNamed:@"list_selected"] : [UIImage imageNamed:@"list_select"])];
            cell.profileImageViewLeadingConstraint.constant = cell.separatorInset.left;
            
            cell.label.text = contact;
            
            cell.profileImageView.person = contact;
            return cell;

        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case InviteesSectionFriends:
            return @"Previously Invited Friends";
        case InviteesSectionContacts:
            return @"Browse Contacts";
        case InviteesSectionEmail:
            return @"New Friends";
        default:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case InviteesSectionEmail:
            return NSLocalizedString(@"invitees_newfriends_footer", nil);
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (_noPreviousFriends || indexPath.section == InviteesSectionEmail) {
        return;
    }
    
    if (indexPath.section == InviteesSectionContacts) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:SEGUE_TO_CONTACTS sender:self];
        } else {
            PFObject *contact = _contacts[indexPath.row - 1];
            if ([_selectedContacts containsObject:contact]) {
                [_selectedContacts removeObject:contact];
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_select"]];
            } else {
                [_selectedContacts addObject:contact];
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_selected"]];
            }
        }
        return;
    }
    
    PFObject *friend = _friends[indexPath.row];
    if ([_selectedFriends containsObject:friend]) {
        [_selectedFriends removeObject:friend];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_select"]];
    } else {
        [_selectedFriends addObject:friend];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_selected"]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat textViewWidth = self.view.frame.size.width - 30;
    if (indexPath.section == InviteesSectionFriends) {
        if (_noPreviousFriends) {
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 6;
            CGRect frame = [NSLocalizedString(@"invitees_nopreviousfriends", nil) boundingRectWithSize:CGSizeMake(textViewWidth, CGFLOAT_MAX)
                                                       options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                                                            attributes:@{NSFontAttributeName: kNoPreviousFriendsFont, NSParagraphStyleAttributeName: style}
                                                       context:nil];
            return frame.size.height + 25;
        } else {
            return 54;
        }
    } else if (indexPath.section == InviteesSectionContacts) {
        if (indexPath.row == 0) {
            return 44;
        } else {
            return 54;
        }
    } else {
        CGRect frame = [_textViewText boundingRectWithSize:CGSizeMake(textViewWidth, CGFLOAT_MAX)
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:@{NSFontAttributeName: [UIFont inviteTableSmallFont]}
                                          context:nil];
        CGFloat height = frame.size.height + 30;
        return height;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_TO_TIMEFRAME]) {
        
        // Add email addresses to invitees
        
        NSMutableArray *allInvitees = [[NSMutableArray alloc] initWithArray:_selectedFriends];
        NSMutableArray *emailAddresses = [NSMutableArray array];
        
        if (_textViewText.length) {
            NSArray *components = [_textViewText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *string = [components componentsJoinedByString:@""];
            emailAddresses = [[string componentsSeparatedByString:@","] mutableCopy];
        }
        
        [emailAddresses addObjectsFromArray:_selectedContacts];
        if (emailAddresses.count) {
            [AppDelegate user].protoEvent.emails = emailAddresses;
        }
        [allInvitees addObjectsFromArray:emailAddresses];
        [AppDelegate user].protoEvent.allInvitees = allInvitees;
        
        [AppDelegate user].protoEvent.invitees = _selectedFriends;
        
        NSMutableArray *inviteeEmails = [NSMutableArray array];
        for (PFObject *invitee in _selectedFriends) {
            [inviteeEmails addObject:[invitee objectForKey:EMAIL_KEY]];
        }
        if (inviteeEmails.count) {
            [AppDelegate user].protoEvent.inviteeEmails = inviteeEmails;
        }
        
    } else if ([segue.identifier isEqualToString:SEGUE_TO_CONTACTS]) {
        ((ContactsViewController *)segue.destinationViewController).delegate = self;
    }
}

- (IBAction)cancel:(id)sender
{
    [AppDelegate user].protoEvent = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize size = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, size.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 animations:^{
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, 0.0, 0.0);
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    } completion:nil];
}

#pragma mark - InputCellDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    _textViewText = textView.text;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - UITextView Dismiss Toolbar

- (void)addDoneToolBarToKeyboard:(UITextView *)textView
{
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Dismiss Keyboard" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClickedDismissKeyboard)],
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         nil];
    [doneToolbar sizeToFit];
    textView.inputAccessoryView = doneToolbar;
}

- (void)doneButtonClickedDismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - ContactsViewControllerDelegate

- (void)contactsViewController:(ContactsViewController *)vc didSelectEmailAddresses:(NSArray *)emails
{
    for (NSString *email in emails) {
        if (![_contacts containsObject:email]) {
            [_contacts addObject:email];
        }
        if (![_selectedContacts containsObject:email]) {
            [_selectedContacts addObject:email];
        }
    }
    [_tableView reloadData];
}

@end
