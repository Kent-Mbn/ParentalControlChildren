//
//  AppDelegate.h
//  ParentalControlChildren
//
//  Created by CHAU HUYNH on 5/6/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Common.h"
#import "Define.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "UserDefault.h"
#import "APIService.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationTracker.h"
#import <MessageUI/MessageUI.h>

typedef NS_ENUM(NSInteger, NSTypeOfSafeArea) {
    radiusShape = 0,
    polygonShape = 1,
};

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate> {
    NSString *strPusherId;
    NSString *strChildId;
    
    CLLocationCoordinate2D lastLocationAppDelegate;
    
    NSTypeOfSafeArea typeSafeArea;
    
    //Circle Safe Area
    int radiusCircle;
    CLLocationCoordinate2D centerPointCircle;
    
    //Tracking save location
    CLLocationCoordinate2D centerTrackingMoving;
    CLLocationCoordinate2D middleTrackingMoving;

}

@property (strong, nonatomic) UIWindow *window;

//Location
@property LocationTracker * locationTracker;
@property (strong,nonatomic) LocationShareModel * shareModel;

//Core data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


//Polygon safearea
@property (nonatomic, strong) NSMutableArray *arrayForPolygon;

//Timer checking safearea
@property (nonatomic) NSTimer *timerTrackingSafeArea;

//Timer tracking save locations
@property (nonatomic) NSTimer *timerTrackingSaveLocations;
@property (nonatomic) NSTimer *timerTrackingSaveLocationsMoving;
@property (nonatomic) NSTimer *timerRestartTrackingSaveLocationsMoving;

//BOOL isStart system tracking location moving and tracking safe are.
@property (nonatomic) BOOL isStartSystemTracking;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//Checking SafeArea
- (void) beginCheckingSafeArea;

//Tracking save locations
- (void) beginTrackingSaveLocations;

//Call message controller
- (void) callMessageVC;

//Redirect
- (void) setGotoHomeChild:(dispatch_block_t)block;
- (void) setGotoRegister:(dispatch_block_t)block;

@end

