//
//  NSDictionary+syCategory.h
//  syUtil
//
//  Created by 世缘 on 15/2/4.
//  Copyright (c) 2015年 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Category)
/**
 *  把当前Dictionary转换为json
 *
 *  @return 转换后的json字符串
 */
- (NSString *)dictionaryToJson;

/**
 *  把指定的Dictionary转换为json
 *
 *  @param dictionary 要转换的dictionary
 *
 *  @return 转换后的json字符串，失败则为{}
 */
+ (NSString *)dictionaryToJson:(NSDictionary *)dictionary;
@end
