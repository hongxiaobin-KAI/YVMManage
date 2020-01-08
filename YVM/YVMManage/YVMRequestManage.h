//
//  YVMRequestManage.h
//  YVM
//
//  Created by mac on 2019/9/18.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YVMNetWorkClient.h"
#import "NSObject+YVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface YVMRequestManage : NSObject

+ (void)addReq:(NSObject *)sender
     interface:(NSString *)interface
        params:(NSMutableDictionary *)params
       success:(YVMNetDataSuccessHandler __nullable)success
       failure:(YVMNetDataFailureHandler __nullable)failure;

+ (void)addReq:(NSObject *)sender
     interface:(NSString *)interface
        params:(NSMutableDictionary *)params
 requestMethod:(YVMRequestMethod)requestMethod
       success:(YVMNetDataSuccessHandler __nullable)success
       failure:(YVMNetDataFailureHandler __nullable)failure;

+ (void)addReq:(NSObject *)sender
     interface:(NSString *)interface
        params:(NSMutableDictionary *)params
 requestMethod:(YVMRequestMethod)requestMethod
      starting:(YVMNetHandler __nullable)starting
       success:(YVMNetDataSuccessHandler __nullable)success
       failure:(YVMNetDataFailureHandler __nullable)failure;

+ (void)addReq:(NSObject *)sender
       baseUrl:(NSString * __nullable)baseUrl
     interface:(NSString *)interface
        params:(NSMutableDictionary *)params
 requestMethod:(YVMRequestMethod)requestMethod
      starting:(YVMNetHandler __nullable)starting
       success:(YVMNetDataSuccessHandler __nullable)success
       failure:(YVMNetDataFailureHandler __nullable)failure;

+ (void)cancelRequest:(NSObject *)sender;

+ (void)removeRequest:(NSObject *)sender;

@end

NS_ASSUME_NONNULL_END
