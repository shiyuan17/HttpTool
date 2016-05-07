//
//  HttpTool.m
//  DotaMaster
//
//  Created by 世缘 on 15/4/9.
//  Copyright (c) 2015年 Qian. All rights reserved.
//

#import "HttpTool.h"
#import "AFNetworking.h"
#import "TMCache.h"
#import "NSString+MD5.h"
#import "NSDictionary+Category.h"
NSString *const HttpCacheArrayKey = @"HttpCacheArrayKey";
NSString *const HttpExpiredCacheArrayKey = @"HttpExpiredCacheArrayKey";
#define isbeforeIOS7 ([[[UIDevice currentDevice]systemVersion]floatValue] < 7.0?YES:NO)

static dispatch_source_t _timer;

@implementation HttpTool
+ (void)initialize{
    [self regularlyCheckExpiredHttpCache];
}

#pragma mark - 网络请求前处理，无网络不请求
+(BOOL)requestBeforeCheckNetWorkWithFailureBlock:(failureBlocks)errorBlock{
    AFNetworkReachabilityStatus networkStatu=[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    BOOL isFi;
    if(networkStatu==AFNetworkReachabilityStatusNotReachable){//无网络
        isFi = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(errorBlock!=nil){
                errorBlock(nil);
                NSLog(@"无网络,请打开网络");
            }
        });
    }else{//有网络
        isFi = YES;
        [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    }
    
    return isFi;
}

#pragma mark - 网络请求带缓存
+ (void)requestHttpWithCacheType:(HttpCacheType)cacheType requestType:(HttpRequestType)requestType expired:(HttpCacheExpiredTimeType)expiredType url:(NSString *)url params:(NSDictionary *)params success:(successBlock)success failure:(void (^)(NSError *))failure
{
    
    switch (cacheType) {
        case HttpCacheTypeNormal:
            if (requestType == HttpRequestTypeGet) {
                [self getWithURL:url params:params success:success failure:failure];
            }else{
                [self postWithURL:url params:params success:success failure:failure];
            }
            
            break;
        case HttpCacheTypeRequest:{
            NSString *cacheKey = [self getHttpCacheKeyWithUrl:url param:params];
            
            id obj;
            obj = [[TMCache sharedCache] objectForKey:cacheKey];
            if (obj) {
                success(obj);
            }else{
                
                if (requestType == HttpRequestTypeGet) {
                    [self getWithURL:url params:params success:^(id json) {
                        if (json) {
                            [self saveHttpCacheObjectWith:url param:params expired:expiredType obj:json];
                            success(json);
                        }
                    } failure:failure];
                }else{
                    [self postWithURL:url params:params success:^(id json) {
                        if (json) {
                            [self saveHttpCacheObjectWith:url param:params expired:expiredType obj:json];
                            success(json);
                        }
                    } failure:failure];
                }
                
            }
            
            break;
        }
        default:
            break;
    }
}


#pragma mark - post
+ (void)postWithURL:(NSString *)url params:(NSDictionary *)params success:(successBlock)success failure:(void (^)(NSError *))failure
{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if(![self requestBeforeCheckNetWorkWithFailureBlock:failure]){
            return;
        }
        //为url编码
        NSString *urlStr = [self urlCoding:url];
        // 2.发送请求
        [[self getHttpSessionManager] POST:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            if (success) {
                success(responseObject);
            }

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            if (failure) {
                NSLog(@"网络请求日志\n请求URL：%@ \n信息：%@",url,[error.userInfo objectForKey:@"NSLocalizedDescription"]);
                failure(error);
            }
        }];
        
    });
    
}

#pragma mark  post 文件请求formData
+ (void)postWithURL:(NSString *)url params:(NSDictionary *)params formDataArray:(NSArray *)formDataArray success:(successBlock)success failure:(void (^)(NSError *))failure
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if(![self requestBeforeCheckNetWorkWithFailureBlock:failure]){
            return;
        }
        //为url编码
        NSString *urlStr = [self urlCoding:url];
        
        [[self getHttpSessionManager] POST:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull totalFormData) {
            for (HttpToolFormData *formData in formDataArray) {
                [totalFormData appendPartWithFileData:formData.data name:formData.name fileName:formData.filename mimeType:formData.mimeType];
            }
        } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            if (success) {
                success(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            if (failure) {
                NSLog(@"网络请求日志\n请求URL：%@ \n信息：%@",url,[error.userInfo objectForKey:@"NSLocalizedDescription"]);
                failure(error);
            }
        }];
    });
    
}

#pragma mark  get请求
+ (void)getWithURL:(NSString *)url params:(NSDictionary *)params success:(successBlock)success failure:(void (^)(NSError *))failure
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if(![self requestBeforeCheckNetWorkWithFailureBlock:failure]){
            return;
        }
        //为url编码
        NSString *urlStr = [self urlCoding:url];
        // 2.发送请求
        
        [[self getHttpSessionManager] GET:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            if (success) {
                success(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            if (failure) {
                NSLog(@"网络请求日志\n请求URL：%@ \n信息：%@",url,[error.userInfo objectForKey:@"NSLocalizedDescription"]);
                failure(error);
            }

        }];

    });
    
}

#pragma mark 创建请求管理对象
+ (AFHTTPSessionManager *)getHttpSessionManager{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript",@"text/plain", nil];
    return manager;
}

#pragma mark url编码 
+ (NSString *)urlCoding:(NSString *)url{
    NSString *encodePath ;
    if (isbeforeIOS7) {
        encodePath = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }else{
        encodePath = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    }
    return encodePath;
}


#pragma mark - 缓存
#pragma mark 保存http缓存对象
+ (void)saveHttpCacheObjectWith:(NSString *)url param:(NSDictionary *)param expired:(HttpCacheExpiredTimeType)expiredType obj:(id)obj{
    NSString *md5CacheKey = [self getHttpCacheKeyWithUrl:url param:param];
    
    [[TMCache sharedCache] setObject:obj forKey:md5CacheKey];
    
    if (expiredType == HttpCacheExpiredTimeTypeNormal) {
        [self saveHttpCacheArrayWithKey:md5CacheKey];//保存cacheKey
    }else{
        [self saveHttpExpiredCacheArrayWithKey:md5CacheKey expired:expiredType];//保存定时缓存 CacheKey
        
    }
    
}

#pragma mark 获取缓存key
+ (NSString *)getHttpCacheKeyWithUrl:(NSString *)url param:(NSDictionary *)param{
    NSString *paramStr = [param dictionaryToJson];
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@%@",url,paramStr,@"cacheKey"];
    NSString *trimText = [cacheKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    NSString *md5CacheKey = [trimText MD5Digest];
    return md5CacheKey;
}


#pragma mark 保存http缓存对应的key 数组
+ (void)saveHttpCacheArrayWithKey:(NSString *)key{
    NSMutableDictionary *cacheDic = [[TMCache sharedCache] objectForKey:HttpCacheArrayKey];
    if (!cacheDic) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:key forKey:key];
        
        [[TMCache sharedCache] setObject:dic forKey:HttpCacheArrayKey];
    }else{
        id obj = [cacheDic objectForKey:key];
        if (!obj) {
            [cacheDic setObject:key forKey:key];
            [[TMCache sharedCache] setObject:cacheDic forKey:HttpCacheArrayKey];
        }
        
    }

}

#pragma mark 保存http过期缓存对应的key 数组
+ (void)saveHttpExpiredCacheArrayWithKey:(NSString *)key expired:(HttpCacheExpiredTimeType)expiredType{
    NSMutableDictionary *cacheDic = [[TMCache sharedCache] objectForKey:HttpExpiredCacheArrayKey];
    
    NSString *cacheKeyDate = [NSString stringWithFormat:@"%@,%ld",[[self getDateFormatter] stringFromDate:[NSDate date]],(long)expiredType];
    if (!cacheDic) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:cacheKeyDate forKey:key];
        
        [[TMCache sharedCache] setObject:dic forKey:HttpExpiredCacheArrayKey];
    }else{
        id obj = [cacheDic objectForKey:key];
        if (!obj) {//判断是否已经保存了对应的key
            [cacheDic setObject:cacheKeyDate forKey:key];
            [[TMCache sharedCache] setObject:cacheDic forKey:HttpExpiredCacheArrayKey];
        }
     
    }
    
}

#pragma mark 清除本地http缓存
+ (void)clearAllLocalHttpCache:(clearHttpCacheBlock)block{
    NSArray *arrs = (NSArray *)[[TMCache sharedCache] objectForKey:HttpCacheArrayKey];
    for (NSString *key in arrs) {
        [[TMCache sharedCache] removeObjectForKey:key];
    }
    [[TMCache sharedCache] removeObjectForKey:HttpCacheArrayKey];
    
    block();
}

#pragma mark 清除所有http本地时间缓存
+ (void)clearAllLocalHttpTimeCache:(clearHttpExpiredCacheBlock)block{
    NSArray *arrs = (NSArray *)[[TMCache sharedCache] objectForKey:HttpExpiredCacheArrayKey];
    for (NSString *key in arrs) {
        [[TMCache sharedCache] removeObjectForKey:key];
    }
    [[TMCache sharedCache] removeObjectForKey:HttpExpiredCacheArrayKey];
    
    block();
}

#pragma mark 定时查询过期缓存，过期则清除
+ (void)regularlyCheckExpiredHttpCache{
    
    NSTimeInterval period = 60.0;/**一分钟检查一次*/
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    
    dispatch_source_set_event_handler(_timer, ^{
        
        NSDictionary *cacheDic = [[TMCache sharedCache] objectForKey:HttpExpiredCacheArrayKey];
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithDictionary:cacheDic];
        BOOL isEdit = NO;
        for (NSString *key in [cacheDic allKeys]) {
            NSString *value = [cacheDic objectForKey:key];
            NSArray *arr = [value componentsSeparatedByString:@","];
            if (arr.count>1) {
                NSDateFormatter *formatter = [self getDateFormatter];
                
                NSString *oldDateStr = arr[0];
                NSDate *oldDate = [formatter dateFromString:oldDateStr];
                CGFloat time = [arr[1] floatValue];
                
                NSString *currentDateStr = [formatter stringFromDate:[NSDate date]] ;
                NSDate *currentDate = [formatter dateFromString:currentDateStr];
                
                NSTimeInterval aTimer = [currentDate timeIntervalSinceDate:oldDate];
                int hour = (int)(aTimer/3600);
                int minute = (int)(aTimer - hour*3600)/60;
//                int second = aTimer - hour*3600 - minute*60;
                if (minute>=time) {
                    isEdit = YES;
                    [[TMCache sharedCache] removeObjectForKey:key];
                    [tmpDic removeObjectForKey:key];
                }
            }
        }
        
        if (isEdit) {
            [[TMCache sharedCache] setObject:tmpDic forKey:HttpExpiredCacheArrayKey];
        }
    });
    
    dispatch_resume(_timer);
}

#pragma mark - 日期对象获取
+ (NSDateFormatter *)getDateFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        formatter  = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return formatter;
}


@end



/**
 *  用来封装文件数据的模型
 */
@implementation HttpToolFormData

@end
