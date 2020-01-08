//
//  YVMNetWorkClient.h
//  YVM
//
//  Created by mac on 2019/9/9.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import <AFHTTPSessionManager.h>

#import "YVMCommon.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    YVMRequestMethodGet = 110,
    YVMRequestMethodPost,
    YVMRequestMethodDelete,
    YVMRequestMethodPut,
    YVMRequestMethodHead,
    YVMRequestMethodPatch,
} YVMRequestMethod;

@class YVMNetWorkManager;
@protocol YVMRequestDelegate <NSObject>

@optional
/** 开始网络请求 */
- (void)startRequest:(YVMNetWorkManager *)client;

/** 网络请求成功 */
- (void)requestDidSuccess:(YVMNetWorkManager *)client dataTask:(NSURLSessionDataTask *)task status:(YVMResponseStatus)status object:(id)object;

/** 网络请求失败 */
- (void)requestDidFailure:(YVMNetWorkManager *)client dataTask:(NSURLSessionDataTask *)task status:(YVMResponseStatus)status error:(NSError *)error;

@end

@interface YVMNetWorkManager : AFHTTPSessionManager

@property (nonatomic, copy) NSString *interfaceString;  /**< 接口名 */

@property (nonatomic, assign) YVMRequestMethod requestMethod;  /**< 默认为Post请求 */

@property (nonatomic, weak) id<YVMRequestDelegate> delegate;  /**<  */

- (instancetype)initWithBaseUrlString:(NSString *)baseUrlString;

- (NSURLSessionDataTask *)requestWithParameters:(NSMutableDictionary *)parameters;

/** 取消网络请求 */
- (void) cancel;

/**
 将数据处理为JSON格式
 
 @param responseObject 用于处理的数据
 @return json对象数据
 */
+ (id)parseResponseDataToJSON:(id)responseObject;

@end

NS_ASSUME_NONNULL_END
