//
//  HomeVC.m
//  ParentalControlChildren
//
//  Created by CHAU HUYNH on 5/8/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "HomeVC.h"

@implementation HomeVC

- (void) viewDidLoad {
    typeMap = NSTypeMapStandard;
    [self changeStatusOfButtonMapType];
    _viewBottomBar.backgroundColor = masterColor;
    //CLLocationCoordinate2D cooPoint1 = [Common get2DCoordFromString:@"16.046123,108.203659"];
    //[self addAndFocusPinViewToMap:cooPoint1];
    
    [self initGetCurrentLocation];
}

- (void) viewWillAppear:(BOOL)animated {
    
}


#pragma mark - ACTION
- (IBAction)actionEmergency:(id)sender {
    [Common showAlertView:APP_NAME message:MSS_NOTICE_SEND_SMS delegate:self cancelButtonTitle:@"Cancel" arrayTitleOtherButtons:@[@"Yes"] tag:0];
}

- (IBAction)actionSettings:(id)sender {
    
}

- (IBAction)actionChangeMapType:(id)sender {
    if (typeMap == NSTypeMapStandard) {
        typeMap = NSTypeMapSatellite;
        _mapView.mapType = MKMapTypeSatellite;
    } else {
        typeMap = NSTypeMapStandard;
        _mapView.mapType = MKMapTypeStandard;
    }
    [self changeStatusOfButtonMapType];
}

#pragma mark - FUNCTION
-(void) changeStatusOfButtonMapType {
    if (typeMap == NSTypeMapStandard) {
        [_btTypeMap setBackgroundImage:[UIImage imageNamed:@"map_standard.png"] forState:UIControlStateNormal];
    } else {
        [_btTypeMap setBackgroundImage:[UIImage imageNamed:@"bt_map_satellite.png"] forState:UIControlStateNormal];
    }
}

-(void) addAndFocusPinViewToMap:(CLLocationCoordinate2D) point {
    MKPointAnnotation *pointAnn = [[MKPointAnnotation alloc] init];
    pointAnn.coordinate = point;
    pointAnn.title = @"Huynh Phong Chau";
    pointAnn.subtitle = @"Da Nang";
    [_mapView addAnnotation:pointAnn];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(point, 1000, 1000);
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    [_mapView selectAnnotation:pointAnn animated:YES];
}

#pragma mark - LOCATION
- (void) initGetCurrentLocation {
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
}

- (BOOL) checkPermissonGetCurrentLocation {
    return YES;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    [self addAndFocusPinViewToMap:location.coordinate];
    [locationManager stopUpdatingLocation];
}

#pragma mark - MAP DELEGATE
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString* AnnotationIdentifier = @"Annotation";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if (!pinView) {
        MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 0, 35, 35)];
        imageV.image = [UIImage imageNamed:@"ic_gps.png"];
        if (annotation == mapView.userLocation){
            customPinView.image = [UIImage imageNamed:@""];
            [customPinView addSubview:imageV];
        }
        else{
            [customPinView addSubview:imageV];
            customPinView.image = [UIImage imageNamed:@""];
            //customPinView.pinColor = MKPinAnnotationColorRed;
        }
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        return customPinView;
        
    } else {
        pinView.centerOffset = CGPointMake(0, -35 / 2);
        pinView.annotation = annotation;
    }
    
    return pinView;
}


@end
