//
//  EditPhoneVC.m
//  ParentalControlChildren
//
//  Created by Huynh Phong Chau on 5/10/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "EditPhoneVC.h"

@interface EditPhoneVC ()

@end

@implementation EditPhoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _viewTopBar.backgroundColor = masterColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)actionDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
