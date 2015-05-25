//
//  SettingsVC.m
//  ParentalControlChildren
//
//  Created by Huynh Phong Chau on 5/9/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "SettingsVC.h"

@interface SettingsVC ()

@end

@implementation SettingsVC

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

#pragma mark - TABLEVIEW DELEGATE
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SettingsCellId";
    SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if(IS_OS_8_OR_LATER) {
        cell.layoutMargins = UIEdgeInsetsMake(0, 1000, 0, 0);
        cell.preservesSuperviewLayoutMargins = NO;
    }
    tableView.separatorColor = [UIColor blackColor];
    if (indexPath.row == 0) {
        cell.imvIconLeft.image = [UIImage imageNamed:@"ic_phone_number.png"];
        cell.lblTitle.text = @"Number Phone";
    } else {
        cell.imvIconLeft.image = [UIImage imageNamed:@"ic_set_area.png"];
        cell.lblTitle.text = @"SMS Message";
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"sugueToAddContact" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"segueToEditSMS" sender:nil];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews
{
    if ([_tblView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tblView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_tblView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tblView setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - ACTION
- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
