//
//  Common.h
//  ParentalControlChildren
//
//  Created by CHAU HUYNH on 5/8/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "Define.h"
#import "UserDefault.h"

@interface Common : NSObject

+(void)roundView:(UIView *) uView andRadius:(float) radius;
+(void) showAlertView:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle arrayTitleOtherButtons:(NSArray *)arrayTitleOtherButtons tag:(int)tag;
+ (CLLocationCoordinate2D) get2DCoordFromString:(NSString*)coordString;
+ (void) circleImageView:(UIView *) imgV;
+ (void) updateDeviceToken:(NSString *) newDeviceToken;
+ (NSString *) getDeviceToken;
+ (BOOL) isValidEmail:(NSString *)checkString;

+ (void) updateTimeWhenTerminateApp:(NSString *) time;
+ (NSString *) getTimeWhenTerminateApp;

+ (AFHTTPRequestOperationManager *)AFHTTPRequestOperationManagerReturn;
+ (BOOL) validateRespone:(id) respone;

+ (void) showNetworkActivityIndicator;
+ (void) hideNetworkActivityIndicator;
+ (void) showLoadingViewGlobal:(NSString *) titleaLoading;
+ (void) hideLoadingViewGlobal;

+ (NSString *) pathOfFileLocalTrackingLocation;
+ (void) writeArrayToFileLocalTrackingLocation:(NSMutableArray *) arrToWrite;
+ (NSMutableArray *) readFileLocalTrackingLocation;
+ (void) writeObjToFileTrackingLocation:(NSDictionary *) dicObj;
+ (void) removeFileLocalTrackingLocation;

+ (float) calDistanceTwoCoordinate:(CLLocationCoordinate2D)firstPoint andSecondPoint:(CLLocationCoordinate2D)secondPoint;

+ (NSString *) returnStringArrayLat:(NSMutableArray *) arrData;
+ (NSString *) returnStringArrayLong:(NSMutableArray *) arrData;
+ (NSString *) returnStringArrayCreatedAtLocation:(NSMutableArray *) arrData;
+ (NSArray *) returnArrayLocations:(NSString *) strLats andLongs:(NSString *)strLongs;

+ (void) addContactToArrayUserDefault:(NSArray *) arrIds andArrPhoneNumbers:(NSArray *)arrPhones;
+ (void) removeContactToArrayUserDefault:(NSArray *) arrIds andArrPhoneNumbers:(NSArray *)arrPhones;

+ (BOOL) isValidString:(NSString *) strCheck;

+ (BOOL) isValidCoordinate:(CLLocationCoordinate2D) checkPoint;

#pragma mark - Algorthim Checking Point In Polygon or In Circle
+ (BOOL) checkPointInsidePolygon:(NSMutableArray *) arrPonits andCheckPoint:(CLLocationCoordinate2D) checkPoint;
+ (float) angleOfThreePoints:(CLLocationCoordinate2D)anglePoint andSecondPoint:(CLLocationCoordinate2D) secondPoint andThirdPoint:(CLLocationCoordinate2D)thirdPoint;
+ (BOOL) checkPointInsideCircle:(float)radiusCircle andCenterPoint:(CLLocationCoordinate2D) centerPoint andCheckPoint:(CLLocationCoordinate2D) checkPoint;



@end
