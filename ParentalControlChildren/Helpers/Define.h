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

#pragma mark - CODE RESPONE FROM SERVER
#define CODE_RESPONE_SUCCESS 0

#define APP_NAME @"Child App"


#pragma mark - MESSAGE
#define MSS_NOTICE_SEND_SMS @"Are you sure send SMS?"

#define MSS_REGISTER_INVALID_PHONE_NUMBER @"Phone Number is invalid."
#define MSS_REGISTER_INVALID_FULL_NAME @"Full name is invalid."
#define MSS_REGISTER_INVALID_EMAIL @"Email is invalid."
#define MSS_REGISTER_FAILDED @"Register failed!"

#define MSS_CONFIRM_FAILED @"Confirm failed!"
#define MSS_CONFIRM_SUCCESS @"Confirm successfully!"


#pragma mark - ADDRESS BOOK
#define MSS_DENIED @"You must give the app permission to add the contact first."
