//
//  Define.h
//  ParentalControlChildren
//
//  Created by CHAU HUYNH on 5/8/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

// Master color
#define masterColor [UIColor colorWithRed:49/255.0f green:144/255.0f blue:181/255.0f alpha:1.0]
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define kNotificationGetNewLocation @"kNotificationGetNewLocation"
#define timeTrackingLocation 5
#define timePauseTrackingLocation 5

#define timeCheckingSafeArea 10

//met
#define distanceCheckingFilter 2

#pragma mark - CODE RESPONE FROM SERVER
#define CODE_RESPONE_SUCCESS 0

#define APP_DELEGATE (AppDelegate *)[UIApplication sharedApplication].delegate

#define CONTENT_MSS_NOTIFY_DEFAULT @"Your childrent is going out the safe area!"

#define APP_NAME @"Child App"
#define NAME_LOCAL_FILE_SAVE_LOCATION @"localTrackingLocation.plist"

#pragma mark - MESSAGE
#define MSS_NOTICE_SEND_SMS @"Are you sure send SMS?"

#define MSS_REGISTER_INVALID_PHONE_NUMBER @"Phone Number is invalid."
#define MSS_REGISTER_INVALID_FULL_NAME @"Full name is invalid."
#define MSS_REGISTER_INVALID_EMAIL @"Email is invalid."
#define MSS_REGISTER_FAILDED @"Register failed!"

#define MSS_CONFIRM_FAILED @"Confirm failed!"
#define MSS_CONFIRM_SUCCESS @"Confirm successfully!"

#define MSS_PUSH_NOTI_OUT_SAFE_AREA @"Out safe area!!!"
#define MSS_PUSH_NOTI_FAILED @"Push notification failed!!"

#pragma mark - ADDRESS BOOK
#define MSS_DENIED @"You must give the app permission to add the contact first."

#pragma mark - TRACKING LOCATION
#define MSS_UIBackgroundRefreshStatusDenied @"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
#define MSS_UIBackgroundRefreshStatusRestricted @"The functions of this app are limited because the Background App Refresh is disable."

#pragma mark - EDIT MESSAGE
#define MSS_CONTENT_IS_NULL @"Content messge is not blank!"
