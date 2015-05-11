//
//  EditPhoneVC.h
//  ParentalControlChildren
//
//  Created by Huynh Phong Chau on 5/10/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"

@interface EditPhoneVC : UIViewController
- (IBAction)actionBack:(id)sender;
- (IBAction)actionDone:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIView *viewTopBar;


@end
