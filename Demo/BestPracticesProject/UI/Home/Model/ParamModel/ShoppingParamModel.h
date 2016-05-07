//
//  ShoppingParamModel.h
//  BestPracticesProject
//
//  Created by A on 16/5/7.
//  Copyright © 2016年 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShoppingParamModel : NSObject
@property (strong ,nonatomic) NSString  *name;/**<名称*/
@property (assign ,nonatomic) NSInteger age;/**<年龄*/

- (instancetype) initWithName:(NSString *)name age:(NSInteger)age;
@end
