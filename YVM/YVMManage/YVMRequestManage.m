//
//  YVMRequestManage.m
//  YVM
//
//  Created by mac on 2019/9/18.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import "YVMRequestManage.h"
#import <CommonCrypto/CommonDigest.h>
#import "YVMNetWorkConfig.h"

@interface YVMRequestManage () <YVMRequestDelegate>

@property (nonatomic, strong) NSMutableDictionary *requestDict;

@property (nonatomic, strong) NSMutableDictionary *errorCodeDict;

@end

@implementation YVMRequestManage

static id defaultManager = nil;

+ (instancetype)defalut {
    @synchronized(self){
        if (!defaultManager) {
            defaultManager = [[self allocWithZone:NULL] init];
        }
    }
    return defaultManager;
}

+ (void)addReq:(NSObject *)sender
     interface:(NSString *)interface
        params:(NSMutableDictionary *)params
       success:(YVMNetDataSuccessHandler __nullable)success
       failure:(YVMNetDataFailureHandler __nullable)failure {
    [YVMRequestManage addReq:sender
                   interface:interface
                      params:params
               requestMethod:YVMRequestMethodPost
                     success:success
                     failure:failure];
}

+ (void)addReq:(NSObject *)sender
     interface:(NSString *)interface
        params:(NSMutableDictionary *)params
 requestMethod:(YVMRequestMethod)requestMethod
       success:(YVMNetDataSuccessHandler __nullable)success
       failure:(YVMNetDataFailureHandler __nullable)failure {
    [YVMRequestManage addReq:sender
                   interface:interface
                      params:params
               requestMethod:requestMethod
                    starting:nil
                     success:success
                     failure:failure];
}

+ (void)addReq:(NSObject *)sender
     interface:(NSString *)interface
        params:(NSMutableDictionary *)params
 requestMethod:(YVMRequestMethod)requestMethod
      starting:(YVMNetHandler __nullable)starting
       success:(YVMNetDataSuccessHandler __nullable)success
       failure:(YVMNetDataFailureHandler __nullable)failure {
    [YVMRequestManage addReq:sender
                     baseUrl:nil
                   interface:interface
                      params:params
               requestMethod:requestMethod
                    starting:starting
                     success:success
                     failure:failure];
}

+ (void)addReq:(NSObject *)sender
       baseUrl:(NSString * __nullable)baseUrl
     interface:(NSString *)interface
        params:(NSMutableDictionary *)params
 requestMethod:(YVMRequestMethod)requestMethod
      starting:(YVMNetHandler __nullable)starting
       success:(YVMNetDataSuccessHandler __nullable)success
       failure:(YVMNetDataFailureHandler __nullable)failure {
    if (!sender.yvmId) {
        sender.yvmId = [self yvmId];
    }
    NSString *ctlName = sender.yvmId;
    
    YVMRequestManage *manage = [YVMRequestManage defalut];
    
    if (ctlName) {
        NSMutableDictionary *ctrRequestsDict = manage.requestDict[ctlName];
        if (!ctrRequestsDict) {
            ctrRequestsDict = [NSMutableDictionary dictionary];
            manage.requestDict[ctlName] = ctrRequestsDict;
        }
        
        YVMNetWorkClient *client = ctrRequestsDict[interface];
        if (client == nil) {
            client = [manage newNetClientWithBaseUrl:baseUrl yvmId:ctlName interface:interface];
            client.starting = starting;
            client.successResponse = success;
            client.failureResponse = failure;
            client.requestMethod = requestMethod;
            ctrRequestsDict[interface] = client;
        } else {
            [client cancel];
        }
        
        if (client.starting != starting) {
            client.starting = starting;
        }
        
        if (client.successResponse != success) {
            client.successResponse = success;
        }
        
        if (client.failureResponse != failure) {
            client.failureResponse = failure;
        }
        
        if (params) {
            [client requestWithParameters:params];
        }
    }
}

#pragma mark HTTPClientDelegate
/**
 *      开始加载
 */
- (void)startRequest:(YVMNetWorkClient *)client {
    if (client.starting) {
        client.starting();
    } else if ([YVMNetWorkConfig share].startCommonBlock){
        [YVMNetWorkConfig share].startCommonBlock();
    }
}

/**
 *      返回成功
 */
- (void)requestDidSuccess:(YVMNetWorkClient *)client dataTask:(NSURLSessionDataTask *)task status:(YVMResponseStatus)status object:(id)object {
    YVMNetWorkConfig *config = [YVMNetWorkConfig share];
    
    if (config.successCommonBlock){
        if (config.successStatusDeal && config.status.length && config.content.length) {
            NSString *status = [object objectForKey:config.status];
            NSDictionary *dict = [object objectForKey:config.content];
            config.successCommonBlock([status integerValue] == config.statusCode,dict);
        } else {
            config.successCommonBlock(YES, object);
        }
    }
    
    if (config.successStatusDeal && config.status.length && config.content.length) {
        NSString *status = [object objectForKey:config.status];
        if (client.successResponse) {
            NSDictionary *dict = [object objectForKey:config.content];
            client.successResponse([status integerValue] == config.statusCode,dict);
        }
    } else {
        if (client.successResponse) {
            client.successResponse(YES, object);
        }
    }
}

/**
 *      返回失败
 */
- (void)requestDidFailure:(YVMNetWorkClient *)client dataTask:(NSURLSessionDataTask *)task status:(YVMResponseStatus)status error:(NSError *)error {
    if (client.failureResponse) {
        client.failureResponse(status ,error);
    } else if ([YVMNetWorkConfig share].failureCommonBlock) {
        [YVMNetWorkConfig share].failureCommonBlock(status ,error);
    }
}

- (YVMNetWorkClient *)getClientWithYvmId:(NSString *)yvmId name:(NSString *)name {
    if (yvmId && name) {
        NSMutableDictionary *ctrRequestsDict = self.requestDict[yvmId];
        if (!ctrRequestsDict) {
            YVMNetWorkClient *client = ctrRequestsDict[name];
            ctrRequestsDict = nil;
            return client;
        }
        return nil;
    }
    return nil;
}

- (YVMNetWorkClient *)newNetClientWithBaseUrl:(NSString *)baseUrl yvmId:(NSString *)yvmId interface:(NSString *)interface {
    YVMNetWorkClient *client;
    if (baseUrl.length) {
        client = [[YVMNetWorkClient alloc] initWithBaseUrlString:baseUrl];
    } else {
        client = [[YVMNetWorkClient alloc] init];
    }
    
    [client setYvmId:yvmId];
    [client setInterfaceString:interface];
    [client setDelegate:self];
    return client;
}

- (void)requestWithClient:(YVMNetWorkClient *)client params:(NSMutableDictionary *)params {
    if (client) {
        [client cancel];
        [client requestWithParameters:params];
    }
}

/**
 取消所有请求
 */
+ (void)cancelRequest:(NSObject *)sender {
    if (!sender.yvmId) {
        return;
    }
    NSString *ctlName = sender.yvmId;
    
    YVMRequestManage *manage = [YVMRequestManage defalut];
    
    if (ctlName) {
        NSMutableDictionary *ctrRequestsDict = manage.requestDict[ctlName];
        
        for (NSString *key in ctrRequestsDict) {
            YVMNetWorkClient *client = ctrRequestsDict[key];
            [client cancel];
            client.delegate = nil;
        }
    }
}

/**
 取消某个请求
 @param interface  请求接口名
 */
+ (void)cancelRequest:(NSObject *)sender interface:(NSString *)interface {
    if (!sender.yvmId) {
        return;
    }
    NSString *ctlName = sender.yvmId;
    
    YVMRequestManage *manage = [YVMRequestManage defalut];
    
    if (ctlName) {
        NSMutableDictionary *ctrRequestsDict = manage.requestDict[ctlName];
        
        for (NSString *key in ctrRequestsDict) {
            YVMNetWorkClient *client = ctrRequestsDict[key];
            if ([client.interfaceString isEqualToString:interface]) {
                [client cancel];
                client.delegate = nil;
                break;
            }
        }
    }
}

+  (void)removeRequest:(NSObject *)sender {
    if (!sender.yvmId) {
        return;
    }
    NSString *ctlName = sender.yvmId;
    YVMRequestManage *manage = [YVMRequestManage defalut];
    
    if (ctlName) {
        NSMutableDictionary *ctrRequestsDict = manage.requestDict[ctlName];
        
        for (NSString *key in ctrRequestsDict) {
            YVMNetWorkClient *client = ctrRequestsDict[key];
            [client cancel];
            client.delegate = nil;
            client.starting = nil;
            client.successResponse = nil;
            client.failureResponse = nil;
            [client invalidateSessionCancelingTasks:YES];
        }
        [ctrRequestsDict removeAllObjects];
        [manage.requestDict removeObjectForKey:ctlName];
    }
}

/**
 生成页面编码
 */
+ (NSString *)yvmId {
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSInteger randomNum = arc4random() % 100000000;
    NSString *numStr = [NSString stringWithFormat:@"%.6f%ld",nowTimeInterval ,randomNum];
    NSString *yvmId = [self md5:numStr];
    
    return yvmId;
}

/**
 将字符串md5处理
 
 @param str 需要处理的字符串
 @return md5后的字符串
 */
+ (NSString *)md5:(NSString *)str {
    const char* cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (NSInteger i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    
    return ret;
}

@end
