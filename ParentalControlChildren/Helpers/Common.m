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


@end
