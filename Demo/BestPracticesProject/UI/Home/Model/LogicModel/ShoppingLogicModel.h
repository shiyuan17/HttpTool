//
//  ShoppingLogicModel.h
//  BestPracticesProject
//
//  Created by A on 16/5/7.
//  Copyright © 2016年 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShoppingList;
@interface ShoppingLogicModel : NSObject

@property (nonatomic, strong) NSArray<ShoppingList *> *array;

@end
@interface ShoppingList : NSObject

@property (nonatomic, copy) NSString *title;/**<标题*/

@property (nonatomic, copy) NSString *money;/**<钱*/

@property (nonatomic, assign) BOOL isCheck;/**<是否选中*/
@end

