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
@property(nonatomic,strong) NSString *isPaired;
@property(nonatomic,strong) NSString *email;
@property(nonatomic,strong) NSString *full_name;
@property(nonatomic,strong) NSString *content_mss;
@property(nonatomic,strong) NSString *lats;
@property(nonatomic,strong) NSString *longs;
@property(nonatomic,strong) NSString *radiusCircle;
@property(nonatomic,strong) NSString *arrContactIds;
@property(nonatomic,strong) NSString *arrPhoneNumbers;
@property(nonatomic,strong) NSString *deviceTokenParents;

+ (UserDefault *) user;
- (void) update;
+ (void) update;
+ (void) clearInfo;

@end
