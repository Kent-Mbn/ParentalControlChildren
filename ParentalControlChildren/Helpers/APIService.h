//
//  APIService.h
//  ProjectBase
//
//  Created by CHAU HUYNH on 9/19/14.
//  Copyright (c) 2014 CHAU HUYNH. All rights reserved.
//

//------SETUP SERVER IP------//

#define SERVER_IP   @"http://117.3.65.103/parental-control/public"
#define SERVER_PORT @"8015"

#define URL_SERVER_API_FULL [NSString stringWithFormat:@"%@", SERVER_IP]
#define URL_SERVER_API(method) [NSString stringWithFormat:@"%@%@",URL_SERVER_API_FULL,method]

#define API_DEVICE_REGISTER @"/device/register"
#define API_DEVICE_CONFIRM_REQUEST_PAIR(parent_id, child_id) [NSString stringWithFormat:@"/userdevice/updatestatus/%@/%@",parent_id, child_id]
#define API_ADD_NEW_HISTORY_DEVICE(device_id) [NSString stringWithFormat:@"/history/create/%@", device_id]
#define API_ADD_OLD_HISTORY_DEVICE(device_id) [NSString stringWithFormat:@"/history/addoldhistoryforios/%@", device_id]
#define API_GET_SAFE_AREA(child_id) [NSString stringWithFormat:@"/safearea/getsafearea/%@",child_id]
#define API_PUSH_NOTIFICATION @"/userdevice/pushnotificationios"
#define API_GET_PARENTS_OF_DEVICE(device_id) [NSString stringWithFormat:@"/userdevice/getparentofchild/%@", device_id]


/*
#define API_USER_LOGIN @"/user/auth"
#define API_GET_USER_POST_LIST @"/user/stat"
#define API_COMPOSE_POST @"/user/post"
#define API_UPLOAD_MEDIA(post_id) [NSString stringWithFormat:@"/post/%@/media", post_id]
#define API_GET_POST_OF_USER(user_id) [NSString stringWithFormat:@"/user/%@/post", user_id]
#define API_COMMENT_FOR_A_POST(post_id) [NSString stringWithFormat:@"/post/%@/comment", post_id]

#define API_UPDATE_LOCATION @"/user/location"
#define API_LIST_USER @"/user/search"
#define API_LIST_POST @"/post/search"
#define API_LIKE_DISLIKE_POST(post_id) [NSString stringWithFormat:@"/post/%@/vote", post_id]

#define API_CHANGE_NAME_MY_PROFILE @"/user/profile"
#define API_CHANGE_AVATAR_MY_PROFILE @"/user/avatar"

#define API_GET_PROFILE(user_id) [NSString stringWithFormat:@"/user/%@", user_id]
#define KEY_RESPONE_LOGIN_SUCCESS @"success"
 */



