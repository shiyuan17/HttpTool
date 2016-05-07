//
//  ShoppingParamModel.m
//  BestPracticesProject
//
//  Created by A on 16/5/7.
//  Copyright © 2016年 sy. All rights reserved.
//

#import "ShoppingParamModel.h"

@implementation ShoppingParamModel
- (instancetype) initWithName:(NSString *)name age:(NSInteger)age{
    if (self = [super init]) {
        self.name = name;
        self.age= age;
    }
    return self;
}
@end
