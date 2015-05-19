//
//  HomeVC.m
//  ParentalControlChildren
//
//  Created by CHAU HUYNH on 5/8/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "HomeVC.h"

@implementation HomeVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationGetNewLocation object:nil];
}

- (void) viewDidLoad {
    typeMap = NSTypeMapStandard;
    [self changeStatusOfButtonMapType];
    _viewBottomBar.backgroundColor = masterColor;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(returnNewLocation:)
                                                 name:kNotificationGetNewLocation
                                               object:nil];
    typeSafeArea = radiusShape;
    _arrayForPolygon = [[NSMutableArray alloc] init];
    
    //Start system checking safe area

    AppDelegate *delegateShare = APP_DELEGATE;
    /*
    if (delegateShare.timerTrackingSafeArea) {
        [delegateShare.timerTrackingSafeArea invalidate];
        delegateShare.timerTrackingSafeArea = nil;
    }
    [delegateShare beginCheckingSafeArea];
     
    
    if (delegateShare.timerTrackingSaveLocations) {
        [delegateShare.timerTrackingSaveLocations invalidate];
        delegateShare.timerTrackingSaveLocations = nil;
    }
    [delegateShare beginTrackingSaveLocations];
     */
    
    [delegateShare beginTrackingSaveLocations];
}

- (void) viewWillAppear:(BOOL)animated {
    //[self callWSGetSafeArea];
}

#pragma mark - ACTION
- (IBAction)actionEmergency:(id)sender {
    //[Common showAlertView:APP_NAME message:MSS_NOTICE_SEND_SMS delegate:self cancelButtonTitle:@"Cancel" arrayTitleOtherButtons:@[@"Yes"] tag:0];
    if (typeSafeArea == radiusShape) {
        if ([Common checkPointInsideCircle:radiusCircle andCenterPoint:centerPointCircle andCheckPoint:lastLocation]) {
            NSLog(@"Nam trong!");
        } else {
            NSLog(@"Nam ngoai!");
        }
    } else {
        if ([Common checkPointInsidePolygon:_arrayForPolygon andCheckPoint:lastLocation]) {
            NSLog(@"Nam trong!");
        } else {
            NSLog(@"Nam ngoai!");
        }
    }
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

-(void) loadAllLocationsToMap {
    //Load all location and show to map
    NSMutableArray *arrDataLocation = [Common readFileLocalTrackingLocation];
    NSLog(@"Tracking location: %@", arrDataLocation);
    if ([arrDataLocation count] > 0) {
        for (int i = 0; i < [arrDataLocation count]; i++) {
            NSDictionary *objDic = [arrDataLocation objectAtIndex:i];
            CLLocationCoordinate2D pointLocation = [Common get2DCoordFromString:[NSString stringWithFormat:@"%@,%@", objDic[@"lat"], objDic[@"long"]]];
            [self addPinViewToMap:pointLocation];
        }
    }
    
    //[self zoomToFitMapAnnotations];
}

-(void) changeStatusOfButtonMapType {
    if (typeMap == NSTypeMapStandard) {
        [_btTypeMap setBackgroundImage:[UIImage imageNamed:@"map_standard.png"] forState:UIControlStateNormal];
    } else {
        [_btTypeMap setBackgroundImage:[UIImage imageNamed:@"bt_map_satellite.png"] forState:UIControlStateNormal];
    }
}

-(void) addAndFocusPinViewToMap:(CLLocation *) locationPoint {
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
         NSLog(@"inlandWater: %@", placemark.inlandWater);hjmygt5hjymko0lokhjnfrtg
         
         NSLog(@"ocean: %@", placemark.ocean);
         NSLog(@"areasOfInterest: %@", placemark.areasOfInterest);
         */
        
        MKPointAnnotation *pointAnn = [[MKPointAnnotation alloc] init];
        pointAnn.coordinate = point;
        pointAnn.title = @"Name";
        pointAnn.subtitle = placemark.name;
        [_mapView addAnnotation:pointAnn];
        
        /*
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(point, 1000, 1000);
        [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
         */
         
        [_mapView selectAnnotation:pointAnn animated:YES];
        
        //Update current location to server
        //[self callWSUpdateHistoryLocation:point andAddress:placemark.name];
    }];
}

-(void) addPinViewToMap:(CLLocationCoordinate2D) location {
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = location;
    [_mapView addAnnotation:point];
}

-(void) zoomToFitMapAnnotations {
    int count_point = [_mapView.annotations count];
    if (count_point == 0) {
        return;
    }
    
    MKMapPoint points[count_point];
    for (int i = 0; i < count_point; i++) {
        MKAnnotationView *oneAnno = [_mapView.annotations objectAtIndex:i];
        points[i] = MKMapPointForCoordinate([oneAnno.annotation coordinate]);
    }
    
    MKPolygon *poly = [MKPolygon polygonWithPoints:points count:count_point];
    [_mapView setVisibleMapRect:[poly boundingMapRect] edgePadding:UIEdgeInsetsMake(100, 100, 100, 100) animated:YES];
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

- (void) callWSGetSafeArea {
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_GET_SAFE_AREA(@"3")));
    [manager POST:URL_SERVER_API(API_GET_SAFE_AREA(@"3")) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideNetworkActivityIndicator];
        NSLog(@"response: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            
            NSArray *arrData = (NSArray *)responseObject;
            NSArray *arrSafeAreaData;
            if (arrData[0] != nil) {
                NSDictionary *dicData = arrData[0];
                arrSafeAreaData = dicData[@"safeArea"];
            } else {
                return;
            }
            [_arrayForPolygon removeAllObjects];
            if ([arrSafeAreaData count] == 1) {
                //Draw circle
                typeSafeArea = radiusShape;
                NSDictionary *objPoint = [arrSafeAreaData objectAtIndex:0];
                centerPointCircle = [Common get2DCoordFromString:[NSString stringWithFormat:@"%@,%@", objPoint[@"latitude"], objPoint[@"longitude"]]];
                radiusCircle = [objPoint[@"radius"] intValue];
                [self addCircle:radiusCircle andCircleCoordinate:centerPointCircle];
            } else {
                //Draw polygon
                typeSafeArea = polygonShape;
                for (int i = 0; i < [arrSafeAreaData count]; i++) {
                    NSDictionary *objPoint = [arrSafeAreaData objectAtIndex:i];
                    CLLocation *locationPoint = [[CLLocation alloc] initWithLatitude:[objPoint[@"latitude"] doubleValue] longitude:[objPoint[@"longitude"] doubleValue]];
                    [_arrayForPolygon addObject:locationPoint];
                }
                [self drawPolygon];
                [self zoomToFitMapAnnotations:_arrayForPolygon];
            }
        } else {
            //Return error
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideNetworkActivityIndicator];
        NSLog(@"Error: %@", error.description);
    }];
}

- (void) returnNewLocation :(NSNotification *) noti {
    NSDictionary *theData = [noti userInfo];
    if (theData != nil) {
        NSLog(@"New location add Home: %@", theData);
        CLLocationCoordinate2D newLocation = [Common get2DCoordFromString:[NSString stringWithFormat:@"%@,%@", theData[@"lat"], theData[@"long"]]];
        
        //Checking distance from old location and new location
        if (CLLocationCoordinate2DIsValid(lastLocation)) {
            if ([Common calDistanceTwoCoordinate:lastLocation andSecondPoint:newLocation] > distanceCheckingFilter) {
                lastLocation = newLocation;
                
                //Update map again
                [_mapView removeAnnotations:_mapView.annotations];
                CLLocation *locationUpdate = [[CLLocation alloc] initWithLatitude:[theData[@"lat"] doubleValue] longitude:[theData[@"long"] doubleValue]];
                [self addAndFocusPinViewToMap:locationUpdate];
            }
        }
    }
}

- (void) drawPolygon {
    // remove polygon if one exists
    [self removeAllOverlay];
    
    //Create an array of coordinates
    int countCoordinate = [_arrayForPolygon count];
    CLLocationCoordinate2D coordinates[countCoordinate];
    for (int i=0; i < countCoordinate; i++) {
        CLLocation *locationTemp;
        locationTemp = (CLLocation *)[_arrayForPolygon objectAtIndex:i];
        coordinates[i] = locationTemp.coordinate;
    }
    
    // Create a polygon with array of coordinates
    _polygon = [MKPolygon polygonWithCoordinates:coordinates count:countCoordinate];
    
    // Create a polygon view
    _polygonView = [[MKPolygonView alloc] initWithPolygon:_polygon];
    _polygonView.strokeColor = [UIColor redColor];
    _polygonView.lineWidth = 5;
    _polygonView.fillColor = [UIColor colorWithRed:12/255 green:24/255 blue:26/255 alpha:0.5];
    
    [_mapView addOverlay:_polygon];
    
}

- (void)addCircle:(double)radius andCircleCoordinate:(CLLocationCoordinate2D) coordinate {
    //Remove all overlaya and annotations
    [self removeAllOverlay];
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:coordinate radius:radius];
    [_mapView addOverlay:circle];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 3000, 3000);
    [_mapView setRegion:region animated:YES];
}

-(void) zoomToFitMapAnnotations:(NSMutableArray *)arrLocationPins {
    MKMapPoint points[[arrLocationPins count]];
    for (int i = 0; i < [arrLocationPins count]; i++) {
        CLLocation *locationTemp;
        locationTemp = (CLLocation *)[arrLocationPins objectAtIndex:i];
        points[i] = MKMapPointForCoordinate(locationTemp.coordinate);
    }
    
    MKPolygon *poly = [MKPolygon polygonWithPoints:points count:[arrLocationPins count]];
    [_mapView setVisibleMapRect:[poly boundingMapRect] edgePadding:UIEdgeInsetsMake(100, 100, 100, 100) animated:YES];
}

-(void)removeAllOverlay {
    [_mapView removeOverlays:_mapView.overlays];
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

- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    if (typeSafeArea == radiusShape) {
        MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:(MKCircle *) overlay];
        circleView.fillColor = [UIColor colorWithRed:12/255 green:24/255 blue:26/255 alpha:0.5];
        circleView.strokeColor = [UIColor redColor];
        return circleView;
    } else {
        return _polygonView;
    }
    return nil;
}


@end
