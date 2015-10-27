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

typedef NS_ENUM(NSUInteger, WeedOutReason) {
    WeedOutReasonInitialSubmit,
    WeedOutReasonUpdate
};

@interface Event ()

@property (nonatomic, strong) NSMutableArray *actualInviteesToInvite;
@property (nonatomic, strong) NSMutableArray *actualEmailsToInvite;
@property (nonatomic, strong) NSMutableArray *inviteeEmails;

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

+ (Event *)eventFromPFObject:(PFObject *)pfObject
{
    Event *event = [[Event alloc] init];
    event.isParseEvent = YES;
    event.parseEvent = pfObject;
    
    if ([((PFObject *)event.parseEvent[EVENT_CREATOR_KEY]).objectId isEqualToString:[AppDelegate parseUser].objectId]) {
        event.existingTitle = pfObject[EVENT_TITLE_KEY];
        event.existingInvitees = pfObject[EVENT_INVITEES_KEY];
        event.existingStartDate = pfObject[EVENT_START_DATE_KEY];
        event.existingEndDate = pfObject[EVENT_END_DATE_KEY];

        PFObject *location = pfObject[EVENT_LOCATION_KEY];
        event.existingProtoLocation = [[Location alloc] initWithFoursquareId:location[LOCATION_FOURSQUARE_ID_KEY] name:location[LOCATION_NAME_KEY] latitude:[location[LOCATION_LATITUDE_KEY] doubleValue] longitude:[location[LOCATION_LONGITUDE_KEY] doubleValue] formattedAddress:location[LOCATION_ADDRESS_KEY] pfObject:location];
        event.protoLocation = event.existingProtoLocation;
        
        event.updatedTitle = NO;
        event.updatedTimeframe = NO;
        event.updatedInvitees = NO;
        event.updatedEmails = NO;
        event.updatedLocation = NO;
    }
    return event;
}

#pragma mark - Properties

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
        [self weedOutParseUsersFromEmails:_emails reason:WeedOutReasonInitialSubmit];
    } else {
        [self submitToParse];
    }
}

- (void)updateEvent
{
    _actualEmailsToInvite = [_emails mutableCopy];
    _actualInviteesToInvite = [_invitees mutableCopy];
    _inviteeEmails = [NSMutableArray array];

    [self prepareToSubmit];

    if (_emails.count) {
        [self weedOutParseUsersFromEmails:_emails reason:WeedOutReasonUpdate];
    } else {
        [self updateOnParse];
    }
}

- (void)prepareToSubmit
{
    [_invitees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_inviteeEmails addObject:[((PFObject *)obj) objectForKey:EMAIL_KEY]];
    }];
}

- (void)weedOutParseUsersFromEmails:(NSArray *)emails reason:(WeedOutReason)reason
{
    PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
    [query whereKey:EMAIL_KEY containedIn:emails];
    [query findObjectsInBackgroundWithBlock:^(NSArray *persons, NSError *error) {
        
        // If email address exists for any database user, move user from emails to invitees
        for (PFObject *person in persons) {
            if (![_inviteeEmails containsObject:person[EMAIL_KEY]]) {
                [_actualInviteesToInvite addObject:person];
                [_inviteeEmails addObject:[person objectForKey:EMAIL_KEY]];
            }
            [_actualEmailsToInvite removeObject:person[EMAIL_KEY]];
        }
        
        if (reason == WeedOutReasonInitialSubmit) {
            [self submitToParse];
        } else {
            [self updateOnParse];
        }
        
    }];
}

- (void)updateOnParse
{
    __block NSMutableArray *save = [NSMutableArray array];
    
    // Create a new Person for all emails left
    for (NSString *email in _actualEmailsToInvite)
    {
        _updatedEmails = YES;
        PFObject *person = [PFObject objectWithClassName:CLASS_PERSON_KEY];
        person[EMAIL_KEY] = email;
        // Now that person has been created remove from actualEmailsToInvite and add to actualInviteesToInvite
        [_actualInviteesToInvite addObject:person];
        [save addObject:person];
    }

    if (_updatedTitle) {
        _parseEvent[EVENT_TITLE_KEY] = _title;
    }

    if (_updatedTimeframe) {
        _parseEvent[EVENT_START_DATE_KEY] = _startDate;
        _parseEvent[EVENT_END_DATE_KEY] = _endDate;
    }
    
    if (_updatedLocation) {
        PFObject *location = [self convertLocation];
        if (location) {
            [save addObject:location];
        }
    }
    
    [PFObject saveAllInBackground:save target:self selector:@selector(eventUpdatedWithResult:error:)];
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

    PFObject *location = [self convertLocation];
    if (location) {
        [save addObject:location];
    }
    [save addObject:_parseEvent];
    [PFObject saveAllInBackground:save target:self selector:@selector(eventCreatedWithResult:error:)];
}

- (PFObject *)convertLocation
{
    if (_protoLocation) {
        // First, check if user is using saved location
        
        for (PFObject *location in [AppDelegate user].locations) {
            if (location.objectId == self.protoLocation.pfObject.objectId) {
                _parseEvent[EVENT_LOCATION_KEY] = location;
                break;
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
            _parseEvent[EVENT_LOCATION_KEY] = location;
            _locationToSave = location;
            return location;
        }
    }
    return nil;
}

- (void)eventUpdatedWithResult:(NSNumber *)result error:(NSError *)error
{
    if ([result boolValue]) { // success

        NSMutableArray *save = [_actualInviteesToInvite mutableCopy];

        // For some reason addUniqueObject is not adding to an existing array, but wiping the array first...
        _parseEvent[EVENT_INVITEES_KEY] = [_actualInviteesToInvite arrayByAddingObjectsFromArray:[AppDelegate user].protoEvent.existingInvitees];
        
        // Iterate through _invitee and pull out emails so that searching for busy times is easier later...
        for (PFObject *invitee in _actualInviteesToInvite) {
            NSString *email = [invitee objectForKey:EMAIL_KEY];
            if (email && email.length > 0) {
//                [responses addObject:[NSString stringWithFormat:@"%@:%@", email, @(EventResponseNoResponse)]];
                [_parseEvent addUniqueObject:[NSString stringWithFormat:@"%@:%@", email, @(EventResponseNoResponse)] forKey:EVENT_RESPONSES_KEY];
            }
            [Event makeAdjustmentsToPerson:invitee event:_parseEvent];
        }
        
        if (_locationToSave) {
            [[AppDelegate parseUser] addUniqueObject:_locationToSave forKey:LOCATIONS_KEY];
        }
        
        [save addObject:_parseEvent];
        [save addObject:[AppDelegate parseUser]];
        
        [PFObject saveAllInBackground:save block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                if (_updatedLocation || _updatedTimeframe) {
                    NSLog(@"Update all");
                    [self sendPushNotification];
                } else if (_updatedInvitees || _updatedEmails) {
                    NSMutableString *inviteeString = [[NSMutableString alloc] initWithString:@"Update Invite users: "];
                    NSMutableString *emailString = [[NSMutableString alloc] initWithString:@"Update new users: "];
                    for (PFObject *invitee in _actualInviteesToInvite) {
                        if (invitee[FULL_NAME_KEY]) {
                            [inviteeString appendFormat:@"%@, ", invitee[EMAIL_KEY]];
                        } else {
                            [emailString appendFormat:@"%@, ", invitee[EMAIL_KEY]];
                        }
                    }
                    NSLog(@"%@", inviteeString);
                    NSLog(@"%@", emailString);
                }
                
                // Do not email if only title was updated
                
                NSLog(@"Update creator: %@", [AppDelegate user].email);
                
                [self sendNewEventEmailToCreator];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UPDATED_NOTIFICATION object:nil userInfo:nil];
                
            } else {
                NSLog(@"ERRRRRRRROR!!!");
            }
        }];
    } else {
        NSLog(@"ERRRRRRRROR!!!");
    }
}

- (void)eventCreatedWithResult:(NSNumber *)result error:(NSError *)error
{
    if ([result boolValue]) { // success
        
        NSMutableArray *save = [_actualInviteesToInvite mutableCopy];

        // By now the new event and all people who had to be created for this event have been created...
        [_parseEvent addUniqueObjectsFromArray:_actualInviteesToInvite forKey:EVENT_INVITEES_KEY];
        
        // Iterate through _invitee and pull out emails so that searching for busy times is easier later...
        NSMutableArray *responses = [NSMutableArray array];
        for (PFObject *invitee in _actualInviteesToInvite) {
            NSString *email = [invitee objectForKey:EMAIL_KEY];
            if (email && email.length > 0) {
                [responses addObject:[NSString stringWithFormat:@"%@:%@", email, @(EventResponseNoResponse)]];
            }
            [Event makeAdjustmentsToPerson:invitee event:_parseEvent];
        }
        _parseEvent[EVENT_RESPONSES_KEY] = responses;
        
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
                [AppDelegate user].events = [User sortEvents:events];
                
                // DEBUG ONLY
                NSMutableString *inviteeString = [[NSMutableString alloc] initWithString:@"Emailing Invite users: "];
                NSMutableString *emailString = [[NSMutableString alloc] initWithString:@"Emailing new users: "];
                for (PFObject *invitee in _actualInviteesToInvite) {
                    if (invitee[FULL_NAME_KEY]) {
                        [inviteeString appendFormat:@"%@, ", invitee[EMAIL_KEY]];
                    } else {
                        [emailString appendFormat:@"%@, ", invitee[EMAIL_KEY]];
                    }
                }
                NSLog(@"%@", inviteeString);
                NSLog(@"%@", emailString);
                NSLog(@"Emailing creator: %@", [AppDelegate user].email);
                // DEBUG ONLY
                
                [self sendPushNotification];
                [self sendNewEventEmailToCreator];
                
                NSDictionary *userInfo = @{@"createdEvent": _parseEvent};
                [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CREATED_NOTIFICATION object:nil userInfo:userInfo];
                
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
                                       withMessage:[NSString stringWithFormat:@"%@ sent you a new event: %@", self.host, self.title]];
    }
}

- (NSString *)locationText
{
        NSString *locationName;
        NSString *locationAddress;
        
        if (_isParseEvent) {
            locationName = [self.location objectForKey:LOCATION_NAME_KEY];
            locationAddress = [self.location objectForKey:LOCATION_ADDRESS_KEY];
        } else {
            locationName = self.protoLocation.name;
            locationAddress = self.protoLocation.formattedAddress;
        }
        
        NSMutableString *att = [[NSMutableString alloc] init];
        
        if (locationName) {
            [att appendString:locationName];
            [att appendString:@"\n"];
        }
        
        if (locationAddress) {
            [att appendString:locationAddress];
        }
        
        return att;
}

- (void)sendNewEventEmailToCreator
{
    NSMutableArray *mergeVars = [NSMutableArray array];
    NSMutableArray *vars = [NSMutableArray array];
    NSMutableArray *inviteesContent = [NSMutableArray array];
    
    for (PFObject *invitee in _actualInviteesToInvite) {
        NSString *display = invitee[FULL_NAME_KEY] ? invitee[FULL_NAME_KEY] : invitee[EMAIL_KEY];
        [inviteesContent addObject:@{@"display": display, @"facebook_id": invitee[FACEBOOK_ID_KEY] ? invitee[FACEBOOK_ID_KEY] : @"" , @"response": @(EventResponseNoResponse)}];
    }
    
    [vars addObject:@{@"name": @"event_title", @"content": self.title}];
    [vars addObject:@{@"name": @"host", @"content": self.host}];
    [vars addObject:@{@"name": @"my_response", @"content": @(EventResponseHost)}];
    [vars addObject:@{@"name": @"time", @"content": [AppDelegate viewTimeframeForStartDate:self.startDate endDate:self.endDate]}];
    [vars addObject:@{@"name": @"location", @"content": [self locationText]}];
    [vars addObject:@{@"name": @"invitees", @"content": inviteesContent}];
    [vars addObject:@{@"name": @"deeplink", @"content": [NSString stringWithFormat:@"invite://%@", self.parseEvent.objectId]}];
    
    [mergeVars addObject:@{@"rcpt": self.creator[EMAIL_KEY], @"vars": vars}];
    
    NSArray *to = @[@{@"email": self.creator[EMAIL_KEY], @"name": self.creator[FULL_NAME_KEY]}];
    [PFCloud callFunctionInBackground:@"email_template"
                       withParameters:@{@"template": @"new-event-creator",
                                        @"to": to,
                                        @"merge_vars": mergeVars,
                                        @"subject": [NSString stringWithFormat:@"New Invite Event: %@", self.title],
                                        @"from_email": @"invite@appuous.com",
                                        @"from_name": @"Invite App"
                                        } block:^(id object, NSError *error) {
                                            if (error) {
                                                NSLog(@"%@", error.localizedDescription);
                                            }
                                        }];
}

@end
