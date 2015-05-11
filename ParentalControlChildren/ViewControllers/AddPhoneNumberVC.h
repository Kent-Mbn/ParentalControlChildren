//
//  AddPhoneNumberVC.h
//  ParentalControlChildren
//
//  Created by Huynh Phong Chau on 5/9/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "Common.h"
#import "Define.h"
#import "PersonContactObj.h"
#import "AddPhoneNumberCell.h"

@interface AddPhoneNumberVC : UIViewController<UITableViewDelegate, UITableViewDataSource> {

}
@property(nonatomic, strong) NSMutableArray *arrContacts;
@property(nonatomic, strong) NSArray *searchResults;

@property (weak, nonatomic) IBOutlet UITableView *tblView;
- (IBAction)actionBack:(id)sender;
- (IBAction)actionDone:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewTopBar;

@end
