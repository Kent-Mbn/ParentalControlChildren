//
//  EditSMSMessageVC.m
//  ParentalControlChildren
//
//  Created by Huynh Phong Chau on 5/9/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "EditSMSMessageVC.h"

@interface EditSMSMessageVC ()

@end

@implementation EditSMSMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _viewTopBar.backgroundColor = masterColor;
    NSString *strInitContent = [UserDefault user].content_mss;
    if (strInitContent.length > 0) {
        _textView.text = [UserDefault user].content_mss;
    } else {
        _textView.text = CONTENT_MSS_NOTIFY_DEFAULT;
    }
    [_textView becomeFirstResponder];
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionDone:(id)sender {
    if (_textView.text.length > 0) {
        [[UserDefault user] setContent_mss:_textView.text];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [Common showAlertView:APP_NAME message:MSS_CONTENT_IS_NULL delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
    }
}
@end
