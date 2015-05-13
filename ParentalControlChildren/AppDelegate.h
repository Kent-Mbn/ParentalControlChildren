//
//  AppDelegate.h
//  ParentalControlChildren
//
//  Created by CHAU HUYNH on 5/6/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Common.h"
#import "Define.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "UserDefault.h"
#import "APIService.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate> {
    NSString *strPusherId;
    NSString *strChildId;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

