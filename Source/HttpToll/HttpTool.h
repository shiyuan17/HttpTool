//
//  HttpTool.h
//  DotaMaster
//
//  Created by 世缘 on 15/4/9.
//  Copyright (c) 2015年 Qian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpTool : NSObject


typedef NS_ENUM(NSInteger, HttpErrorType) {
    HttpErrorTypeNormal=0,//请求正常，无错误
    
    HttpErrorTypeURLConnectionError,//请求时出错，可能是URL不正确
    
    HttpErrorTypeStatusCodeError,//请求时出错，服务器未返回正常的状态码：200
    
    HttpErrorTypeDataNilError,//请求回的Data在解析前就是nil，导致请求无效，无法后续JSON反序列化。
    
    HttpErrorTypeDataSerializationError,//data在JSON反序列化时出错
    
    HttpErrorTypeNoNetWork,//无网络连接
    
    HttpErrorTypeServiceRetrunErrorStatus,//服务器请求成功，但抛出错误
};

typedef NS_ENUM(NSInteger, HttpCacheType) {
    HttpCacheTypeNormal=0,//普通请求不缓存数据
    HttpCacheTypeRequest//请求并使用缓存(有缓存就使用缓存不发起请求)
};

//单位分钟
typedef NS_ENUM(NSInteger, HttpCacheExpiredTimeType) {
    HttpCacheExpiredTimeTypeNormal=0,/**<不设置过期时间*/
    HttpCacheExpiredTimeTypeThirtyMinutes=30,/**<30分钟*/
    HttpCacheExpiredTimeTypeOneDay=1440,/**<一天*/
    HttpCacheExpiredTimeTypeTwoDay=2880/**<两天*/
};



typedef NS_ENUM(NSInteger, HttpRequestType) {
    HttpRequestTypeGet=0,
    
    HttpRequestTypePost
};

typedef void (^successBlock)(id obj);

typedef void (^errorBlock)(HttpErrorType errorType);
typedef void (^failureBlocks)(NSError *error);
typedef void (^clearHttpCacheBlock)();
typedef void (^clearHttpExpiredCacheBlock)();

/**
 *  总的请求，包含cache
 *
 *  @param cacheType   缓存的类型
 *  @param requestType  请求类型
 *  @param params 请求的参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (void)requestHttpWithCacheType:(HttpCacheType)cacheType requestType:(HttpRequestType)requestType expired:(HttpCacheExpiredTimeType)expiredType url:(NSString *)url params:(NSDictionary *)params success:(successBlock)success failure:(void (^)(NSError *))failure;


/**
 *  发送一个POST请求
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (void)postWithURL:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;

/**
 *  发送一个POST请求(上传文件数据)
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param formData  文件参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (void)postWithURL:(NSString *)url params:(NSDictionary *)params formDataArray:(NSArray *)formDataArray success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;

/**
 *  发送一个GET请求
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (void)getWithURL:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;


+ (void)clearAllLocalHttpCache:(clearHttpCacheBlock)block;/**<清除所有本地http缓存*/
+ (void)clearAllLocalHttpTimeCache:(clearHttpExpiredCacheBlock)block;/**<清除所有http时间缓存*/
@end


/**
 *  用来封装文件数据的模型
 */
@interface HttpToolFormData : NSObject
/**
 *  文件数据
 */
@property (nonatomic, strong) NSData *data;

/**
 *  参数名
 */
@property (nonatomic, copy) NSString *name;

/**
 *  文件名 必须加后缀
 */
@property (nonatomic, copy) NSString *filename;

/**
 *  文件类型
 */
@property (nonatomic, copy) NSString *mimeType;
@end