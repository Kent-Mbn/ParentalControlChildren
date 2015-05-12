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

+ (void) showAlertView:(NSString *)title message:(NSString *)message delegate:(UIViewController *)delegate cancelButtonTitle:(NSString *)cancelButtonTitle arrayTitleOtherButtons:(NSArray *)arrayTitleOtherButtons tag:(int)tag {
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


@end
