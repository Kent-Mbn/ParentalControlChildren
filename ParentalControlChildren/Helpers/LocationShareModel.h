//
//  LocationShareModel.h
//  Location
//
//  Created by Harry Tran on 4/17/15.
//  Copyright (c) 2015 HarryTran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface LocationShareModel : NSObject

@property (nonatomic) CLLocationManager * anotherLocationManager;

@property (nonatomic) NSMutableDictionary *myLocationDictInPlist;
@property (nonatomic) NSMutableArray *myLocationArrayInPlist;

@property (nonatomic) BOOL afterResume;

+(id)sharedModel;

@end
