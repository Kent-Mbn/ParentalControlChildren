//
//  Common.m
//  ParentalControlChildren
//
//  Created by CHAU HUYNH on 5/8/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "Common.h"

@implementation Common

+(void)roundView:(UIView *)uView andRadius:(float) radius {
    uView.layer.cornerRadius = radius;
}

+ (void) showAlertView:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle arrayTitleOtherButtons:(NSArray *)arrayTitleOtherButtons tag:(int)tag {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:delegate
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    alert.tag = tag;
    
    if([arrayTitleOtherButtons count] > 0) {
        for (int i = 0; i < [arrayTitleOtherButtons count]; i++) {
            [alert addButtonWithTitle:arrayTitleOtherButtons[i]];
        }
    }
    
    [alert show];
}

+ (CLLocationCoordinate2D) get2DCoordFromString:(NSString*)coordString
{
    CLLocationCoordinate2D location;
    NSArray *coordArray = [coordString componentsSeparatedByString: @","];
    location.latitude = ((NSNumber *)coordArray[0]).doubleValue;
    location.longitude = ((NSNumber *)coordArray[1]).doubleValue;
    
    return location;
}

+ (void) circleImageView:(UIView *) imgV {
    imgV.layer.cornerRadius = imgV.frame.size.width / 2;
    imgV.clipsToBounds = YES;
    imgV.contentMode = UIViewContentModeScaleAspectFill;
}

+ (void) updateDeviceToken:(NSString *) newDeviceToken {
    [[NSUserDefaults standardUserDefaults] setObject:newDeviceToken forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) getDeviceToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"];
}

+ (BOOL) isValidEmail:(NSString *)checkString
{
    checkString = [checkString lowercaseString];
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:checkString];
}

+ (void) showLoadingViewGlobal:(NSString *) titleaLoading {
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    if (titleaLoading != nil) {
        [SVProgressHUD showWithStatus:titleaLoading maskType:SVProgressHUDMaskTypeGradient];
    } else {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    }
}

+ (void) showNetworkActivityIndicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

+ (void) hideNetworkActivityIndicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

+ (void) hideLoadingViewGlobal {
    [SVProgressHUD dismiss];
}

+ (AFHTTPRequestOperationManager *)AFHTTPRequestOperationManagerReturn {
    NSLog(@".......Call WS........");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //[manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager.requestSerializer setTimeoutInterval:30];
    return manager;
}

+ (BOOL) validateRespone:(id) respone {
    NSArray *arrRespone = (NSArray *)respone;
    NSDictionary *dicRespone = (NSDictionary *)[arrRespone objectAtIndex:0];
    if (dicRespone) {
        if ([dicRespone[@"resultcode"] intValue] == CODE_RESPONE_SUCCESS) {
            return YES;
        }
    }
    return NO;
}

+ (NSString *) pathOfFileLocalTrackingLocation {
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [filePaths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:NAME_LOCAL_FILE_SAVE_LOCATION];
    return path;
}

+ (void) writeArrayToFileLocalTrackingLocation:(NSMutableArray *) arrToWrite {
    [arrToWrite writeToFile:[self pathOfFileLocalTrackingLocation] atomically:YES];
}

+ (NSMutableArray *) readFileLocalTrackingLocation {
    NSMutableArray *arrReturn = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self pathOfFileLocalTrackingLocation]]) {
        arrReturn = [[NSMutableArray arrayWithContentsOfFile:[self pathOfFileLocalTrackingLocation]] mutableCopy];
    }
    return arrReturn;
}

+ (void) writeObjToFileTrackingLocation:(NSDictionary *) dicObj {
    //Get data
    NSMutableArray *arrInit = [self readFileLocalTrackingLocation];
    if (arrInit != nil) {
        [arrInit addObject:dicObj];
    } else {
        arrInit = [[NSMutableArray alloc] init];
        [arrInit addObject:dicObj];
    }
    
    //Write to file
    [self writeArrayToFileLocalTrackingLocation:arrInit];
}

+ (void) removeFileLocalTrackingLocation {
    NSString *filePath = [self pathOfFileLocalTrackingLocation];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
}

+ (float) calDistanceTwoCoordinate:(CLLocationCoordinate2D)firstPoint andSecondPoint:(CLLocationCoordinate2D)secondPoint {
    CLLocation *userloc = [[CLLocation alloc]initWithLatitude:firstPoint.latitude longitude:firstPoint.longitude];
    CLLocation *dest = [[CLLocation alloc]initWithLatitude:secondPoint.latitude longitude:secondPoint.longitude];
    CLLocationDistance dist = [userloc distanceFromLocation:dest];
    return (float)dist;
}

+ (NSString *) returnStringArrayLat:(NSMutableArray *) arrData {
    NSString *strReturn = @"";
    if ([arrData count] > 0) {
        for (int i = 0; i < [arrData count]; i++) {
            CLLocation *objLocation = [arrData objectAtIndex:i];
            if (i == [arrData count] - 1) {
                strReturn = [NSString stringWithFormat:@"%@%@", strReturn, [NSString stringWithFormat:@"%@", @(objLocation.coordinate.latitude)]];
            } else {
                strReturn = [NSString stringWithFormat:@"%@%@", strReturn, [NSString stringWithFormat:@"%@;", @(objLocation.coordinate.latitude)]];
            }
        }
    }
    return strReturn;
}

+ (NSString *) returnStringArrayLong:(NSMutableArray *) arrData {
    NSString *strReturn = @"";
    if ([arrData count] > 0) {
        for (int i = 0; i < [arrData count]; i++) {
            CLLocation *objLocation = [arrData objectAtIndex:i];
            if (i == [arrData count] - 1) {
                strReturn = [NSString stringWithFormat:@"%@%@", strReturn, [NSString stringWithFormat:@"%@", @(objLocation.coordinate.longitude)]];
            } else {
                strReturn = [NSString stringWithFormat:@"%@%@", strReturn, [NSString stringWithFormat:@"%@;", @(objLocation.coordinate.longitude)]];
            }
        }
    }
    return strReturn;
}

+ (NSMutableArray *) returnArrayLocations:(NSString *) strLats andLongs:(NSString *)strLongs {
    NSArray *arrLats = [strLats componentsSeparatedByString:@";"];
    NSArray *arrLongs = [strLongs componentsSeparatedByString:@";"];
    if ([arrLats count] > 0 && [arrLongs count] > 0 && [arrLats count] == [arrLongs count]) {
        NSMutableArray *arrResult = [[NSMutableArray alloc] init];
        for (int i = 0; i < [arrLats count]; i++) {
            CLLocation *locationObj = [[CLLocation alloc] initWithLatitude:[[arrLats objectAtIndex:i] doubleValue] longitude:[[arrLongs objectAtIndex:i] doubleValue]];
            [arrResult addObject:locationObj];
        }
        return arrResult;
    }
    return nil;
}

+ (void) addContactToArrayUserDefault:(NSArray *) arrIds andArrPhoneNumbers:(NSArray *)arrPhones {
    
    //Read string Ids and PhoneNumbers
    NSString *strIds;
    NSString *strPhoneNumbers;
    strIds = [UserDefault user].arrContactIds;
    strPhoneNumbers = [UserDefault user].arrPhoneNumbers;
    
    //Convert userdefault to NSMutableArray
    NSMutableArray *arrUsIds = [[NSMutableArray alloc] initWithArray:[strIds componentsSeparatedByString:@"*"]];
    NSMutableArray *arrUsPhones = [[NSMutableArray alloc] initWithArray:[strPhoneNumbers componentsSeparatedByString:@"*"]];
    
    //Convert prameter to NSMutableArray
    NSMutableArray *arrPrIds = [NSMutableArray arrayWithArray:arrIds];
    NSMutableArray *arrPrPhones = [NSMutableArray arrayWithArray:arrPhones];
    
    for (int i = 0; i < [arrPrIds count]; i++) {
        if ([arrUsIds count] > 0) {
            BOOL isAdd = YES;
            for (int l = 0; l < [arrUsIds count]; l++) {
                if ([[arrUsIds objectAtIndex:l] isEqualToString:[arrPrIds objectAtIndex:i]]) {
                    isAdd = NO;
                }
            }
            if (isAdd) {
                [arrUsIds addObject:[arrPrIds objectAtIndex:i]];
                [arrUsPhones addObject:[arrPrPhones objectAtIndex:i]];
            }
        } else {
            [arrUsIds addObject:[arrPrIds objectAtIndex:i]];
            [arrUsPhones addObject:[arrPrPhones objectAtIndex:i]];
        }
    }
    
    //Save to user default again
    [[UserDefault user] setArrContactIds:[arrUsIds componentsJoinedByString:@"*"]];
    [[UserDefault user] setArrPhoneNumbers:[arrUsPhones componentsJoinedByString:@"*"]];
}

+ (void) removeContactToArrayUserDefault:(NSArray *) arrIds andArrPhoneNumbers:(NSArray *)arrPhones {
    //Read string Ids and PhoneNumbers
    NSString *strIds;
    NSString *strPhoneNumbers;
    strIds = [UserDefault user].arrContactIds;
    strPhoneNumbers = [UserDefault user].arrPhoneNumbers;
    
    //Format to nsmutable array
    if (strIds.length > 0 && strPhoneNumbers.length > 0) {
        NSMutableArray *arrMuIds = [[NSMutableArray alloc] initWithArray:[strIds componentsSeparatedByString:@"*"]];
        NSMutableArray *arrMuPhones = [[NSMutableArray alloc] initWithArray:[strPhoneNumbers componentsSeparatedByString:@"*"]];
        for (int i = 0; i < [arrIds count]; i++) {
            for (int l = 0; l < [arrMuIds count]; l++) {
                if ([[arrIds objectAtIndex:i] isEqualToString:[arrMuIds objectAtIndex:l]]) {
                    //Remove Id and Phone Number out of arrMuIds and arrMuPhones
                    [arrMuIds removeObjectAtIndex:l];
                    [arrMuPhones removeObjectAtIndex:l];
                }
            }
        }
        
        //Convert array to string again and save to userdefault
        [[UserDefault user] setArrContactIds:[arrMuIds componentsJoinedByString:@"*"]];
        [[UserDefault user] setArrPhoneNumbers:[arrMuPhones componentsJoinedByString:@"*"]];
    }
}

+ (BOOL) isValidString:(NSString *) strCheck {
    if (strCheck.length > 0 && ![strCheck isEqual:[NSNull null]] && ![strCheck isEqualToString:@"(null)"]) {
        return YES;
    }
    return NO;
}

#pragma mark - Algorthim Checking Point In Polygon or In Circle

/*
 * a^2 = b^2 + c^2 - 2*b*ccosA -> cosA -> A (angle)
 */
+ (BOOL) checkPointInsidePolygon:(NSMutableArray *) arrPonits andCheckPoint:(CLLocationCoordinate2D) checkPoint {
    //? Lam sao de kiem tra 2 diem la canh cua mot da giac ???
    float totalAngle = 0;
    for (int i = 0; i < [arrPonits count]; i++) {
        
        int lastIndex = i + 1;
        if (i == ([arrPonits count] - 1)) {
            lastIndex = 0;
        }
        
        CLLocation *firstPointT = [arrPonits objectAtIndex:i];
        CLLocation *secondPointT = [arrPonits objectAtIndex:lastIndex];
        totalAngle += [self angleOfThreePoints:checkPoint andSecondPoint:firstPointT.coordinate         andThirdPoint:secondPointT.coordinate];
    }
    NSLog(@"Angle la: %f", totalAngle);
    
    if (((2 * M_PI) - totalAngle) < 0.001) {
        return YES;
    }
    return NO;
}
+ (float) angleOfThreePoints:(CLLocationCoordinate2D)anglePoint andSecondPoint:(CLLocationCoordinate2D) secondPoint andThirdPoint:(CLLocationCoordinate2D)thirdPoint {
    
    //A = anglePoint B = secondPoint C = thirdPoint
    //a = BC b = AC c = AB
    //cosA = (b2 + c2 - a2) / (2.b.c)
    
    double a = [self calDistanceTwoCoordinate:secondPoint andSecondPoint:thirdPoint];
    double b = [self calDistanceTwoCoordinate:anglePoint andSecondPoint:thirdPoint];
    double c = [self calDistanceTwoCoordinate:anglePoint andSecondPoint:secondPoint];
    
    return acos((pow(b, 2) + pow(c, 2) - pow(a, 2)) / (2 * b * c));
}
+ (BOOL) checkPointInsideCircle:(float)radiusCircle andCenterPoint:(CLLocationCoordinate2D) centerPoint andCheckPoint:(CLLocationCoordinate2D) checkPoint {
    
    //Distance of checkpoint and centerPoint
    float distancePoints = [self calDistanceTwoCoordinate:centerPoint andSecondPoint:checkPoint];
    if (distancePoints - radiusCircle <= 0) {
        return YES;
    }
    return NO;
}

#pragma mark - Algorthim calculate area of polygon and circle
+ (double) areaOfTriangle:(CLLocationCoordinate2D)firstPoint andSecondPoint:(CLLocationCoordinate2D)secondPoint andThirdPoint:(CLLocationCoordinate2D)thirdPoint {
    double areaReturn = 0.0f;
    
    /* Herong: S=sqrt(p(p-a)(p-b)(p-c)) */
    double a = [self calDistanceTwoCoordinate:firstPoint andSecondPoint:secondPoint];
    double b = [self calDistanceTwoCoordinate:secondPoint andSecondPoint:thirdPoint];
    double c = [self calDistanceTwoCoordinate:firstPoint andSecondPoint:thirdPoint];
    
    // 1/2 perimeter
    double p = (a + b + c)/2;
    
    //Cal area
    areaReturn = sqrtf(p * (p - a) * (p - b) * (p - c));
    
    return areaReturn;
}

+ (double) areaOfPolygon:(NSMutableArray *) arrPoints {
    double areaReturn = 0.0f;
    
    // Area is summury all of area of triangle
    int count = [arrPoints count] - 2;
    if (count >= 1) {
        for (int i = 0; i < count; i++) {
            CLLocation *firstPoint = [arrPoints objectAtIndex:0];
            CLLocation *secondPoint = [arrPoints objectAtIndex:(i+1)];
            CLLocation *thirdPoint = [arrPoints objectAtIndex:(i+2)];
            
            areaReturn += [self areaOfTriangle:firstPoint.coordinate andSecondPoint:secondPoint.coordinate andThirdPoint:thirdPoint.coordinate];
        }
    }
    
    return areaReturn;
}

@end
