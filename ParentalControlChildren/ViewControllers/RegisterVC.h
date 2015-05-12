//
//  RegisterVC.h
//  ParentalControlChildren
//
//  Created by CHAU HUYNH on 5/8/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "Define.h"

@interface RegisterVC : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewBGRegister;
@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfFullName;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UIScrollView *scrView;
- (IBAction)actionRegister:(id)sender;
- (IBAction)actionHideKeyboard:(id)sender;


@end
