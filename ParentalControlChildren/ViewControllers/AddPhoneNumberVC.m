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
    _searchResults = [[NSArray alloc] init];
    _viewTopBar.backgroundColor = masterColor;
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor blackColor];
}

- (void) viewWillAppear:(BOOL)animated {
    [self getAllPeopleFromContactList];
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
- (void) filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"strName contains[c] %@", searchText];
    _searchResults = [_arrContacts filteredArrayUsingPredicate:resultPredicate];
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
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        obj = [_searchResults objectAtIndex:indexPath.row];
    } else {
        obj = [_arrContacts objectAtIndex:indexPath.row];
    }
    
    cell.lblName.text = obj.strName;
    cell.lblPhoneNumber.text = obj.strMobile;
    
    if (obj.dataImage != nil) {
        cell.imgAvatar.image = [UIImage imageWithData:obj.dataImage];
    } else {
        cell.imgAvatar.image = [UIImage imageNamed:@"ic_people.png"];
    }
    
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
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
    NSArray *allPeoples = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    NSString *fullName;
    NSString *phoneNumber;
    NSData *dataAvatar;
    
    for (id record in allPeoples) {
        ABRecordRef people = (__bridge ABRecordRef)record;
        
        //Get name
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(people, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(people, kABPersonLastNameProperty);
        fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
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
        PersonContactObj *obj = [[PersonContactObj alloc] initWith:fullName andPhoneNumber:phoneNumber andDataImage:dataAvatar];
        if (phoneNumber.length > 0) {
            [_arrContacts addObject:obj];
        }
    }
    if ([_arrContacts count] > 0) {
        [_tblView reloadData];
    }
}

#pragma - mark Search Display Controller Delegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

#pragma mark - ACTION

- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionDone:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
