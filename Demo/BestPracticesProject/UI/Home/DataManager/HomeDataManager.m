//
//  HomeDataManager.m
//  BestPracticesProject
//
//  Created by A on 16/5/6.
//  Copyright © 2016年 sy. All rights reserved.
//

#import "HomeDataManager.h"
#import "ShoppingParamModel.h"
#import "ShoppingLogicModel.h"

@implementation HomeDataManager
+ (HomeDataManager *)sharedManager
{
    static HomeDataManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance  = [[self alloc] init];
    });
    return instance;
}

#pragma mark -获取购物车数据
- (void)getShoppingList:(ShoppingParamModel *)param success:(void (^)(ShoppingLogicModel *))success failure:(void (^)(NSError *))failure{
   
    [HttpTool requestHttpWithCacheType:HttpCacheTypeRequest requestType:HttpRequestTypeGet expired:HttpCacheExpiredTimeTypeThirtyMinutes url:TestDataUrl params:param.mj_keyValues success:^(id obj) {
        if (success) {
            ShoppingLogicModel *model = [ShoppingLogicModel mj_objectWithKeyValues:obj];
            success(model);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}
@end
