//
//  UserDefault.m
//  UserDefaultEx
//
//  Created by CHAU HUYNH on 10/12/14.
//  Copyright (c) 2014 CHAU HUYNH. All rights reserved.
//

#import "UserDefault.h"
#define kUserDefault_Acc @"User_App"

@implementation UserDefault

static UserDefault *globalObject;

- (id)initWithId:(NSInteger)childId
{
    self.child_id = [NSString stringWithFormat:@"%ld", (long)childId];
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.child_id = [aDecoder decodeObjectForKey:@"child_id"];
        self.isPaired = [aDecoder decodeObjectForKey:@"isPaired"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.token_device = [aDecoder decodeObjectForKey:@"token_device"];
        self.full_name = [aDecoder decodeObjectForKey:@"full_name"];
        self.content_mss = [aDecoder decodeObjectForKey:@"content_mss"];
        self.lats = [aDecoder decodeObjectForKey:@"lats"];
        self.longs = [aDecoder decodeObjectForKey:@"longs"];
        self.radiusCircle = [aDecoder decodeObjectForKey:@"radiusCircle"];
        self.arrContactIds = [aDecoder decodeObjectForKey:@"arrContactIds"];
        self.arrPhoneNumbers = [aDecoder decodeObjectForKey:@"arrPhoneNumbers"];
        self.deviceTokenParents = [aDecoder decodeObjectForKey:@"deviceTokenParents"];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.child_id forKey:@"child_id"];
    [aCoder encodeObject:self.isPaired forKey:@"isPaired"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.token_device forKey:@"token_device"];
    [aCoder encodeObject:self.full_name forKey:@"full_name"];
    [aCoder encodeObject:self.content_mss forKey:@"content_mss"];
    [aCoder encodeObject:self.lats forKey:@"lats"];
    [aCoder encodeObject:self.longs forKey:@"longs"];
    [aCoder encodeObject:self.radiusCircle forKey:@"radiusCircle"];
    [aCoder encodeObject:self.arrContactIds forKey:@"arrContactIds"];
    [aCoder encodeObject:self.arrPhoneNumbers forKey:@"arrPhoneNumbers"];
    [aCoder encodeObject:self.deviceTokenParents forKey:@"deviceTokenParents"];
}

- (void) updateUserDefault
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSKeyedArchiver archivedDataWithRootObject:self] forKey:kUserDefault_Acc];
    [userDefault synchronize];
}

+ (void) clearInfo{
    UserDefault *user = [UserDefault user];
    user.child_id = nil;
    user.email = nil;
    user.isPaired = nil;
    user.token_device = nil;
    user.full_name = nil;
    user.content_mss = nil;
    user.lats = nil;
    user.longs = nil;
    user.radiusCircle = nil;
    user.arrContactIds = nil;
    user.arrPhoneNumbers = nil;
    user.deviceTokenParents = nil;
    [user update];
}

+ (UserDefault *) user
{
    if (!globalObject) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        globalObject = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefault dataForKey:kUserDefault_Acc]] ;
        if (!globalObject) {
            globalObject = [[UserDefault alloc] init] ;
            [globalObject update];
        }
    }
    
    return globalObject;
}
- (void) update
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSKeyedArchiver archivedDataWithRootObject:self]
                    forKey:kUserDefault_Acc];
    [userDefault synchronize];
}

+ (void) update
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSKeyedArchiver archivedDataWithRootObject:globalObject]
                    forKey:kUserDefault_Acc];
    [userDefault synchronize];
}

@end
