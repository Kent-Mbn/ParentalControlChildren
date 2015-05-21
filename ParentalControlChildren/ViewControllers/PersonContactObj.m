//
//  PersonContactObj.m
//  ParentalControlChildren
//
//  Created by Huynh Phong Chau on 5/9/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "PersonContactObj.h"

@implementation PersonContactObj

- (id) initWith:(NSInteger)Id andName:(NSString *) strName andPhoneNumber:(NSString *)strPhoneNumber andDataImage:(NSData *) dataImg {
    if (self = [super init]) {
        self.recordId = Id;
        self.strName = strName;
        self.strMobile = strPhoneNumber;
        self.dataImage = dataImg;
    }
    return self;
}

@end
