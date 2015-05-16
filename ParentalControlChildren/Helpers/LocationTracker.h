//
//  LocationTracker.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationShareModel.h"
#import "Define.h"
#import "Common.h"

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;

@property (strong,nonatomic) LocationShareModel * shareModel;

@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;

//@property times
@property (nonatomic) NSTimeInterval timeIntervalGetLocationTracking;
@property (nonatomic) NSTimeInterval timeDelayTracking;
@property (nonatomic) NSTimeInterval timeProcessTracking;

//@property distance filter
@property (nonatomic) NSInteger distanceFilterTracking;

+ (CLLocationManager *)sharedLocationManager;

- (void)startLocationTracking;
- (void)restartLocationUpdates;
- (void)stopLocationTracking;
- (void)updateLocationToServer;


@end
