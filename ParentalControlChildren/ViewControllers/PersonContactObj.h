//
//  PersonContactObj.h
//  ParentalControlChildren
//
//  Created by Huynh Phong Chau on 5/9/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonContactObj : NSObject

- (id) initWith:(NSString *) strName andPhoneNumber:(NSString *)strPhoneNumber andDataImage:(NSData *) dataImg;
@property(nonatomic, strong) NSString *strName;
@property(nonatomic, strong) NSString *strMobile;
@property(nonatomic, strong) NSData *dataImage;

@end
