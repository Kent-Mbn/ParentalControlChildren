//
//  AppDelegate.m
//  ParentalControlChildren
//
//  Created by CHAU HUYNH on 5/6/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "AppDelegate.h"

#define kNotificationEnableTrackingLocations @"trackingLocation"
#define kNotificationReloadTrackingLocations @"reloadTrackingLocation"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationEnableTrackingLocations object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationGetNewLocation object:nil];
}

- (BOOL) application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /* Register push notification */
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.shareModel = [LocationShareModel sharedModel];
    self.shareModel.afterResume = NO;
    typeSafeArea = radiusShape;
    
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
        [Common showAlertView:APP_NAME message:MSS_UIBackgroundRefreshStatusDenied delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        [Common showAlertView:APP_NAME message:MSS_UIBackgroundRefreshStatusRestricted delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
    } else{
        
        /* INIT for background mode */
        self.locationTracker = [[LocationTracker alloc]init];
        self.locationTracker.timeIntervalGetLocationTracking = timeTrackingLocation;
        self.locationTracker.timeProcessTracking = 60;
        self.locationTracker.timeDelayTracking = 10;
        [self.locationTracker startLocationTracking];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(returnNewLocation:)
                                                     name:kNotificationGetNewLocation
                                                   object:nil];
        /* INIT for filled app */
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            // This "afterResume" flag is just to show that he receiving location updates
            // are actually from the key "UIApplicationLaunchOptionsLocationKey"
            self.shareModel.afterResume = YES;
            self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
            self.shareModel.anotherLocationManager.delegate = self;
            self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.shareModel.anotherLocationManager.distanceFilter = kCLDistanceFilterNone;
            
            if(IS_OS_8_OR_LATER) {
                [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
            }
            
            [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
        } else if([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
            [self actionAskForPair:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
        }
    }
    
    //Redirect to Home or not
    if ([Common isValidString:[NSString stringWithFormat:@"%@", [UserDefault user].child_id]]) {
        //Push to Home screen
        [self setGotoHomeChild:^{
            
        }];
    } else {
        [self setGoToRegister:^{
            
        }];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //Remove the "afterResume" Flag after the app is active again.
    self.shareModel.afterResume = NO;
    
    if(self.shareModel.anotherLocationManager)
        [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
    self.shareModel.anotherLocationManager.delegate = self;
    self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.shareModel.anotherLocationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    
    //Remove all data
    [Common removeFileLocalTrackingLocation];
}

#pragma mark - NOTIFICATION DELEGATE
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    NSString *tokenStr = [deviceToken description];
    tokenStr = [tokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    tokenStr = [tokenStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    tokenStr = [tokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    [Common updateDeviceToken:tokenStr];
    [[UserDefault user] setToken_device:tokenStr];
    [UserDefault update];
    NSLog(@"Device Token Child App: %@", tokenStr);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    NSLog(@"Failed to register with error : %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"userInfo: %@", userInfo);
    application.applicationIconBadgeNumber = 0;
    [self actionAskForPair:userInfo];
}

- (void) actionAskForPair:(NSDictionary *) userInfo {
    NSString *msg = userInfo[@"aps"][@"alert"];
    [Common showAlertView:APP_NAME message:msg delegate:self cancelButtonTitle:@"Cancel" arrayTitleOtherButtons:@[@"Confirm"] tag:1];
    strPusherId = userInfo[@"aps"][@"pusher_id"];
    strChildId = [UserDefault user].child_id;
}

#pragma mark - FUNCTIONS
- (void) callWSConfirmAddPair:(NSString *) strParentId andStrChildId:(NSString *) strChildrentId {
    [Common showLoadingViewGlobal:nil];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_DEVICE_CONFIRM_REQUEST_PAIR(strParentId, strChildrentId)));
    [manager POST:URL_SERVER_API(API_DEVICE_CONFIRM_REQUEST_PAIR(strParentId, strChildrentId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideLoadingViewGlobal];
        NSLog(@"response: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            //Save is Paired and device token of parent
            [UserDefault user].isPaired = @"YES";
            [[UserDefault user] update];
            if ([[UserDefault user].isPaired isEqualToString:@"YES"]) {
                //Start system checking safe area
                [self beginCheckingSafeArea];
                [self beginTrackingSaveLocations];
            }
            
            [Common showAlertView:APP_NAME message:MSS_CONFIRM_SUCCESS delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
        } else {
            [Common showAlertView:APP_NAME message:MSS_CONFIRM_FAILED delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideLoadingViewGlobal];
        [Common showAlertView:APP_NAME message:MSS_CONFIRM_FAILED delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
    }];
}

- (void) setGoToRegister:(dispatch_block_t)block
{
    UIStoryboard *storyboard = [self.window.rootViewController storyboard];
    if (!storyboard) {
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    }
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_ID_REGISTER"];
    
    if (![self.window.rootViewController isEqual:viewController]) {
        self.window.rootViewController = viewController;
        if (block) {
            block();
        }
    }
}

- (void) setGotoHomeChild:(dispatch_block_t)block
{
    UIStoryboard *storyboard = [self.window.rootViewController storyboard];
    if (!storyboard) {
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    }
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_ID_HOME"];
    
    if (![self.window.rootViewController isEqual:viewController]) {
        self.window.rootViewController = viewController;
        if (block) {
            block();
        }
    }
}


#pragma mark - ALERT DELEGATE
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == 1) {
        if ([Common isValidString:strChildId] && [Common isValidString:strPusherId]) {
            [self callWSConfirmAddPair:strPusherId andStrChildId:strChildId];
        }
    }
}

#pragma mark - LOCATION
/*
-(void)updateLocation {
    [self.locationTracker updateLocationToServer];
}

- (void) restartLocation {
    [self.locationTracker restartLocationUpdates];
}
 */

- (void) returnNewLocation :(NSNotification *) noti {
    NSDictionary *theData = [noti userInfo];
    if (theData != nil) {
        NSLog(@"+++ New location: %@", theData);
        CLLocationCoordinate2D newLocation = [Common get2DCoordFromString:[NSString stringWithFormat:@"%@,%@", theData[@"lat"], theData[@"long"]]];
        lastLocationAppDelegate = newLocation;
        
        /*
        if (CLLocationCoordinate2DIsValid(lastLocationAppDelegate)) {
            if ([Common calDistanceTwoCoordinate:lastLocationAppDelegate andSecondPoint:newLocation] > distanceCheckingFilter) {
                lastLocationAppDelegate = newLocation;
                //Write location to file
                 NSDictionary *dicObj = [NSDictionary dictionaryWithObjects:@[@(lastLocationAppDelegate.latitude),@(lastLocationAppDelegate.longitude),@"background"] forKeys:@[@"lat",@"long",@"type"]];
                 [Common writeObjToFileTrackingLocation:dicObj];
            }
        }
         */
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    NSLog(@"Killed app -> send location to server");
    //Call to server with new location, if fail save to local.
    //[self callWSAddNewLocation:location.coordinate];
}


#pragma mark - CORE DATA

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "gcs.vn.company.ParentalControlChildren" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ParentalControlChildren" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ParentalControlChildren.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - CHECKING SAFE AREA
- (void) beginCheckingSafeArea {
    //Begin for first call
    [self updateSafeArea];
    if (self.timerTrackingSafeArea) {
        [self.timerTrackingSafeArea invalidate];
        self.timerTrackingSafeArea = nil;
    }
    self.timerTrackingSafeArea = [NSTimer scheduledTimerWithTimeInterval:timeCheckingSafeArea
                                     target:self
                                   selector:@selector(endTimerCheckingSafeArea)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) endTimerCheckingSafeArea {
    [self updateSafeArea];
}

- (void) notifyToParent {
    if (lastLocationAppDelegate.latitude != 0 && lastLocationAppDelegate.longitude != 0) {
        if (typeSafeArea == radiusShape) {
            if (centerPointCircle.latitude !=0 && centerPointCircle.longitude != 0 && radiusCircle > 0) {
                if (![Common checkPointInsideCircle:radiusCircle andCenterPoint:centerPointCircle andCheckPoint:lastLocationAppDelegate]) {
                    [self callGetParentsTokenDeviceAndPush];
                    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                        [self callMessageVC];
                    }
                }
            }
        } else {
            if ([_arrayForPolygon count] > 2) {
                if (![Common checkPointInsidePolygon:_arrayForPolygon andCheckPoint:lastLocationAppDelegate]) {
                    [self callGetParentsTokenDeviceAndPush];
                    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                        [self callMessageVC];
                    }
                }
            }
        }
    }
}

- (void) updateSafeArea {
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            
                                            } mutableCopy];
    //NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_GET_SAFE_AREA(@"3")));
    [manager POST:URL_SERVER_API(API_GET_SAFE_AREA([UserDefault user].child_id)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideNetworkActivityIndicator];
        //NSLog(@"response: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            NSArray *arrData = (NSArray *)responseObject;
            NSArray *arrSafeAreaData;
            if (arrData[0] != nil) {
                NSDictionary *dicData = arrData[0];
                arrSafeAreaData = dicData[@"safeArea"];
            } else {
                return;
            }
            if ([arrSafeAreaData count] == 1) {
                //Draw circle
                typeSafeArea = radiusShape;
                NSDictionary *objPoint = [arrSafeAreaData objectAtIndex:0];
                [[UserDefault user] setLats:objPoint[@"latitude"]];
                [[UserDefault user] setLongs:objPoint[@"longitude"]];
                [[UserDefault user] setRadiusCircle:objPoint[@"radius"]];
                [UserDefault update];
                
                NSLog(@"Lats: %@", [UserDefault user].lats);
                
                centerPointCircle = [Common get2DCoordFromString:[NSString stringWithFormat:@"%@,%@", objPoint[@"latitude"], objPoint[@"longitude"]]];
                radiusCircle = [objPoint[@"radius"] intValue];
                
            } else {
                //Draw polygon
                typeSafeArea = polygonShape;
                [[UserDefault user] setRadiusCircle:@"0"];
                NSMutableArray *arrLocations = [[NSMutableArray alloc] init];
                for (int i = 0; i < [arrSafeAreaData count]; i++) {
                    NSDictionary *objPoint = [arrSafeAreaData objectAtIndex:i];
                    CLLocation *locationPoint = [[CLLocation alloc] initWithLatitude:[objPoint[@"latitude"] doubleValue] longitude:[objPoint[@"longitude"] doubleValue]];
                    [arrLocations addObject:locationPoint];
                }
                [[UserDefault user] setLats:[Common returnStringArrayLat:arrLocations]];
                [[UserDefault user] setLongs:[Common returnStringArrayLong:arrLocations]];
                [UserDefault update];
                
                _arrayForPolygon = arrLocations;
            }
            [self notifyToParent];
        } else {
            //Can not get safe area
            [self updateSafeAreaOffline];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideNetworkActivityIndicator];
        NSLog(@"Error Update SafeArea: %@", error.description);
        [self updateSafeAreaOffline];
    }];
}

- (void) updateSafeAreaOffline {
    //Get data from userdefault.
    NSString *strRadius;
    NSString *strLats;
    NSString *strLongs;
    
    NSLog(@"radiusCircle: %@", [UserDefault user].radiusCircle);
    
    strRadius = [NSString stringWithFormat:@"%@", [UserDefault user].radiusCircle];
    strLats = [NSString stringWithFormat:@"%@", [UserDefault user].lats];
    strLongs = [NSString stringWithFormat:@"%@", [UserDefault user].longs];
    
    //Check lat long length > 0, check radius of circle, if = 0 -> polygon else is circle.
    
    if ([Common isValidString:strLats] && [Common isValidString:strLongs]) {
        if (strRadius == nil || [strRadius isEqualToString:@"0"]) {
            //polygon
            NSArray *arrSafeAreaDataLats = [strLats componentsSeparatedByString:@";"];
            NSArray *arrSafeAreaDataLongs = [strLongs componentsSeparatedByString:@";"];
            typeSafeArea = polygonShape;
            NSMutableArray *arrLocations = [[NSMutableArray alloc] init];
            for (int i = 0; i < [arrSafeAreaDataLats count]; i++) {
                CLLocation *locationPoint = [[CLLocation alloc] initWithLatitude:[[arrSafeAreaDataLats objectAtIndex:i] doubleValue] longitude:[[arrSafeAreaDataLongs objectAtIndex:i] doubleValue]];
                [arrLocations addObject:locationPoint];
            }
            _arrayForPolygon = arrLocations;
        } else {
            //circle
            typeSafeArea = radiusShape;
            centerPointCircle = [Common get2DCoordFromString:[NSString stringWithFormat:@"%@,%@", strLats, strLongs]];
            radiusCircle = [strRadius intValue];
        }
    }
    
    //call notify to parent.
    [self notifyToParent];
}

- (void) callMessageVC {
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *alV = [[UIAlertView alloc] initWithTitle:@"SMS" message:@"Your device doesn't support SMS!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alV show];
        return;
    }
    NSArray *arrPhoneNumbers = [[NSArray alloc] initWithArray:[[UserDefault user].arrPhoneNumbers componentsSeparatedByString:@"*"]];
    NSLog(@"arr phone number: %@", arrPhoneNumbers);
    
    if ([arrPhoneNumbers count] > 0) {
        NSString *messageString = [UserDefault user].content_mss;
        if (messageString.length == 0) {
            messageString = @"Out of safeare!";
        }
        
        MFMessageComposeViewController *messController = [[MFMessageComposeViewController alloc] init];
        messController.messageComposeDelegate = self;
        [messController setRecipients:arrPhoneNumbers];
        [messController setBody:messageString];
        
        [self.window.rootViewController presentViewController:messController animated:YES completion:^{
            
        }];
    } else {
        UIAlertView *alV = [[UIAlertView alloc] initWithTitle:@"SMS" message:@"No phone number!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alV show];
        return;
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
        {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"SMS" message:@"Send failed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertV show];
            break;
        }
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) callGetParentsTokenDeviceAndPush {
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_GET_PARENTS_OF_DEVICE([UserDefault user].child_id)));
    [manager POST:URL_SERVER_API(API_GET_PARENTS_OF_DEVICE([UserDefault user].child_id)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideNetworkActivityIndicator];
        if ([Common validateRespone:responseObject]) {
            if (responseObject[0][@"data"]) {
                NSArray *arrDatas = responseObject[0][@"data"];
                if ([arrDatas count] > 0) {
                    for (int i = 0; i < [arrDatas count]; i++) {
                        NSDictionary *dicAParent = [arrDatas objectAtIndex:i];
                        [self callPushNotification:dicAParent[@"register_id"]];
                    }
                }
            }
        } else {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideNetworkActivityIndicator];
        
    }];

}

- (void) callPushNotification:(NSString *)parentDevice {
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            @"device_token":parentDevice,
                                            @"push_to":@"parent",
                                            @"message":MSS_PUSH_NOTI_OUT_SAFE_AREA,
                                            @"pusher_id":[UserDefault user].child_id,
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_PUSH_NOTIFICATION));
    [manager POST:URL_SERVER_API(API_PUSH_NOTIFICATION) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideLoadingViewGlobal];
        NSLog(@"response: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            
        } else {
            [Common showAlertView:APP_NAME message:MSS_PUSH_NOTI_FAILED delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideNetworkActivityIndicator];
        NSLog(@"Error callPushNotification: %@", error.description);
        [Common showAlertView:APP_NAME message:MSS_PUSH_NOTI_FAILED delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
    }];
}

#pragma mark - TRACKING SAVE LOCATIONS HISTORY
- (void) beginTrackingSaveLocations {
    NSLog(@"------  beginTrackingSaveLocations");
    if (self.timerTrackingSaveLocations) {
        [self.timerTrackingSaveLocations invalidate];
        self.timerTrackingSaveLocations = nil;
    }
    if (self.timerTrackingSaveLocationsMoving) {
        [self.timerTrackingSaveLocationsMoving invalidate];
        self.timerTrackingSaveLocationsMoving = nil;
    }
    self.timerTrackingSaveLocations = [NSTimer scheduledTimerWithTimeInterval:timeTrackingSaveLocations
                                                                  target:self
                                                                selector:@selector(endTimerTrackingSaveLocations)
                                                                userInfo:nil
                                                                 repeats:YES];
    self.timerTrackingSaveLocations = [NSTimer scheduledTimerWithTimeInterval:timeTrackingSaveLocationsMoving
                                                                       target:self
                                                                     selector:@selector(endTimerTrackingSaveLocationsMoving)
                                                                     userInfo:nil
                                                                      repeats:YES];
    centerTrackingMoving = middleTrackingMoving = lastLocationAppDelegate;
}

- (void) restartTrackingSaveLocationsMoving {
    NSLog(@"------  restartTrackingSaveLocationsMoving");
    if (self.timerRestartTrackingSaveLocationsMoving) {
        [self.timerRestartTrackingSaveLocationsMoving invalidate];
        self.timerRestartTrackingSaveLocationsMoving = nil;
    }
    self.timerRestartTrackingSaveLocationsMoving = [NSTimer scheduledTimerWithTimeInterval:10
                                                                       target:self
                                                                     selector:@selector(endTimerRestartTrackingSaveLocationsMoving)
                                                                     userInfo:nil
                                                                      repeats:YES];
}

- (void) callWSAddNewLocation:(CLLocationCoordinate2D) newPoint {
    NSLog(@"------  callWSAddNewLocation");
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            @"latitude":@(newPoint.latitude),
                                            @"longitude":@(newPoint.longitude),
                                            @"address":@"address",
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_ADD_NEW_HISTORY_DEVICE([UserDefault user].child_id)));
    [manager POST:URL_SERVER_API(API_ADD_NEW_HISTORY_DEVICE([UserDefault user].child_id)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideNetworkActivityIndicator];
        NSLog(@"++++ response Add New Location ++++: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            //Continue to send local history to server
            NSMutableArray *arrDataLocation = [Common readFileLocalTrackingLocation];
            if ([arrDataLocation count] > 0) {
                NSMutableArray *arrLocations = [[NSMutableArray alloc] init];
                for (int i = 0; i < [arrDataLocation count]; i++) {
                    NSDictionary *objDic = [arrDataLocation objectAtIndex:i];
                    CLLocation *locObj = [[CLLocation alloc] initWithLatitude:[objDic[@"lat"] doubleValue] longitude:[objDic[@"long"] doubleValue]];
                    [arrLocations addObject:locObj];
                }
                [self callWSAddOldLocation:arrLocations];
            }
        } else {
            //Save to local
            [self savePointToLocal:newPoint];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideNetworkActivityIndicator];
        //Save to local
        [self savePointToLocal:newPoint];
    }];

}

- (void) callWSAddOldLocation:(NSMutableArray *) arrPoints {
    NSLog(@"------  callWSAddOldLocation");
    NSString *strLats = @"";
    NSString *strLongs = @"";
    strLats = [Common returnStringArrayLat:arrPoints];
    strLongs = [Common returnStringArrayLong:arrPoints];
    
    //status_request: add time created at for each point. if (status_created = 0) created time += adjust_time
    
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            @"latitude":strLats,
                                            @"longitude":strLongs,
                                            @"status_request":@"0",
                                            @"adjust_time":@(timeTrackingSaveLocations),
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_ADD_OLD_HISTORY_DEVICE([UserDefault user].child_id)));
    [manager POST:URL_SERVER_API(API_ADD_OLD_HISTORY_DEVICE([UserDefault user].child_id)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideNetworkActivityIndicator];
        NSLog(@"++++ response OLD LOCATION ++++++: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            //Remove all data in local
            [Common removeFileLocalTrackingLocation];
        } else {
            //Return error
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideNetworkActivityIndicator];
    }];
}

- (void) savePointToLocal:(CLLocationCoordinate2D) localPoint {
    NSLog(@"------  savePointToLocal");
    //Write location to file
    NSDictionary *dicObj = [NSDictionary dictionaryWithObjects:@[@(localPoint.latitude),@(localPoint.longitude),@"background"] forKeys:@[@"lat",@"long",@"type"]];
    [Common writeObjToFileTrackingLocation:dicObj];
}

- (void) endTimerTrackingSaveLocations {
    NSLog(@"------  endTimerTrackingSaveLocations");
    [self callWSAddNewLocation:lastLocationAppDelegate];
}

- (void) endTimerTrackingSaveLocationsMoving {
    NSLog(@"------  endTimerTrackingSaveLocationsMoving");
    //Check tracking point is out side radius tracking moving
    NSLog(@"Distance: %f", [Common calDistanceTwoCoordinate:centerTrackingMoving andSecondPoint:lastLocationAppDelegate]);
    
    if ([Common calDistanceTwoCoordinate:centerTrackingMoving andSecondPoint:lastLocationAppDelegate] >= radiusTrackingSaveLocationMoving) {
        // IS out side
        //Call add new location to server
        [self callWSAddNewLocation:lastLocationAppDelegate];
        
        //Restart process
        [self restartTrackingSaveLocationsMoving];
    } else {
        NSLog(@"Distance little: %f", [Common calDistanceTwoCoordinate:middleTrackingMoving andSecondPoint:lastLocationAppDelegate]);
        if ([Common calDistanceTwoCoordinate:middleTrackingMoving andSecondPoint:lastLocationAppDelegate] > distanceCheckingFilter) {
            //Save to local
            [self savePointToLocal:lastLocationAppDelegate];
        }
    }
    middleTrackingMoving = lastLocationAppDelegate;
}

- (void) endTimerRestartTrackingSaveLocationsMoving {
    NSLog(@"------  endTimerRestartTrackingSaveLocationsMoving");
    [self.timerRestartTrackingSaveLocationsMoving invalidate];
    self.timerRestartTrackingSaveLocationsMoving = nil;
    [self beginCheckingSafeArea];
}

@end
