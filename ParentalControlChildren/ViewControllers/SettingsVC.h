//
//  SettingsVC.h
//  ParentalControlChildren
//
//  Created by Huynh Phong Chau on 5/9/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsCell.h"
#import "Define.h"
#import "Common.h"

@interface SettingsVC : UIViewController<UITableViewDataSource, UITableViewDelegate>
- (IBAction)actionBack:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIView *viewTopBar;

@end
