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

-(void) addAndFocusPinViewToMapAndUpdateToServer:(CLLocation *) locationPoint {
    //Remove all pin to map before add new pin
    [_mapView removeAnnotations:_mapView.annotations];
    
    CLLocationCoordinate2D point = locationPoint.coordinate;
    
    //Get Address
    [Common showLoadingViewGlobal:nil];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:locationPoint completionHandler:^(NSArray *placemarks, NSError *error) {
        [Common hideLoadingViewGlobal];
        if (error) {
            return;
        }
        NSLog(@"Array place mark: %@", placemarks);
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        
        /*
         NSLog(@"name: %@", placemark.name);
         NSLog(@"thoroughfare: %@", placemark.thoroughfare);
         NSLog(@"subThoroughfare: %@", placemark.subThoroughfare);
         NSLog(@"locality: %@", placemark.locality);
         NSLog(@"subLocality: %@", placemark.subLocality);
         NSLog(@"administrativeArea: %@", placemark.administrativeArea);
         NSLog(@"subAdministrativeArea: %@", placemark.subAdministrativeArea);
         NSLog(@"postalCode: %@", placemark.postalCode);
         NSLog(@"ISOcountryCode: %@", placemark.ISOcountryCode);
         NSLog(@"country: %@", placemark.country);
         NSLog(@"inlandWater: %@", placemark.inlandWater);
         NSLog(@"ocean: %@", placemark.ocean);
         NSLog(@"areasOfInterest: %@", placemark.areasOfInterest);
         */
        
        MKPointAnnotation *pointAnn = [[MKPointAnnotation alloc] init];
        pointAnn.coordinate = point;
        pointAnn.title = @"Chau";
        pointAnn.subtitle = placemark.name;
        [_mapView addAnnotation:pointAnn];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(point, 1000, 1000);
        [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
        [_mapView selectAnnotation:pointAnn animated:YES];
        
        //Update current location to server
        [self callWSUpdateHistoryLocation:point andAddress:placemark.name];
    }];
}

- (void) callWSUpdateHistoryLocation:(CLLocationCoordinate2D)curLocation andAddress:(NSString *)strAddr {
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            @"latitude":@(curLocation.latitude),
                                            @"longitude":@(curLocation.longitude),
                                            @"address":strAddr,
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_ADD_NEW_HISTORY_DEVICE([UserDefault user].child_id)));
    [manager POST:URL_SERVER_API(API_ADD_NEW_HISTORY_DEVICE(@"7")) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideNetworkActivityIndicator];
        NSLog(@"response: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            //Success
        } else {
            //Return error
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideNetworkActivityIndicator];
    }];
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

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    if (dateOfLastLocation == nil) {
        dateOfLastLocation = location.timestamp;
        NSLog(@"Location: %f", location.coordinate.latitude);
        [self addAndFocusPinViewToMapAndUpdateToServer:location];
    } else {
        NSDate *locationDate = location.timestamp;
        NSTimeInterval interval = [locationDate timeIntervalSinceDate:dateOfLastLocation];
        if (abs(interval) > (5 * 60)) {
            NSLog(@"Location: %f", location.coordinate.latitude);
            [self addAndFocusPinViewToMapAndUpdateToServer:location];
        }
    }
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
        customPinView.animatesDrop = NO;
        customPinView.canShowCallout = YES;
        return customPinView;
        
    } else {
        pinView.centerOffset = CGPointMake(0, -35 / 2);
        pinView.annotation = annotation;
    }
    
    return pinView;
}


@end
