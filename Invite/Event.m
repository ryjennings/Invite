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

#define kNewEventCreator @"new-event-creator"
#define kNewEventInviteUsers @"new-event-invite-users"
#define kNewEventNewUsers @"new-event-new-users"
#define kUpdatedEventCreator @"updated-event-creator"
#define kUpdatedEventInviteUsers @"updated-event-invite-users"

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
    if (self.parseEvent && self.parseEvent[EVENT_CREATOR_KEY]) {
        return self.parseEvent[EVENT_CREATOR_KEY];
    }
    return [AppDelegate parseUser];
}

- (void)setCreator:(PFObject *)creator
{
    if (self.parseEvent) {
        self.parseEvent[EVENT_CREATOR_KEY] = creator;
    }
    _creator = creator;
}

- (NSString *)title
{
    if (self.parseEvent && self.parseEvent[EVENT_TITLE_KEY]) {
        return self.parseEvent[EVENT_TITLE_KEY];
    }
    return _title;
}

- (void)setTitle:(NSString *)title
{
    if (self.parseEvent) {
        self.parseEvent[EVENT_TITLE_KEY] = title;
    }
    _title = title;
}

- (NSArray *)invitees
{
    if (self.parseEvent && self.parseEvent[EVENT_INVITEES_KEY]) {
        return self.parseEvent[EVENT_INVITEES_KEY];
    }
    return _invitees;
}

- (void)setInvitees:(NSArray *)invitees
{
    if (self.parseEvent) {
        self.parseEvent[EVENT_INVITEES_KEY] = invitees;
    }
    _invitees = invitees;
}

- (NSDate *)startDate
{
    if (self.parseEvent && self.parseEvent[EVENT_START_DATE_KEY]) {
        return self.parseEvent[EVENT_START_DATE_KEY];
    }
    return _startDate;
}

- (void)setStartDate:(NSDate *)startDate
{
    if (self.parseEvent) {
        self.parseEvent[EVENT_START_DATE_KEY] = startDate;
    }
    _startDate = startDate;
}

- (NSDate *)endDate
{
    if (self.parseEvent && self.parseEvent[EVENT_END_DATE_KEY]) {
        return self.parseEvent[EVENT_END_DATE_KEY];
    }
    return _endDate;
}

- (void)setEndDate:(NSDate *)endDate
{
    if (self.parseEvent) {
        self.parseEvent[EVENT_END_DATE_KEY] = endDate;
    }
    _endDate = endDate;
}

- (PFObject *)location
{
    if (self.parseEvent && self.parseEvent[EVENT_LOCATION_KEY]) {
        return self.parseEvent[EVENT_LOCATION_KEY];
    }
    return _location;
}

- (void)setLocation:(PFObject *)location
{
    if (self.parseEvent) {
        self.parseEvent[EVENT_LOCATION_KEY] = location;
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
    if (self.parseEvent) {
        return self.parseEvent[EVENT_CREATOR_KEY][FULL_NAME_KEY];
    }
    return [AppDelegate user].fullName;
}

#pragma mark -

- (void)submitEvent
{
    self.actualEmailsToInvite = self.emails.count ? [NSMutableArray arrayWithArray:self.emails] : [NSMutableArray array];
    self.actualInviteesToInvite = self.invitees.count ? [NSMutableArray arrayWithArray:self.invitees] : [NSMutableArray array];
    self.inviteeEmails = [NSMutableArray array];
    
    [self prepareToSubmit];
    
    if (self.emails.count) {
        [self weedOutParseUsersFromEmails:self.emails reason:WeedOutReasonInitialSubmit];
    } else {
        [self submitToParse];
    }
}

- (void)updateEvent
{
    self.actualEmailsToInvite = self.addedEmails.count ? [NSMutableArray arrayWithArray:self.addedEmails] : [NSMutableArray array];
    self.actualInviteesToInvite = self.addedInvitees.count ? [NSMutableArray arrayWithArray:self.addedInvitees] : [NSMutableArray array];
    self.inviteeEmails = [NSMutableArray array];

    [self prepareToSubmit];

    if (self.emails.count) {
        [self weedOutParseUsersFromEmails:self.addedEmails reason:WeedOutReasonUpdate];
    } else {
        [self updateOnParse];
    }
}

- (void)prepareToSubmit
{
    [self.invitees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.inviteeEmails addObject:[((PFObject *)obj) objectForKey:EMAIL_KEY]];
    }];
}

- (void)weedOutParseUsersFromEmails:(NSArray *)emails reason:(WeedOutReason)reason
{
    PFQuery *query = [PFQuery queryWithClassName:CLASS_PERSON_KEY];
    [query whereKey:EMAIL_KEY containedIn:emails];
    [query findObjectsInBackgroundWithBlock:^(NSArray *persons, NSError *error) {
        
        // If email address exists for any database user, move user from emails to invitees
        for (PFObject *person in persons) {
            if (![self.inviteeEmails containsObject:person[EMAIL_KEY]]) {
                [self.actualInviteesToInvite addObject:person];
                [self.inviteeEmails addObject:[person objectForKey:EMAIL_KEY]];
            }
            [self.actualEmailsToInvite removeObject:person[EMAIL_KEY]];
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
    for (NSString *email in self.addedEmails)
    {
        PFObject *person = [PFObject objectWithClassName:CLASS_PERSON_KEY];
        person[EMAIL_KEY] = email;
        // Now that person has been created remove from actualEmailsToInvite and add to actualInviteesToInvite
        [self.actualInviteesToInvite addObject:person];
        [save addObject:person];
    }

    if (self.updatedTitle) {
        self.parseEvent[EVENT_TITLE_KEY] = self.title;
    }

    if (self.updatedTimeframe) {
        self.parseEvent[EVENT_START_DATE_KEY] = self.startDate;
        self.parseEvent[EVENT_END_DATE_KEY] = self.endDate;
    }
    
    if (self.updatedLocation) {
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
    for (NSString *email in self.actualEmailsToInvite)
    {
        PFObject *person = [PFObject objectWithClassName:CLASS_PERSON_KEY];
        person[EMAIL_KEY] = email;
        // Now that person has been created remove from actualEmailsToInvite and add to actualInviteesToInvite
        [self.actualInviteesToInvite addObject:person];
        [save addObject:person];
    }
    
    self.parseEvent = [PFObject objectWithClassName:CLASS_EVENT_KEY];
    self.parseEvent[EVENT_CREATOR_KEY] = [AppDelegate parseUser];
    self.parseEvent[EVENT_START_DATE_KEY] = self.startDate;
    self.parseEvent[EVENT_END_DATE_KEY] = self.endDate;
    self.parseEvent[EVENT_TITLE_KEY] = self.title;

    PFObject *location = [self convertLocation];
    if (location) {
        [save addObject:location];
    }
    [save addObject:self.parseEvent];
    [PFObject saveAllInBackground:save target:self selector:@selector(eventCreatedWithResult:error:)];
}

- (PFObject *)convertLocation
{
    if (self.protoLocation) {
        // First, check if user is using saved location
        
        BOOL foundInSavedLocations = NO;
        
        for (PFObject *location in [AppDelegate user].locations) {
            if (location.objectId == self.protoLocation.pfObject.objectId) {
                self.parseEvent[EVENT_LOCATION_KEY] = location;
                foundInSavedLocations = YES;
                break;
            }
        }
        
        if (!foundInSavedLocations) {
            
            // If location does not exist in user's saved locations, create
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
            self.parseEvent[EVENT_LOCATION_KEY] = location;
            self.locationToSave = location;
            return location;
        }
    }
    return nil;
}

- (void)eventUpdatedWithResult:(NSNumber *)result error:(NSError *)error
{
    if ([result boolValue]) { // success

        NSMutableArray *save = [self.actualInviteesToInvite mutableCopy];

        // For some reason addUniqueObject is not adding to an existing array, but wiping the array first...
        self.parseEvent[EVENT_INVITEES_KEY] = [self.actualInviteesToInvite arrayByAddingObjectsFromArray:[AppDelegate user].protoEvent.existingInvitees];
        
        // Iterate through _invitee and pull out emails so that searching for busy times is easier later...
        for (PFObject *invitee in self.actualInviteesToInvite) {
            NSString *email = [invitee objectForKey:EMAIL_KEY];
            if (email && email.length > 0) {
                [self.parseEvent addUniqueObject:[NSString stringWithFormat:@"%@:%@", email, @(EventResponseNoResponse)] forKey:EVENT_RESPONSES_KEY];
            }
            [Event makeAdjustmentsToPerson:invitee event:self.parseEvent];
        }
        
        if (self.locationToSave) {
            [[AppDelegate parseUser] addUniqueObject:self.locationToSave forKey:LOCATIONS_KEY];
            [Event addLocation:self.locationToSave];
        }
        
        [save addObject:self.parseEvent];
        [save addObject:[AppDelegate parseUser]];
        
        [PFObject saveAllInBackground:save block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                // Do not email if only title was updated
                
                [self sendEventEmailUsingTemplate:kUpdatedEventCreator];
                
                if (self.addedEmails.count) {
                    [self sendEventEmailUsingTemplate:kNewEventNewUsers];
                }
                
                if (self.updatedLocation || self.updatedTimeframe) {

                    [self sendUpdatedNotification];
                    if (self.inviteeEmails.count && self.sendEmails) {
                        [self sendEventEmailUsingTemplate:kUpdatedEventInviteUsers];
                    }
                    
                } else if (self.updatedInvitees && self.sendEmails) {
                    [self sendEventEmailUsingTemplate:kUpdatedEventInviteUsers];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UPDATED_NOTIFICATION object:nil userInfo:nil];
                
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:STEP2_UPDATED_ERROR_NOTIFICATION object:nil userInfo:nil];
            }
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:STEP1_UPDATED_ERROR_NOTIFICATION object:nil userInfo:nil];
    }
}

- (void)eventCreatedWithResult:(NSNumber *)result error:(NSError *)error
{
    if ([result boolValue]) { // success
        
        NSMutableArray *save = [self.actualInviteesToInvite mutableCopy];

        // By now the new event and all people who had to be created for this event have been created...
        [self.parseEvent addUniqueObjectsFromArray:self.actualInviteesToInvite forKey:EVENT_INVITEES_KEY];
        
        // Iterate through _invitee and pull out emails so that searching for busy times is easier later...
        NSMutableArray *responses = [NSMutableArray array];
        for (PFObject *invitee in self.actualInviteesToInvite) {
            NSString *email = [invitee objectForKey:EMAIL_KEY];
            if (email && email.length > 0) {
                [responses addObject:[NSString stringWithFormat:@"%@:%@", email, @(EventResponseNoResponse)]];
            }
            [Event makeAdjustmentsToPerson:invitee event:self.parseEvent];
        }
        self.parseEvent[EVENT_RESPONSES_KEY] = responses;
        
        [[AppDelegate parseUser] addUniqueObject:self.parseEvent forKey:EVENTS_KEY];
        if (self.locationToSave) {
            [[AppDelegate parseUser] addUniqueObject:self.locationToSave forKey:LOCATIONS_KEY];
            [Event addLocation:self.locationToSave];
        }
        
        [save addObject:self.parseEvent];
        [save addObject:[AppDelegate parseUser]];
        
        [PFObject saveAllInBackground:save block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                if (![AppDelegate user].events) {
                    [AppDelegate user].events = [NSArray array];
                }
                NSMutableArray *events = [[AppDelegate user].events mutableCopy];
                [events addObject:self.parseEvent];
                [AppDelegate user].events = [User sortEvents:events];
                
                [self sendCreatedNotification];
                
                [self sendEventEmailUsingTemplate:kNewEventCreator];
                if (self.inviteeEmails.count && self.sendEmails) {
                    [self sendEventEmailUsingTemplate:kNewEventInviteUsers];
                }
                if (self.actualEmailsToInvite.count) {
                    [self sendEventEmailUsingTemplate:kNewEventNewUsers];
                }
                
                NSDictionary *userInfo = @{@"createdEvent": self.parseEvent};
                [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CREATED_NOTIFICATION object:nil userInfo:userInfo];
                
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:STEP2_CREATED_ERROR_NOTIFICATION object:nil userInfo:nil];
            }
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:STEP1_CREATED_ERROR_NOTIFICATION object:nil userInfo:nil];
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

+ (void)addLocation:(PFObject *)location
{
    if (![AppDelegate user].locations) {
        [AppDelegate user].locations = [NSArray array];
    }
    
    NSMutableArray *locations = [[AppDelegate user].locations mutableCopy];
    [locations addObject:location];
    [AppDelegate user].locations = locations;
}

- (void)sendCreatedNotification
{
    if (self.inviteeEmails) {
        PFQuery *query = [PFInstallation query];
        [query whereKey:EMAIL_KEY containedIn:self.inviteeEmails];
        
        // Send push notification to query
        [PFPush sendPushMessageToQueryInBackground:query
                                       withMessage:[NSString stringWithFormat:@"%@ sent you a new event: %@", self.host, self.title]];
    }
}

- (void)sendUpdatedNotification
{
    if (self.inviteeEmails) {
        PFQuery *query = [PFInstallation query];
        [query whereKey:EMAIL_KEY containedIn:self.inviteeEmails];
        
        // Send push notification to query
        [PFPush sendPushMessageToQueryInBackground:query
                                       withMessage:[NSString stringWithFormat:@"Event update: %@", self.title]];
    }
}

- (NSString *)locationText
{
        NSString *locationName;
        NSString *locationAddress;
        
        if (self.isParseEvent) {
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

- (void)sendEventEmailUsingTemplate:(NSString *)template
{
    NSMutableArray *vars = [NSMutableArray array];
    NSMutableArray *inviteesContent = [NSMutableArray array];
    
    for (PFObject *invitee in self.invitees) {
        NSString *display = invitee[FULL_NAME_KEY] ? invitee[FULL_NAME_KEY] : invitee[EMAIL_KEY];
        [inviteesContent addObject:@{@"display": display}];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM"];
    NSString *month = [[formatter stringFromDate:self.startDate] uppercaseString];
    [formatter setDateFormat:@"dd"];
    NSString *day = [formatter stringFromDate:self.startDate];

    [vars addObject:@{@"name": @"event_title",  @"content": self.title}];
    [vars addObject:@{@"name": @"host",         @"content": self.host}];
    [vars addObject:@{@"name": @"host_email",   @"content": self.creator[EMAIL_KEY]}];
    [vars addObject:@{@"name": @"time",         @"content": [AppDelegate viewTimeframeForStartDate:self.startDate endDate:self.endDate]}];
    [vars addObject:@{@"name": @"location",     @"content": [self locationText]}];
    [vars addObject:@{@"name": @"invitees",     @"content": inviteesContent}];
    [vars addObject:@{@"name": @"deeplink",     @"content": [NSString stringWithFormat:@"invite://%@", self.parseEvent.objectId]}];
    [vars addObject:@{@"name": @"time_month",   @"content": month}];
    [vars addObject:@{@"name": @"time_day",     @"content": day}];
    
    NSString *subject;
    
    if ([template isEqualToString:kNewEventCreator]) {
        subject = @"New event: %@";
    } else if ([template isEqualToString:kNewEventInviteUsers] || [template isEqualToString:kNewEventNewUsers]) {
        subject = @"You've been invited: %@";
    } else if ([template isEqualToString:kUpdatedEventCreator] || [template isEqualToString:kUpdatedEventInviteUsers]) {
        subject = @"Updated event: %@";
    }
    
    NSMutableArray *to = [NSMutableArray array];
    
    if ([template isEqualToString:kNewEventCreator] || [template isEqualToString:kUpdatedEventCreator]) {
        [to addObject:@{@"email": self.creator[EMAIL_KEY]}];
    } else if ([template isEqualToString:kNewEventInviteUsers] || [template isEqualToString:kUpdatedEventInviteUsers]) {
        
        if (self.updatedInvitees) {
            for (PFObject *invitee in self.addedInvitees) {
                [to addObject:@{@"email": invitee[EMAIL_KEY]}];
            }
        } else {
            for (NSString *email in self.inviteeEmails) {
                [to addObject:@{@"email": email}];
            }
        }
        
    } else if ([template isEqualToString:kNewEventNewUsers]) {
        if (self.updatedEmails) {
            for (NSString *email in self.addedEmails) {
                [to addObject:@{@"email": email}];
            }
        } else {
            for (NSString *email in self.actualEmailsToInvite) {
                [to addObject:@{@"email": email}];
            }
        }
    }
    
    [PFCloud callFunctionInBackground:@"email_template"
                       withParameters:@{@"template": template,
                                        @"to": to,
                                        @"global_merge_vars": vars,
                                        @"subject": [NSString stringWithFormat:subject, self.title],
                                        @"from_email": @"invite@appuous.com",
                                        @"from_name": @"Invite for iOS"
                                        } block:^(id object, NSError *error) {
                                            if (error) {
//                                                NSLog(@"%@", error.localizedDescription);
                                            }
                                        }];
}

@end
