//
//  EventViewController.m
//  Invite
//
//  Created by Ryan Jennings on 3/6/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "EventViewController.h"

#import "AppDelegate.h"
#import "EventRSVPCell.h"
#import "EventTextCell.h"
#import "StringConstants.h"
#import "User.h"

typedef NS_ENUM(NSUInteger, EventRow) {
    EventRowName,
    EventRowTimeframe,
    EventRowRSVP,
    EventRowInvitees,
    EventRowCount,
};

@interface EventViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation EventViewController

- (void)viewDidLoad
{
    _event = [AppDelegate user].eventToDisplay;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return EventRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL creator = NO;
    
    if (indexPath.item == EventRowRSVP) {
        creator = [((PFObject *)[_event objectForKey:EVENT_CREATOR_KEY]).objectId isEqualToString:[AppDelegate parseUser].objectId];
    }
    
    if (indexPath.item == EventRowName || indexPath.item == EventRowTimeframe || indexPath.item == EventRowInvitees || (indexPath.item == EventRowRSVP && creator)) {
        EventTextCell *cell = (EventTextCell *)[tableView dequeueReusableCellWithIdentifier:EVENT_TEXT_CELL_IDENTIFIER];
        switch (indexPath.item) {
            case EventRowName:
                cell.label.text = @"Event Name";
                break;
            case EventRowTimeframe:
            {
                NSDate *start = [_event objectForKey:EVENT_STARTDATE_KEY];
                NSDate *end = [_event objectForKey:EVENT_ENDDATE_KEY];
                cell.label.text = [NSString stringWithFormat:@"%@ - %@", start, end];
            }
                break;
            case EventRowInvitees:
                cell.label.text = [NSString stringWithFormat:@"Invitees: %@", _event[EVENT_RSVP_KEY]];
                break;
            case EventRowRSVP:
                cell.label.text = @"You are the creator of this event.";
                break;
            default:
                break;
        }
        return cell;
    } else {
        NSDictionary *rsvp = [_event objectForKey:EVENT_RSVP_KEY];
        EventResponse response = [[rsvp objectForKey:[AppDelegate user].email] integerValue];
        EventRSVPCell *cell = (EventRSVPCell *)[tableView dequeueReusableCellWithIdentifier:EVENT_RSVP_CELL_IDENTIFIER];
        cell.segments.selectedSegmentIndex = response;
        return cell;
    }
}

- (void)valueChangedOnSegmentedControl:(UISegmentedControl *)control
{
    NSMutableDictionary *rsvp = [[_event objectForKey:EVENT_RSVP_KEY] mutableCopy];
    [rsvp setValue:@(control.selectedSegmentIndex) forKey:[AppDelegate user].email];
    _event[EVENT_RSVP_KEY] = rsvp;
    [_event saveInBackground];
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
