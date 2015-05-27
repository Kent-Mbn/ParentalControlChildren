//
//  AddPhoneNumberVC.m
//  ParentalControlChildren
//
//  Created by Huynh Phong Chau on 5/9/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "AddPhoneNumberVC.h"

@interface AddPhoneNumberVC ()

@end

@implementation AddPhoneNumberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _arrContacts = [[NSMutableArray alloc] init];
    _searchResults = [[NSMutableArray alloc] init];
    _arrIdRecords = [[NSArray alloc] init];
    _viewTopBar.backgroundColor = masterColor;
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor blackColor];
}

- (void) viewDidAppear:(BOOL)animated {
    [self getContactAndReload];
}

- (void) viewWillAppear:(BOOL)animated {
    [Common showLoadingViewGlobal:nil];
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

#pragma mark - FUNCTION

- (void) getContactAndReload {
    _arrIdRecords = [[UserDefault user].arrContactIds componentsSeparatedByString:@"*"];
    NSLog(@"String ids: %@", [UserDefault user].arrContactIds);
    NSLog(@"Array userdefault: %@", _arrIdRecords);
    [self getAllPeopleFromContactList];
}

- (void) filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"strName contains[c] %@", searchText];
    _searchResults.array = [_arrContacts filteredArrayUsingPredicate:resultPredicate];
}

- (void) addContactToUserDefault:(NSInteger)Id andPhoneNumber:(NSString *)strPhone {
    NSArray *arrIds = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld",(long)Id], nil];
    NSArray *arrPhones = [NSArray arrayWithObjects:strPhone, nil];
    [Common addContactToArrayUserDefault:arrIds andArrPhoneNumbers:arrPhones];
}

- (void) removeContactToUserDefault:(NSInteger)Id andPhoneNumber:(NSString *)strPhone {
    NSArray *arrIds = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld",(long)Id], nil];
    NSArray *arrPhones = [NSArray arrayWithObjects:strPhone, nil];
    [Common removeContactToArrayUserDefault:arrIds andArrPhoneNumbers:arrPhones];
}


#pragma mark - TABLE DELEGATE
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_searchResults count];
    } else {
        return [_arrContacts count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 86;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AddPhoneNumberCellId";
    AddPhoneNumberCell *cell = (AddPhoneNumberCell *)[_tblView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[AddPhoneNumberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [Common circleImageView:cell.imgAvatar];
    //cell.backgroundColor = [UIColor darkGrayColor];
    if (IS_OS_8_OR_LATER) {
        cell.layoutMargins = UIEdgeInsetsMake(0, 1000, 0, 0);
        cell.preservesSuperviewLayoutMargins = NO;
    }
    tableView.separatorColor = [UIColor blackColor];
    
    PersonContactObj *obj;
    //cell.accessoryView.backgroundColor = [UIColor darkGrayColor];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.accessoryView = cell.btCheckUncheckSearch;
        obj = [_searchResults objectAtIndex:indexPath.row];
        cell.btCheckUnCheck.hidden = YES;
        cell.btCheckUncheckSearch.hidden = NO;
    } else {
        cell.accessoryView = cell.btCheckUnCheck;
        obj = [_arrContacts objectAtIndex:indexPath.row];
        cell.btCheckUnCheck.hidden = NO;
        cell.btCheckUncheckSearch.hidden = YES;
    }
    
    cell.lblName.text = obj.strName;
    cell.lblPhoneNumber.text = obj.strMobile;
    if (obj.isSaved) {
        [cell.btCheckUnCheck setImage:[UIImage imageNamed:@"box-check.png"] forState:UIControlStateNormal];
        [cell.btCheckUncheckSearch setImage:[UIImage imageNamed:@"box-check.png"] forState:UIControlStateNormal];
    } else {
        [cell.btCheckUnCheck setImage:[UIImage imageNamed:@"box-uncheck.png"] forState:UIControlStateNormal];
        [cell.btCheckUncheckSearch setImage:[UIImage imageNamed:@"box-uncheck.png"] forState:UIControlStateNormal];
    }
    [cell.btCheckUnCheck addTarget:self action:@selector(actionCheckUncheck:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btCheckUncheckSearch addTarget:self action:@selector(actionCheckUncheckSearch:) forControlEvents:UIControlEventTouchUpInside];
    cell.btCheckUnCheck.tag = indexPath.row;
    cell.btCheckUncheckSearch.tag = indexPath.row;
    
    if (obj.dataImage != nil) {
        cell.imgAvatar.image = [UIImage imageWithData:obj.dataImage];
    } else {
        cell.imgAvatar.image = [UIImage imageNamed:@"ic_people.png"];
    }
    cell.backgroundColor = [UIColor darkGrayColor];
    return cell;
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

#pragma mark - ADDRESS BOOK
- (void) getAllPeopleFromContactList {
    
    //Check permission access from app to contact
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        // Denied
        [Common showAlertView:APP_NAME message:MSS_DENIED delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //Authorized
        [self getInforOfAllPeopleFromContactList];
    } else{
        //Not determined
        
        //Request user give permission for app access address book
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted){
                    [Common showAlertView:APP_NAME message:MSS_DENIED delegate:self cancelButtonTitle:@"OK" arrayTitleOtherButtons:nil tag:0];
                    return;
                }
                
                // User accepted
                [self getInforOfAllPeopleFromContactList];
            });
        });
    }
}

- (void) getInforOfAllPeopleFromContactList {
    if (_arrContacts) {
        [_arrContacts removeAllObjects];
    }
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
    NSArray *allPeoples = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    NSInteger Id;
    NSString *fullName;
    NSString *phoneNumber;
    BOOL isSave = NO;
    NSData *dataAvatar;
    
    for (id record in allPeoples) {
        isSave = NO;
        
        ABRecordRef people = (__bridge ABRecordRef)record;
        
        //Get id
        NSNumber *recordId = [NSNumber numberWithInteger:ABRecordGetRecordID(people)];
        Id = recordId.intValue;
        
        for (int i = 0; i < [_arrIdRecords count]; i++) {
            if (Id == [[_arrIdRecords objectAtIndex:i] intValue]) {
                isSave = YES;
            }
        }
        
        //Get name
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(people, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(people, kABPersonLastNameProperty);
        
        NSString *strFirstName = [NSString stringWithFormat:@"%@", firstName];
        NSString *strLastName = [NSString stringWithFormat:@"%@", lastName];
        
        if ([Common isValidString:strFirstName] && [Common isValidString:strLastName]) {
            fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        } else if ([Common isValidString:strFirstName]) {
            fullName = strFirstName;
        } else if ([Common isValidString:strLastName]) {
            fullName = strLastName;
        }
        
        //Get mobile phone
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(people, kABPersonPhoneProperty));
        
        NSString* mobileLabel;
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                break ;
            }
            
        }
        
        //Get avatar image
        if (ABPersonHasImageData(people)) {
            if ( &ABPersonCopyImageDataWithFormat != nil ) {
                dataAvatar = (__bridge NSData *)ABPersonCopyImageDataWithFormat(people, kABPersonImageFormatThumbnail);
            } else {
                dataAvatar = nil;
            }
        } else dataAvatar = nil;
        
        //Add to array contact
        PersonContactObj *obj = [[PersonContactObj alloc] initWith:Id andName:fullName andPhoneNumber:phoneNumber andDataImage:dataAvatar andIsSaved:isSave];
        if (phoneNumber.length > 0) {
            [_arrContacts addObject:obj];
        }
    }
    [Common hideLoadingViewGlobal];
    if ([_arrContacts count] > 0) {
        [_tblView reloadData];
    }
}

#pragma - mark Search Display Controller Delegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (void) searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [self getContactAndReload];
}

#pragma mark - ACTION

- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionDone:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) actionCheckUncheck:(UIButton *) bt {
    int index = (int)bt.tag;
    //Get object at index
    PersonContactObj *obj;
    
    obj = [_arrContacts objectAtIndex:index];
    
    
    if (obj.isSaved) {
        //Un-check
        obj.isSaved = NO;
        [self removeContactToUserDefault:obj.recordId andPhoneNumber:obj.strMobile];
    } else {
        //Check
        obj.isSaved = YES;
        [self addContactToUserDefault:obj.recordId andPhoneNumber:obj.strMobile];
    }
    
    [_arrContacts replaceObjectAtIndex:index withObject:obj];
    [_tblView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) actionCheckUncheckSearch:(UIButton *) bt {
    int index = (int)bt.tag;
    //Get object at index
    PersonContactObj *obj;
    
    obj = [_searchResults objectAtIndex:index];
    
    if (obj.isSaved) {
        //Un-check
        obj.isSaved = NO;
        [self removeContactToUserDefault:obj.recordId andPhoneNumber:obj.strMobile];
    } else {
        //Check
        obj.isSaved = YES;
        [self addContactToUserDefault:obj.recordId andPhoneNumber:obj.strMobile];
    }
    
    [_searchResults replaceObjectAtIndex:index withObject:obj];
    [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

}

@end
