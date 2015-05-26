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
    self.navigationController.navigationBarHidden = YES;
    typeMap = NSTypeMapStandard;
    [self changeStatusOfButtonMapType];
    _viewBottomBar.backgroundColor = masterColor;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(returnNewLocation:)
                                                 name:kNotificationGetNewLocation
                                               object:nil];
    typeSafeArea = radiusShape;
    _arrayForPolygon = [[NSMutableArray alloc] init];
    _arrayToZooming = [[NSMutableArray alloc] init];
    radiusCircle = 0;
}

- (void) viewWillAppear:(BOOL)animated {
    [self startTimerUpdateSafeArea];
}

- (void) viewDidAppear:(BOOL)animated {
    
}

- (void) viewDidDisappear:(BOOL)animated {
    [self stopTimerUpdateSafeArea];
}

#pragma mark - ACTION
- (IBAction)actionEmergency:(id)sender {
    AppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate callMessageVC];
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
}

-(void) changeStatusOfButtonMapType {
    if (typeMap == NSTypeMapStandard) {
        [_btTypeMap setBackgroundImage:[UIImage imageNamed:@"bt_map_satellite.png"] forState:UIControlStateNormal];
    } else {
        [_btTypeMap setBackgroundImage:[UIImage imageNamed:@"map_standard.png"] forState:UIControlStateNormal];
    }
}

-(void) addAndFocusPinViewToMap:(CLLocation *) locationPoint {
    //Remove all pin to map before add new pin
    [_mapView removeAnnotations:_mapView.annotations];
    
    CLLocationCoordinate2D point = locationPoint.coordinate;
    
    //Get Address
    /*
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:locationPoint completionHandler:^(NSArray *placemarks, NSError *error) {
        [Common hideLoadingViewGlobal];
        if (error) {
            return;
        }
        NSLog(@"Array place mark: %@", placemarks);
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        
     
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
     
        
        MKPointAnnotation *pointAnn = [[MKPointAnnotation alloc] init];
        pointAnn.coordinate = point;
        pointAnn.title = @"Name";
        pointAnn.subtitle = placemark.name;
        [_mapView addAnnotation:pointAnn];
        
     
        //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(point, 1000, 1000);
        //[_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
     
         
        [_mapView selectAnnotation:pointAnn animated:YES];
        
        //Update current location to server
        //[self callWSUpdateHistoryLocation:point andAddress:placemark.name];
    }];
*/
    
    
    MKPointAnnotation *pointAnn = [[MKPointAnnotation alloc] init];
    pointAnn.coordinate = point;
    //pointAnn.title = @"Name";
    //pointAnn.subtitle = placemark.name;
    [_mapView addAnnotation:pointAnn];
    [_mapView selectAnnotation:pointAnn animated:YES];
    
    //Zooming if has only tracking location, no safe area
    if (radiusCircle == 0 && [_arrayForPolygon count] == 0) {
        [_mapView setRegion:MKCoordinateRegionMakeWithDistance(point, 500, 500) animated:YES];
    }
}

-(void) addPinViewToMap:(CLLocationCoordinate2D) location {
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = location;
    [_mapView addAnnotation:point];
}

- (void) callWSGetSafeArea {
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSLog(@"request_param: %@", URL_SERVER_API(API_GET_SAFE_AREA([UserDefault user].child_id)));
    [manager POST:URL_SERVER_API(API_GET_SAFE_AREA([UserDefault user].child_id)) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                radiusCircle = 0;
                for (int i = 0; i < [arrSafeAreaData count]; i++) {
                    NSDictionary *objPoint = [arrSafeAreaData objectAtIndex:i];
                    CLLocation *locationPoint = [[CLLocation alloc] initWithLatitude:[objPoint[@"latitude"] doubleValue] longitude:[objPoint[@"longitude"] doubleValue]];
                    [_arrayForPolygon addObject:locationPoint];
                }
                [self drawPolygon];
            }
        } else {
            [self getSafeAreaOffline];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideNetworkActivityIndicator];
        NSLog(@"Error Safe Area At Home: %@", error.description);
        [self getSafeAreaOffline];
    }];
}

- (void) getSafeAreaOffline {
    //Get data from userdefault.
    NSString *strRadius;
    NSString *strLats;
    NSString *strLongs;
    
    strRadius = [NSString stringWithFormat:@"%@", [UserDefault user].radiusCircle];
    strLats = [NSString stringWithFormat:@"%@", [UserDefault user].lats];
    strLongs = [NSString stringWithFormat:@"%@", [UserDefault user].longs];
    
    //Check lat long length > 0, check radius of circle, if = 0 -> polygon else is circle.
    
    if ([Common isValidString:strLats] && [Common isValidString:strLongs]) {
        [_arrayForPolygon removeAllObjects];
        if (strRadius == nil || [strRadius isEqualToString:@"0"]) {
            //polygon
            radiusCircle = 0;
            NSArray *arrSafeAreaDataLats = [strLats componentsSeparatedByString:@";"];
            NSArray *arrSafeAreaDataLongs = [strLongs componentsSeparatedByString:@";"];
            typeSafeArea = polygonShape;
            NSMutableArray *arrLocations = [[NSMutableArray alloc] init];
            for (int i = 0; i < [arrSafeAreaDataLats count]; i++) {
                CLLocation *locationPoint = [[CLLocation alloc] initWithLatitude:[[arrSafeAreaDataLats objectAtIndex:i] doubleValue] longitude:[[arrSafeAreaDataLongs objectAtIndex:i] doubleValue]];
                [arrLocations addObject:locationPoint];
            }
            _arrayForPolygon = arrLocations;
            [self drawPolygon];
        } else {
            //circle
            typeSafeArea = radiusShape;
            centerPointCircle = [Common get2DCoordFromString:[NSString stringWithFormat:@"%@,%@", strLats, strLongs]];
            radiusCircle = [strRadius intValue];
            [self addCircle:radiusCircle andCircleCoordinate:centerPointCircle];
        }
    }

}

- (void) returnNewLocation :(NSNotification *) noti {
    AppDelegate *appDelegate = APP_DELEGATE;
    NSDictionary *theData = [noti userInfo];
    if (theData != nil) {
        NSLog(@"New location add Home: %@", theData);
        
        //Start system tracking location and safe area
        if (!appDelegate.isStartSystemTracking) {
            if ([[UserDefault user].isPaired isEqualToString:@"YES"]) {
                appDelegate.isStartSystemTracking = YES;
                //Start system checking safe area
                if (appDelegate.timerTrackingSafeArea == nil) {
                    [appDelegate beginCheckingSafeArea];
                    [appDelegate beginTrackingSaveLocations];
                }
            }
        }
        
        CLLocationCoordinate2D newLocation = [Common get2DCoordFromString:[NSString stringWithFormat:@"%@,%@", theData[@"lat"], theData[@"long"]]];
        
        //Checking distance from old location and new location
        if (CLLocationCoordinate2DIsValid(lastLocation)) {
            lastLocation = newLocation;
                
            //Update map again
            [_mapView removeAnnotations:_mapView.annotations];
            CLLocation *locationUpdate = [[CLLocation alloc] initWithLatitude:[theData[@"lat"] doubleValue] longitude:[theData[@"long"] doubleValue]];
            [self addAndFocusPinViewToMap:locationUpdate];
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
    
    [self zoomToFitMapAnnotations];
}

- (void)addCircle:(double)radius andCircleCoordinate:(CLLocationCoordinate2D) coordinate {
    //Remove all overlaya and annotations
    [self removeAllOverlay];
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:coordinate radius:radius];
    [_mapView addOverlay:circle];
    
    [self zoomToFitMapAnnotations];
}

-(void) zoomToFitMapAnnotations {
    [_arrayToZooming removeAllObjects];
    if (lastLocation.latitude != 0 && lastLocation.longitude != 0) {
        [_arrayToZooming addObject:[[CLLocation alloc] initWithLatitude:lastLocation.latitude longitude:lastLocation.longitude]];
    }
    
    if (radiusCircle > 0) {
        //Circle
        if (centerPointCircle.latitude != 0 && centerPointCircle.longitude != 0) {
            [_arrayToZooming addObject:[[CLLocation alloc] initWithLatitude:centerPointCircle.latitude longitude:centerPointCircle.longitude]];
        }
        
    } else {
        //Polygon
        if ([_arrayForPolygon count] > 0) {
            for (int i = 0; i < [_arrayForPolygon count]; i++) {
                CLLocation *locationT = [_arrayForPolygon objectAtIndex:i];
                [_arrayToZooming addObject:locationT];
            }
        }
    }
    
    if ([_arrayToZooming count] > 0) {
        MKMapPoint points[[_arrayToZooming count]];
        for (int i = 0; i < [_arrayToZooming count]; i++) {
            CLLocation *locationTemp;
            locationTemp = (CLLocation *)[_arrayToZooming objectAtIndex:i];
            points[i] = MKMapPointForCoordinate(locationTemp.coordinate);
        }
        
        MKPolygon *poly = [MKPolygon polygonWithPoints:points count:[_arrayToZooming count]];
        if (radiusCircle == 0) {
            //Polygon
            [_mapView setVisibleMapRect:[poly boundingMapRect] edgePadding:UIEdgeInsetsMake(100, 100, 100, 100) animated:YES];
        } else {
            //Circle
            if ([Common checkPointInsideCircle:radiusCircle andCenterPoint:centerPointCircle andCheckPoint:lastLocation]) {
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerPointCircle, radiusCircle + 1000, radiusCircle + 1000);
                [_mapView setRegion:region animated:YES];
            } else {
                [_mapView setVisibleMapRect:[poly boundingMapRect] edgePadding:UIEdgeInsetsMake(100, 100, 100, 100) animated:YES];
            }
        }
    }
}

-(void)removeAllOverlay {
    [_mapView removeOverlays:_mapView.overlays];
}

- (void) stopTimerUpdateSafeArea {
    if (_timerUpdateSafeArea) {
        [_timerUpdateSafeArea invalidate];
        _timerUpdateSafeArea = nil;
    }
}

- (void) startTimerUpdateSafeArea {
    [self stopTimerUpdateSafeArea];
    _timerUpdateSafeArea = [NSTimer scheduledTimerWithTimeInterval:timeUpdateSafeAreaHome target:self selector:@selector(endTimerUpdateSafeArea) userInfo:nil repeats:YES];
}

- (void) endTimerUpdateSafeArea {
    [self callWSGetSafeArea];
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
