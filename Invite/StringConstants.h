//
//  StringConstants.h
//  Invite
//
//  Created by Ryan Jennings on 2/17/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

typedef NS_ENUM(NSUInteger, EventResponse) {
    EventResponseNone,
    EventResponseGoing,
    EventResponseMaybe,
    EventResponseNotGoing
};

// Classes
#define CLASS_PERSON_KEY @"Person"
#define CLASS_EVENT_KEY @"Event"

// Event keys

#define EVENT_TITLE_KEY @"title"
#define EVENT_STARTDATE_KEY @"start_date"
#define EVENT_ENDDATE_KEY @"end_date"
#define EVENT_DESCRIPTION_KEY @"description"
#define EVENT_LOCATION_KEY @"location"
#define EVENT_INVITEES_KEY @"invitees"
#define EVENT_RSVP_KEY @"rsvp"
#define EVENT_CREATOR_KEY @"creator"
#define EVENT_COVERIMAGE_KEY @"cover_image"

// Keys
#define EMAIL_KEY @"email"
#define GENDER_KEY @"gender"
#define LOCALE_KEY @"locale"
#define FACEBOOK_ID_KEY @"facebook_id"
#define LAST_NAME_KEY @"last_name"
#define TIMEZONE_KEY @"timezone"
#define FACEBOOK_LINK_KEY @"facebook_link"
#define FULL_NAME_KEY @"full_name"
#define FIRST_NAME_KEY @"first_name"
#define EVENTS_KEY @"events"
#define OBJECTID_KEY @"objectId"
#define FRIENDS_KEY @"friends"
#define FRIENDEMAILS_KEY @"friendEmails"

// Keys used by Facebook
#define ID_KEY @"id"
#define LINK_KEY @"link"
#define NAME_KEY @"name"

// Controllers
#define LOGIN_VIEW_CONTROLLER @"LoginViewController"
#define DASHBOARD_VIEW_CONTROLLER @"DashboardViewController"
#define EVENT_VIEW_CONTROLLER @"EventViewController"

// Segues
#define SEGUE_TO_INVITEES @"SegueToInvitees"
#define SEGUE_TO_TIMEFRAME @"SegueToTimeframe"
#define SEGUE_TO_LOGIN @"SegueToLogin"
#define SEGUE_TO_DASHBOARD @"SegueToDashboard"
#define SEGUE_TO_EVENT @"SegueToEvent"

// Table cell identifiers
#define INVITEE_CELL_IDENTIFIER @"InviteeCellIdentifier"
#define TIMEFRAME_HOUR_CELL_IDENTIFIER @"TimeframeHourCellIdentifier"
#define DASHBOARD_EVENT_CELL_IDENTIFIER @"DashboardEventCellIdentifier"
#define EVENT_RSVP_CELL_IDENTIFIER @"EventRSVPCellIdentifier"
#define EVENT_TEXT_CELL_IDENTIFIER @"EventTextCellIdentifier"
#define EVENT_EDIT_CELL_IDENTIFIER @"EventEditCellIdentifier"

// Notifications
#define USER_CREATED_NOTIFICATION @"UserCreatedNotifcation"
#define DELETE_USER_NOTIFICATION @"DeleteUserNotifcation"
#define EVENT_CREATED_NOTIFICATION @"EventCreatedNotification"
#define PARSE_LOADED_NOTIFICATION @"ParseLoadedNotification"
