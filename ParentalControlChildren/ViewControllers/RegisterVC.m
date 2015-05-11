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

- (IBAction)actionRegister:(id)sender {
    [self performSegueWithIdentifier:@"sugueToHomeScreen" sender:nil];
}

@end
