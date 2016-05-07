//
//  HomeDataManager.h
//  BestPracticesProject
//
//  Created by A on 16/5/6.
//  Copyright © 2016年 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShoppingParamModel,ShoppingLogicModel;
@interface HomeDataManager : NSObject
+ (HomeDataManager *)sharedManager;

/**
 *  获取购物车数据
 *
 *  @param param   购物实体
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getShoppingList:(ShoppingParamModel *)param success:(void (^)(ShoppingLogicModel *))success failure:(void (^)(NSError *))failure;
@end
