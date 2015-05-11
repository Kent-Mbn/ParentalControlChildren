//
//  PhoneNumberListVC.h
//  ParentalControlChildren
//
//  Created by Huynh Phong Chau on 5/9/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneNumberListCell.h"
#import "Define.h"
#import "Common.h"

@interface PhoneNumberListVC : UIViewController<UITableViewDelegate, UITableViewDataSource>
- (IBAction)actionBack:(id)sender;
- (IBAction)actionAddNumberPhone:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIView *viewTopBar;

@end
