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

@interface Common : NSObject

+(void)roundView:(UIView *) uView andRadius:(float) radius;
+(void) showAlertView:(NSString *)title message:(NSString *)message delegate:(UIViewController *)delegate cancelButtonTitle:(NSString *)cancelButtonTitle arrayTitleOtherButtons:(NSArray *)arrayTitleOtherButtons tag:(int)tag;
+ (CLLocationCoordinate2D) get2DCoordFromString:(NSString*)coordString;
+ (void) circleImageView:(UIView *) imgV;

@end
