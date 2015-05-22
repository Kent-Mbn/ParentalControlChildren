//
//  HomeVC.h
//  ParentalControlChildren
//
//  Created by CHAU HUYNH on 5/8/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"
#import <MapKit/MapKit.h>
#import "Common.h"
#import <CoreLocation/CoreLocation.h>
#import "UserDefault.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"

typedef NS_ENUM(NSInteger, NSTypeMap) {
    NSTypeMapStandard = 0,
    NSTypeMapSatellite = 1,
};

@interface HomeVC : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
    NSTypeMap *typeMap;
    CLLocationCoordinate2D lastLocation;
    
    NSTypeOfSafeArea typeSafeArea;
    
    int radiusCircle;
    CLLocationCoordinate2D centerPointCircle;
}

@property (weak, nonatomic) IBOutlet UIButton *btTypeMap;
@property (weak, nonatomic) IBOutlet UIView *viewBottomBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) NSMutableArray *arrayForPolygon;
@property (nonatomic, strong) MKPolygon *polygon;
@property (nonatomic, strong) MKPolygonView *polygonView;

@property (nonatomic) NSTimer *timerUpdateSafeArea;

- (IBAction)actionEmergency:(id)sender;
- (IBAction)actionSettings:(id)sender;
- (IBAction)actionChangeMapType:(id)sender;

@end
