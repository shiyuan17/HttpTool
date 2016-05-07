//
//  NSDictionary+syCategory.m
//  syUtil
//
//  Created by 世缘 on 15/2/4.
//  Copyright (c) 2015年 sy. All rights reserved.
//

#import "NSDictionary+Category.h"

@implementation NSDictionary (Category)
- (NSString *)dictionaryToJson {
    return [NSDictionary dictionaryToJson:self];
}

+ (NSString *)dictionaryToJson:(NSDictionary *)dictionary {
    NSString *json     = nil;
    NSError  *error    = nil;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    
    if (!jsonData) {
        return @"{}";
    } else if (!error) {
        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    } else {
        return error.localizedDescription;
    }
}
@end
