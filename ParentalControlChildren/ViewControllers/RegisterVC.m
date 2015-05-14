//
//  RegisterVC.m
//  ParentalControlChildren
//
//  Created by CHAU HUYNH on 5/8/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "RegisterVC.h"

@implementation RegisterVC

- (void) viewDidLoad {
    self.view.backgroundColor = masterColor;
    [Common roundView:_viewBGRegister andRadius:10.0f];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - FUNCTION
- (BOOL) validInPut {
    if (_tfPhoneNumber.text.length == 0) {
        [Common showAlertView:APP_NAME message:MSS_REGISTER_INVALID_PHONE_NUMBER delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
        return NO;
    }
    
    if (_tfFullName.text.length == 0) {
        [Common showAlertView:APP_NAME message:MSS_REGISTER_INVALID_FULL_NAME delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
        return NO;
    }
    
    if (_tfEmail.text.length == 0 || ![Common isValidEmail:_tfEmail.text]) {
        [Common showAlertView:APP_NAME message:MSS_REGISTER_INVALID_EMAIL delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
        return NO;
    }

    
    return YES;
}

- (void) callWSRegister {
    [Common showLoadingViewGlobal:nil];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            @"email":_tfEmail.text,
                                            @"fullname":_tfFullName.text,
                                            @"phone_number":_tfPhoneNumber.text,
                                            @"register_id":[Common getDeviceToken],
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_DEVICE_REGISTER));
    [manager POST:URL_SERVER_API(API_DEVICE_REGISTER) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideLoadingViewGlobal];
        NSLog(@"response LOGIN: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            //Save infor to userdefault
            NSArray *arrRespone = (NSArray *) responseObject;
            [[UserDefault user] setChild_id:arrRespone[0][@"device_id"]];
            [[UserDefault user] setEmail:_tfEmail.text];
            [[UserDefault user] setFull_name:_tfFullName.text];
            [[UserDefault user] setToken_device:[Common getDeviceToken]];
            
            [self performSegueWithIdentifier:@"sugueToHomeScreen" sender:nil];
        } else {
            [Common showAlertView:APP_NAME message:MSS_REGISTER_FAILDED delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideLoadingViewGlobal];
        [Common showAlertView:APP_NAME message:MSS_REGISTER_FAILDED delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
    }];
}


#pragma mark - TEXT FIELD DELEGATE
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == _tfPhoneNumber) {
        [_scrView setContentOffset:CGPointMake(0, 30) animated:YES];
    }
    
    if (textField == _tfFullName) {
        [_scrView setContentOffset:CGPointMake(0, 60) animated:YES];
    }
    
    if (textField == _tfEmail) {
        [_scrView setContentOffset:CGPointMake(0, 80) animated:YES];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == _tfPhoneNumber) {
        [_tfFullName becomeFirstResponder];
    }
    if(textField == _tfFullName) {
        [_tfEmail becomeFirstResponder];
    }
    if (textField == _tfEmail) {
        [self actionRegister:nil];
    }
    return YES;
}

#pragma mark - ACTION

- (IBAction)actionRegister:(id)sender {
    /*
    if ([self validInPut]) {
        [self actionHideKeyboard:nil];
        [self callWSRegister];
    }*/
    [self performSegueWithIdentifier:@"sugueToHomeScreen" sender:nil];
}

- (IBAction)actionHideKeyboard:(id)sender {
    [_tfEmail resignFirstResponder];
    [_tfFullName resignFirstResponder];
    [_tfPhoneNumber resignFirstResponder];
    [_scrView setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end
