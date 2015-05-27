//
//  EditSMSMessageVC.h
//  ParentalControlChildren
//
//  Created by Huynh Phong Chau on 5/9/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"
#import "UserDefault.h"
#import "Common.h"

@interface EditSMSMessageVC : UIViewController<UITextViewDelegate>
- (IBAction)actionBack:(id)sender;
- (IBAction)actionDone:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewTopBar;
@property (weak, nonatomic) IBOutlet UITextView *textView;


@end
