//
//  Event.m
//  Invite
//
//  Created by Ryan Jennings on 2/13/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

#import "Event.h"
#import "Invite-Swift.h"
#import "AppDelegate.h"
#import "StringConstants.h"

@interface Event ()

@property (nonatomic, strong) NSMutableArray *actualInviteesToInvite;
@property (nonatomic, strong) NSMutableArray *actualEmailsToInvite;
@property (nonatomic, strong) NSMutableArray *inviteeEmails;

@property (nonatomic, strong) PFObject *parseEvent;
@property (nonatomic, assign) BOOL isParseEvent;
@property (nonatomic, strong) PFObject *locationToSave;

@end

@implementation Event

@synthesize creator = _creator;
@synthesize title = _title;
@synthesize invitees = _invitees;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize location = _location;
@synthesize protoLocation = _protoLocation;

+ (Event *)createEvent
{
    Event *event = [[Event alloc] init];
    event.isParseEvent = NO;
    event.creator = [AppDelegate parseUser];
    return event;
}

+ (Event *)eventFromPFObject:(PFObject *)object
{
    Event *event = [[Event alloc] init];
    event.isParseEvent = YES;
    event.parseEvent = object;
    return event;
}

#pragma mark - Properties

//@property (nonatomic, strong) NSDate *endDate;
//@property (nonatomic, strong) PFObject *location;

- (PFObject *)creator
{
    if (_parseEvent && _parseEvent[EVENT_CREATOR_KEY]) {
        return _parseEvent[EVENT_CREATOR_KEY];
    }
    return [AppDelegate parseUser];
}

- (void)setCreator:(PFObject *)creator
{
    if (_parseEvent) {
        _parseEvent[EVENT_CREATOR_KEY] = creator;
    }
    _creator = creator;
}

- (NSString *)title
{
    if (_parseEvent && _parseEvent[EVENT_TITLE_KEY]) {
        return _parseEvent[EVENT_TITLE_KEY];
    }
    return _title;
}

- (void)setTitle:(NSString *)title
{
    if (_parseEvent) {
        _parseEvent[EVENT_TITLE_KEY] = title;
    }
    _title = title;
}

- (NSArray *)invitees
{
    if (_parseEvent && _parseEvent[EVENT_INVITEES_KEY]) {
        return _parseEvent[EVENT_INVITEES_KEY];
    }
    return _invitees;
}

- (void)setInvitees:(NSArray *)invitees
{
    if (_parseEvent) {
        _parseEvent[EVENT_INVITEES_KEY] = invitees;
    }
    _invitees = invitees;
}

- (NSDate *)startDate
{
    if (_parseEvent && _parseEvent[EVENT_START_DATE_KEY]) {
        return _parseEvent[EVENT_START_DATE_KEY];
    }
    return _startDate;
}

- (void)setStartDate:(NSDate *)startDate
{
    if (_parseEvent) {
        _parseEvent[EVENT_START_DATE_KEY] = startDate;
    }
    _startDate = startDate;
}

- (NSDate *)endDate
{
    if (_parseEvent && _parseEvent[EVENT_END_DATE_KEY]) {
        return _parseEvent[EVENT_END_DATE_KEY];
    }
    return _endDate;
}

- (void)setEndDate:(NSDate *)endDate
{
    if (_parseEvent) {
        _parseEvent[EVENT_END_DATE_KEY] = endDate;
    }
    _endDate = endDate;
}

- (PFObject *)location
{
    if (_parseEvent && _parseEvent[EVENT_LOCATION_KEY]) {
        return _parseEvent[EVENT_LOCATION_KEY];
    }
    return _location;
}

- (void)setLocation:(PFObject *)location
{
    if (_parseEvent) {
        _parseEvent[EVENT_LOCATION_KEY] = location;
    }
    _location = location;
}

- (Location *)protoLocation
{
    return _protoLocation;
}

- (void)setProtoLocation:(Location *)protoLocation
{
    _protoLocation = protoLocation;
}

- (void)saveToParse
{
    [_parseEvent saveInBackground];
}

#pragma mark -

- (NSAttributedString *)editTimeframe
{
    if (self.startDate && self.endDate) {
        return [AppDelegate editTimeframeForStartDate:self.startDate endDate:self.endDate];
    }
    return [[NSAttributedString alloc] initWithString:@"Set a time" attributes:@{NSFontAttributeName: [UIFont proximaNovaRegularFontOfSize:20], NSForegroundColorAttributeName: [UIColor inviteTableHeaderColor]}];
}

- (NSString *)viewTimeframe
{
    if (self.startDate && self.endDate) {
        return [AppDelegate viewTimeframeForStartDate:self.startDate endDate:self.endDate];
    }
    return @"";
}

- (NSString *)host
{
    if (_parseEvent) {
        return _parseEvent[EVENT_CREATOR_KEY][FULL_NAME_KEY];
    }
    return [AppDelegate user].fullName;
}

#pragma mark -

- (void)submitEvent
{
    _actualEmailsToInvite = [_emails mutableCopy];
    _actualInviteesToInvite = [_invitees mutableCopy];
    _inviteeEmails = [NSMutableArray array];
    
    [self prepareToSubmit];
    
    if (_emails.count) {
        [self weedOutParseUsersFromEmails];
    } else {
        [self submitToParse];
    }
}

- (void)prepareToSubmit
{
    [_invitees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_inviteeEmails addObject:[((PFObject *)obj) objectForKey:EMAIL_KEY]];
    }];
}

- (void)weedOutParseUsersFromEmails
{
    PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
    [query whereKey:EMAIL_KEY containedIn:_emails];
    [query findObjectsInBackgroundWithBlock:^(NSArray *persons, NSError *error) {
        
        // If email address exists for any database user, move user from emails to invitees
        
        for (PFObject *person in persons) {
            
            if (![_inviteeEmails containsObject:person[EMAIL_KEY]]) {
                
                [_actualInviteesToInvite addObject:person];
                [_inviteeEmails addObject:[person objectForKey:EMAIL_KEY]];
                
            }
            [_actualEmailsToInvite removeObject:person[EMAIL_KEY]];
        }
        [self submitToParse];
    }];
}

- (void)submitToParse
{
    __block NSMutableArray *save = [NSMutableArray array];
    
    // Create a new Person for all emails left
    for (NSString *email in _actualEmailsToInvite)
    {
        PFObject *person = [PFObject objectWithClassName:CLASS_PERSON_KEY];
        person[EMAIL_KEY] = email;
        // Now that person has been created remove from actualEmailsToInvite and add to actualInviteesToInvite
        [_actualInviteesToInvite addObject:person];
        [save addObject:person];
    }
    
    _parseEvent = [PFObject objectWithClassName:CLASS_EVENT_KEY];
    _parseEvent[EVENT_CREATOR_KEY] = [AppDelegate parseUser];
    _parseEvent[EVENT_START_DATE_KEY] = _startDate;
    _parseEvent[EVENT_END_DATE_KEY] = _endDate;
    _parseEvent[EVENT_TITLE_KEY] = _title;

    // First, check if user is using saved location
    
    for (PFObject *location in [AppDelegate user].locations) {
        if (location == self.protoLocation.pfObject) {
            _parseEvent[EVENT_LOCATION_KEY] = location;
        }
    }
    
    // Next, if it's a foursquare location, check if it already exists on parse

    if (!_parseEvent[EVENT_LOCATION_KEY]) {
        
        // If location does not exist in user's saved locations, and does not exist on parse, create
        PFObject *location = [PFObject objectWithClassName:CLASS_LOCATION_KEY];
        if (self.protoLocation.foursquareId) {
            location[LOCATION_FOURSQUARE_ID_KEY] = self.protoLocation.foursquareId;
        }
        if (self.protoLocation.name) {
            location[LOCATION_NAME_KEY] = self.protoLocation.name;
        }
        if (self.protoLocation.latitude) {
            location[LOCATION_LATITUDE_KEY] = @(self.protoLocation.latitude);
        }
        if (self.protoLocation.longitude) {
            location[LOCATION_LONGITUDE_KEY] = @(self.protoLocation.longitude);
        }
        location[LOCATION_ADDRESS_KEY] = self.protoLocation.formattedAddress;
        [save addObject:location];
        _parseEvent[EVENT_LOCATION_KEY] = location;
        _locationToSave = location;
    }

    [save addObject:_parseEvent];
    [PFObject saveAllInBackground:save target:self selector:@selector(eventCreatedWithResult:error:)];
}

- (void)eventCreatedWithResult:(NSNumber *)result error:(NSError *)error
{
    if ([result boolValue]) { // success
        
        NSMutableArray *save = _actualInviteesToInvite;

        // By now the new event and all people who had to be created for this event have been created...
        [_parseEvent addUniqueObjectsFromArray:_actualInviteesToInvite forKey:EVENT_INVITEES_KEY];
        
        // Iterate through _invitee and pull out emails so that searching for busy times is easier later...
        NSMutableDictionary *rsvp = [NSMutableDictionary dictionary];
        for (PFObject *invitee in _actualInviteesToInvite) {
            NSString *email = [invitee objectForKey:EMAIL_KEY];
            if (email && email.length > 0) {
                [rsvp setValue:@(EventResponseNoResponse) forKey:[AppDelegate keyFromEmail:email]];
            }
            [Event makeAdjustmentsToPerson:invitee event:_parseEvent];
        }
        _parseEvent[EVENT_RSVP_KEY] = rsvp;
        
        [[AppDelegate parseUser] addUniqueObject:_parseEvent forKey:EVENTS_KEY];
        if (_locationToSave) {
            [[AppDelegate parseUser] addUniqueObject:_locationToSave forKey:LOCATIONS_KEY];
        }
        
        [save addObject:_parseEvent];
        [save addObject:[AppDelegate parseUser]];
        
        [PFObject saveAllInBackground:save block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                if (![AppDelegate user].events) {
                    [AppDelegate user].events = [NSArray array];
                }
                NSMutableArray *events = [[AppDelegate user].events mutableCopy];
                [events addObject:_parseEvent];
                [AppDelegate user].events = events;
                
                [self sendPushNotification];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CREATED_NOTIFICATION object:self];
                
            } else {
                NSLog(@"ERRRRRRRROR!!!");
            }
        }];
    } else {
        NSLog(@"ERRRRRRRROR!!!");
    }
}

+ (void)makeAdjustmentsToPerson:(PFObject *)person event:(PFObject *)event
{
    // Add event to invitee
    [person addUniqueObject:event forKey:EVENTS_KEY];
    
    // Add invitee to creator's (user's) friends
    [[AppDelegate parseUser] addUniqueObject:person forKey:FRIENDS_KEY];
    
    // Add person to local friends
    [self addPersonToFriends:person];
    
    // Add invitee's email to creator's (user's) friendEmails
    [[AppDelegate parseUser] addUniqueObject:[person objectForKey:EMAIL_KEY] forKey:FRIENDS_EMAILS_KEY];
    
    // Add person's email to local friendEmails
    if (![AppDelegate user].friendEmails) {
        [AppDelegate user].friendEmails = [NSArray array];
    }
    NSMutableArray *friendEmails = [[AppDelegate user].friendEmails mutableCopy];
    [friendEmails addObject:[person objectForKey:EMAIL_KEY]];
    [AppDelegate user].friendEmails = friendEmails;

    // Add creator (user) to invitee's friends
    [person addUniqueObject:[AppDelegate parseUser] forKey:FRIENDS_KEY];
    [person addUniqueObject:[AppDelegate user].email forKey:FRIENDS_EMAILS_KEY];
}

+ (void)addPersonToFriends:(PFObject *)friend
{
    if (![AppDelegate user].friends) {
        [AppDelegate user].friends = [NSArray array];
    }

    NSMutableArray *friends = [[AppDelegate user].friends mutableCopy];
    NSMutableArray *friendsEmails = [NSMutableArray array];
    for (PFObject *f in friends) {
        [friendsEmails addObject:[f objectForKey:EMAIL_KEY]];
    }
    
    if (![friendsEmails containsObject:[friend objectForKey:EMAIL_KEY]]) {
        [friends addObject:friend];
    }
    [AppDelegate user].friends = friends;
}

- (void)sendPushNotification
{
    if (_inviteeEmails) {
        PFQuery *query = [PFInstallation query];
        [query whereKey:EMAIL_KEY containedIn:_inviteeEmails];
        
        // Send push notification to query
        [PFPush sendPushMessageToQueryInBackground:query
                                       withMessage:@"You've received a new event!"];
    }
}

@end
