//
//  StringConstants.h
//  Invite
//
//  Created by Ryan Jennings on 2/17/15.
//  Copyright (c) 2015 Appuous. All rights reserved.
//

typedef NS_ENUM(NSUInteger, EventMyResponse) {
    EventMyResponseNoResponse,
    EventMyResponseGoing,
    EventMyResponseMaybe,
    EventMyResponseSorry,
    EventMyResponseHost
};

typedef NS_ENUM(NSUInteger, EventResponse) {
    EventResponseNoResponse,
    EventResponseGoing,
    EventResponseMaybe,
    EventResponseSorry,
    EventResponseHost
};

// NSUserDefault Keys
#define kSendMeEmail @"SendMeEmail"
#define kShowAvailability @"ShowAvailability"
#define kRemoveEventsAfterExpire @"RemoveEventsAfterExpire"

#define kGoingText @"I'll be there!"
#define kMaybeText @"Maybe"
#define kSorryText @"Sorry, I can't make it"
#define kNoResponseText @"Respond to this event!"
#define kHostText @"You are the host"

#define kCornerRadius 6.f
#define kFooterPadding 20.f

// Classes
#define CLASS_PERSON_KEY @"Person"
#define CLASS_EVENT_KEY @"Event"
#define CLASS_LOCATION_KEY @"Location"

// Location keys
#define LOCATION_ADDRESS_KEY @"address"
#define LOCATION_NAME_KEY @"name"
#define LOCATION_LONGITUDE_KEY @"longitude"
#define LOCATION_LATITUDE_KEY @"latitude"
#define LOCATION_FOURSQUARE_ID_KEY @"foursquare_id"

// Event keys
#define EVENT_TITLE_KEY @"title"
#define EVENT_START_DATE_KEY @"start_date"
#define EVENT_END_DATE_KEY @"end_date"
#define EVENT_DESCRIPTION_KEY @"description"
#define EVENT_LOCATION_KEY @"location"
#define EVENT_INVITEES_KEY @"invitees"
#define EVENT_RESPONSES_KEY @"responses"
#define EVENT_CREATOR_KEY @"creator"

// Keys
#define EMAIL_KEY @"email"
#define GENDER_KEY @"gender"
#define LOCALE_KEY @"locale"
#define FACEBOOK_ID_KEY @"facebook_id"
#define LAST_NAME_KEY @"last_name"
#define FACEBOOK_LINK_KEY @"facebook_link"
#define FULL_NAME_KEY @"full_name"
#define FIRST_NAME_KEY @"first_name"
#define EVENTS_KEY @"events"
#define FRIENDS_KEY @"friends"
#define FRIENDS_EMAILS_KEY @"friends_emails"
#define LOCATIONS_KEY @"locations"
#define OBJECT_ID @"objectId"

// Keys used by Facebook
#define ID_KEY @"id"
#define LINK_KEY @"link"
#define NAME_KEY @"name"

// Controllers
#define LAUNCH_VIEW_CONTROLLER @"LaunchViewController"
#define LOGIN_VIEW_CONTROLLER @"LoginViewController"
#define DASHBOARD_VIEW_CONTROLLER @"DashboardViewController"
#define TITLE_VIEW_CONTROLLER @"TitleViewController"
#define INVITEES_VIEW_CONTROLLER @"InviteesViewController"
#define TIMEFRAME_VIEW_CONTROLLER @"TimeframePickerViewController"
#define LOCATION_VIEW_CONTROLLER @"LocationViewController"
#define EVENT_VIEW_CONTROLLER @"EventViewController"
#define EVENT_NAVIGATION_CONTROLLER @"EventNavigationController"
#define SETTINGS_VIEW_CONTROLLER @"SettingsViewController"
#define INVITEES_SECTION_VIEW_CONTROLLER @"InviteesSectionViewController"
#define LOCATION_RESULTS_VIEW_CONTROLLER @"LocationResultsViewController"

// Segues
#define SEGUE_TO_LOGIN @"SegueToLogin"
#define SEGUE_TO_DASHBOARD @"SegueToDashboard"
#define SEGUE_TO_INVITEES @"SegueToInvitees"
#define SEGUE_TO_TITLE @"SegueToTitle"
#define SEGUE_TO_TIMEFRAME @"SegueToTimeframe"
#define SEGUE_TO_LOCATION @"SegueToLocation"
#define SEGUE_TO_EVENT @"SegueToEvent"
#define SEGUE_TO_START_DATE @"SegueToStartDate"
#define SEGUE_TO_END_DATE @"SegueToEndDate"
#define SEGUE_TO_CONTACTS @"SegueToContacts"
#define SEGUE_TO_SETTINGS @"SegueToSettings"
#define SEGUE_TO_INVITEES_SECTION @"SegueToInviteesSection"

// Table cell identifiers
#define MAP_CELL_IDENTIFIER @"MapCellIdentifier"
#define BASIC_CELL_IDENTIFIER @"BasicCellIdentifier"
#define BASIC_RIGHT_CELL_IDENTIFIER @"BasicRightCellIdentifier"
#define INPUT_CELL_IDENTIFIER @"InputCellIdentifier"
#define NUMBERED_INPUT_CELL_IDENTIFIER @"NumberedInputCellIdentifier"
#define RADIO_CELL_IDENTIFIER @"RadioCellIdentifier"
#define DASHBOARD_CELL_IDENTIFIER @"DashboardCellIdentifier"
#define PROFILE_CELL_IDENTIFIER @"ProfileCellIdentifier"
#define INVITEES_CELL_IDENTIFIER @"InviteesCellIdentifier"
#define INVITEES_COLLECTION_CELL_IDENTIFIER @"InviteesCollectionCellIdentifier"
#define INVITEES_COLLECTION_HEADER_VIEW_IDENTIFIER @"InviteesCollectionHeaderViewIdentifier"
#define CONFLICT_CELL_IDENTIFIER @"ConflictCellIdentifier"
#define TOGGLE_CELL_IDENTIFIER @"ToggleCellIdentifier"
#define TITLE_DATE_CELL_IDENTIFIER @"TitleDateCellIdentifier"
#define LABEL_CELL_IDENTIFIER @"LabelCellIdentifier"
#define PADDING_CELL_IDENTIFIER @"PaddingCellIdentifier"
#define NO_CELL_IDENTIFIER @"NoCellIdentifier"
#define BUTTON_CELL_IDENTIFIER @"ButtonCellIdentifier"
#define LOCATION_CELL_IDENTIFIER @"LocationCellIdentifier"
#define DASHBOARD_AD_CELL_IDENTIFIER @"DashboardAdCellIdentifier"

// Notifications
#define USER_CREATED_NOTIFICATION @"UserCreatedNotifcation"
#define DELETE_USER_NOTIFICATION @"DeleteUserNotifcation"
#define EVENT_CREATED_NOTIFICATION @"EventCreatedNotification"
#define EVENT_UPDATED_NOTIFICATION @"EventUpdatedNotification"
#define DISMISS_EVENT_CONTROLLER_NOTIFICATION @"DismissEventControllerNotification"
#define EVENT_CLOSED_NOTIFICATION @"EventClosedNotification"
#define PARSE_LOADED_NOTIFICATION @"ParseLoadedNotification"
#define APPLICATION_WILL_RESIGN_ACTIVE_NOTIFICATION @"ApplicationWillResignActiveNotification"
#define USER_LOGGED_OUT_NOTIFICATION @"UserLoggedOutNotifcation"
#define DEEPLINK_NOTIFICATION @"DeeplinkNotifcation"
#define FINISHED_REFRESHING_EVENTS_NOTIFICATION @"FinishedRefreshingEventsNotifcation"
#define FINISHED_REMOVING_EVENT_NOTIFICATION @"RemovedEventNotifcation"
