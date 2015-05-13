//
//  UserDefault.h
//  UserDefaultEx
//
//  Created by CHAU HUYNH on 10/12/14.
//  Copyright (c) 2014 CHAU HUYNH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefault : NSObject<NSCoding>

@property(nonatomic,strong) NSString *child_id;
@property(nonatomic,strong) NSString *token_device;
@property(nonatomic,strong) NSString *email;
@property(nonatomic,strong) NSString *full_name;

+ (UserDefault *) user;
- (void) update;
+ (void) update;
+ (void) clearInfo;

@end
