//
//  LocationTracker.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location All rights reserved.
//

#import "LocationTracker.h"

#define LATITUDE @"latitude"
#define LONGITUDE @"longitude"
#define ACCURACY @"theAccuracy"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation LocationTracker

+ (CLLocationManager *)sharedLocationManager {
	static CLLocationManager *_locationManager;
	
	@synchronized(self) {
		if (_locationManager == nil) {
			_locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.distanceFilter = kCLDistanceFilterNone;
		}
	}
	return _locationManager;
}

- (id)init {
	if (self==[super init]) {
        //Get the share model and also initialize myLocationArray
        self.shareModel = [LocationShareModel sharedModel];
        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
	return self;
}

-(void)applicationEnterBackground{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    //Use the BackgroundTaskManager to manage all the background Task
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
}

- (void) restartLocationUpdates
{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
}


- (void)startLocationTracking {
    NSLog(@"startLocationTracking");

	if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
		UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[servicesDisabledAlert show];
	} else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            
            if(IS_OS_8_OR_LATER) {
              [locationManager requestAlwaysAuthorization];
            }
            [locationManager startUpdatingLocation];
            
            /* Begin time interval tracking loaction, config from user */
            [self startTimerProcessTracking];
            [self startTimerIntervalUpdateLocationTracking];
            [self startTimerIntervalGetLocationTracking];
        }
	}
}


- (void)stopLocationTracking {
    NSLog(@"stopLocationTracking");
    
	CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
	[locationManager stopUpdatingLocation];
    
    [self stopTimerProcessTracking];
    [self stopTimerIntervalUpdateLocationTracking];
    [self stopTimerDelayTracking];
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];
    
    //Only get last location
    NSLog(@"Update locations: %@", locations);
    CLLocation * newLocation = [locations lastObject];
    self.myLastLocation = newLocation.coordinate;
    self.myLastLocationAccuracy= newLocation.horizontalAccuracy;
    
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
}


//Stop the locationManager
-(void)stopLocationDelayTracking{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];
    NSLog(@"locationManager stop Updating after %f seconds", self.timeDelayTracking);
}

- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service" message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
        {
            
        }
            break;
    }
}


//Send the location to Server
- (void)updateLocationToServer {
    //Your code to send the self.myLocation and self.myLocationAccuracy to your server
    NSDictionary *dicObj = [NSDictionary dictionaryWithObjects:@[@(self.myLastLocation.latitude),@(self.myLastLocation.longitude),@"background"] forKeys:@[@"lat",@"long",@"type"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGetNewLocation object:self userInfo:dicObj];
}

#pragma mark - TIMER
- (void) startTimerIntervalGetLocationTracking {
    [self stopTimerIntervalGetLocationTracking];
    NSLog(@"---startTimerIntervalGetLocationTracking");
    self.shareModel.timerIntervalGetLocationTracking = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalGetLocationTracking
                                                                          target:self
                                                                        selector:@selector(endTimerIntervalGetLocationTracking)
                                                                        userInfo:nil
                                                                         repeats:YES];
}
- (void) startTimerIntervalUpdateLocationTracking {
    [self stopTimerIntervalUpdateLocationTracking];
    NSLog(@"---startTimerIntervalUpdateLocationTracking");
    self.shareModel.timerIntervalUpdateLocationTracking = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalGetLocationTracking
                                                                          target:self
                                                                        selector:@selector(endTimerIntervalUpdateLocationTracking)
                                                                        userInfo:nil
                                                                         repeats:YES];
}
- (void) startTimerDelayTracking {
    [self stopTimerDelayTracking];
    NSLog(@"---startTimerDelayTracking");
    self.shareModel.timerDelayTracking = [NSTimer scheduledTimerWithTimeInterval:self.timeDelayTracking
                                                                          target:self
                                                                        selector:@selector(endTimerDelayTracking)
                                                                        userInfo:nil
                                                                         repeats:NO];
}
- (void) startTimerProcessTracking {
    [self stopTimerProcessTracking];
    NSLog(@"---startTimerProcessTracking");
    self.shareModel.timerProcessTracking = [NSTimer scheduledTimerWithTimeInterval:self.timeProcessTracking
                                                                          target:self
                                                                        selector:@selector(endTimerProcessTracking)
                                                                        userInfo:nil
                                                                         repeats:YES];
}
- (void) stopTimerIntervalGetLocationTracking {
    NSLog(@"----stopTimerIntervalGetLocationTracking");
    if (self.shareModel.timerIntervalGetLocationTracking) {
        [self.shareModel.timerIntervalGetLocationTracking invalidate];
        self.shareModel.timerIntervalGetLocationTracking = nil;
    }
}
- (void) stopTimerIntervalUpdateLocationTracking {
    NSLog(@"----stopTimerIntervalUpdateLocationTracking");
    if (self.shareModel.timerIntervalUpdateLocationTracking) {
        [self.shareModel.timerIntervalUpdateLocationTracking invalidate];
        self.shareModel.timerIntervalUpdateLocationTracking = nil;
    }
}
- (void) stopTimerDelayTracking {
    NSLog(@"----stopTimerDelayTracking");
    if (self.shareModel.timerDelayTracking) {
        [self.shareModel.timerDelayTracking invalidate];
        self.shareModel.timerDelayTracking = nil;
    }
}
- (void) stopTimerProcessTracking {
    NSLog(@"----stopTimerProcessTracking");
    if (self.shareModel.timerProcessTracking) {
        [self.shareModel.timerProcessTracking invalidate];
        self.shareModel.timerProcessTracking = nil;
    }
}
- (void) endTimerIntervalGetLocationTracking {
    NSLog(@"----endTimerIntervalGetLocationTracking");
    //function excute new location
    [self updateLocationToServer];
}
- (void) endTimerIntervalUpdateLocationTracking {
    NSLog(@"----endTimerIntervalUpdateLocationTracking");
    //Get new location
    [self restartLocationUpdates];
}
- (void) endTimerDelayTracking {
    NSLog(@"----endTimerDelayTracking");
    //Start process tracking
    [self startTimerProcessTracking];
    
    //Start timer update location
    [self startTimerIntervalUpdateLocationTracking];
}
- (void) endTimerProcessTracking {
    NSLog(@"----endTimerProcessTracking");
    //Stop process tracking
    [self stopTimerProcessTracking];
    
    //Stop timer update location
    [self stopTimerIntervalUpdateLocationTracking];
    
    //Start timer delay tracking
    [self startTimerDelayTracking];
    
    //Begin delay time
    [self stopLocationDelayTracking];
}



@end
