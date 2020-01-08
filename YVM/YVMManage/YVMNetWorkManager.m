//
//  YVMNetWorkClient.m
//  YVM
//
//  Created by mac on 2019/9/9.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import "YVMNetWorkManager.h"

#import "YVMNetWorkConfig.h"

@interface YVMNetWorkManager () {
    NSString             *_urlString;
}

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@end

@implementation YVMNetWorkManager

- (instancetype)init {
    if ([YVMNetWorkConfig share].httpBaseUrl.length) {
        _urlString = [[YVMNetWorkConfig share].httpBaseUrl copy];
        self = [super initWithBaseURL:[NSURL URLWithString:_urlString]];
    } else {
        self = [super initWithBaseURL:[NSURL URLWithString:@""]];
    }
    if (self) {
        [self defaultSetting];
    }
    return self;
}

- (instancetype)initWithBaseUrlString:(NSString *)baseUrlString {
    _urlString = [baseUrlString copy];
    self = [super initWithBaseURL:[NSURL URLWithString:_urlString]];
    if (self) {
        [self defaultSetting];
    }
    return self;
}

- (void)defaultSetting {
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.responseSerializer.acceptableContentTypes = [YVMNetWorkConfig share].acceptableContentTypes;
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    _requestMethod = YVMRequestMethodPost;
}

- (NSURLSessionDataTask *)requestWithParameters:(NSMutableDictionary *)parameters {
    if ([parameters isKindOfClass:[NSMutableDictionary class]] && [YVMNetWorkConfig share].commonParam) {
        [parameters addEntriesFromDictionary:[YVMNetWorkConfig share].commonParam];
    }
    
    if ([YVMNetWorkConfig share].debug) {
        YVMLog(@"发起请求：\n url:%@\n interfaceString:%@\n params:%@",_urlString ,self.interfaceString, parameters);
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(startRequest:)]) {
        [_delegate startRequest:self];
    }
    
    switch (self.requestMethod) {
        case YVMRequestMethodGet: {
            [self doGetRequestWithParameters:parameters];
        }
            break;
        case YVMRequestMethodPost: {
            [self doPostRequestWithParameters:parameters];
        }
            break;
        case YVMRequestMethodDelete: {
            [self doGetRequestWithParameters:parameters];
        }
            break;
        case YVMRequestMethodPut: {
            [self doDeleteRequestWithParameters:parameters];
        }
            break;
        case YVMRequestMethodHead: {
            [self doHeadRequestWithParameters:parameters];
        }
            break;
        case YVMRequestMethodPatch: {
            [self doPatchRequestWithParameters:parameters];
        }
            break;
            
        default:
            break;
    }
    
    return _dataTask;
}

- (void)doGetRequestWithParameters:(NSMutableDictionary *)parameters {
     __unsafe_unretained __block typeof(self) weakSelf = self;
    _dataTask = [self GET:self.interfaceString
               parameters:parameters
                 progress:^(NSProgress * _Nonnull downloadProgress) {
                 }
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      [weakSelf responseSuccessWithTask:task object:responseObject];
                  }
                  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      [weakSelf responseErrorWithTask:task error:error];
                  }];
}

- (void)doPostRequestWithParameters:(NSMutableDictionary *)parameters {
    __unsafe_unretained __block typeof(self) weakSelf = self;
    _dataTask = [self POST:self.interfaceString
                parameters:parameters
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                  }
                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                       [weakSelf responseSuccessWithTask:task object:responseObject];
                   }
                   failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                       [weakSelf responseErrorWithTask:task error:error];
                   }];
}

- (void)doDeleteRequestWithParameters:(NSMutableDictionary *)parameters {
    __unsafe_unretained __block typeof(self) weakSelf = self;
    _dataTask = [self DELETE:self.interfaceString
                  parameters:parameters
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         [weakSelf responseSuccessWithTask:task object:responseObject];
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         [weakSelf responseErrorWithTask:task error:error];
                     }];
}

- (void)doPutRequestWithParameters:(NSMutableDictionary *)parameters {
    __unsafe_unretained __block typeof(self) weakSelf = self;
    _dataTask = [self PUT:self.interfaceString
               parameters:parameters
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      [weakSelf responseSuccessWithTask:task object:responseObject];
                  }
                  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      [weakSelf responseErrorWithTask:task error:error];
                  }];
}

- (void)doHeadRequestWithParameters:(NSMutableDictionary *)parameters {
    __unsafe_unretained __block typeof(self) weakSelf = self;
    _dataTask = [self HEAD:self.interfaceString
                parameters:parameters
                   success:^(NSURLSessionDataTask * _Nonnull task) {
                       [weakSelf responseSuccessWithTask:task object:nil];
                   }
                   failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                       [weakSelf responseErrorWithTask:task error:error];
                   }];
}

- (void)doPatchRequestWithParameters:(NSMutableDictionary *)parameters {
    __unsafe_unretained __block typeof(self) weakSelf = self;
    _dataTask = [self PATCH:self.interfaceString
                 parameters:parameters
                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        [weakSelf responseSuccessWithTask:task object:responseObject];
                    }
                    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        [weakSelf responseErrorWithTask:task error:error];
                    }];
}

- (void)responseSuccessWithTask:(NSURLSessionDataTask *)task object:(id)object {
    YVMResponseStatus status = [self responseStatusWithTask:task];
    
    if ([YVMNetWorkConfig share].debug) {
        YVMLog(@"服务器返回数据：\n %@",object);
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(requestDidSuccess:dataTask:status:object:)]) {
        if ([YVMNetWorkConfig share].useJsonParsing) {
            id json = [YVMNetWorkManager parseResponseDataToJSON:object];
            
            if (json == nil && [YVMNetWorkConfig share].debug) {
                YVMLog(@"返回json解析失败");
            }
            
            [_delegate requestDidSuccess:self dataTask:task status:status object:json];
        } else {
            [_delegate requestDidSuccess:self dataTask:task status:status object:object];
        }
    }
}

- (void)responseErrorWithTask:(NSURLSessionDataTask *)task error:(NSError *)error {
    YVMResponseStatus status = [self responseStatusWithTask:task];
    
    switch (error.code) {
        case NSURLErrorCancelled: {
            if ([YVMNetWorkConfig share].debug) {
                YVMLog(@"请求取消");
            }
        }
            break;
            
        default: {
            if ([YVMNetWorkConfig share].debug) {
                YVMLog(@"服务器请求异常：\n%@\n", task.response);
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(requestDidFailure:dataTask:status:error:)]) {
                [_delegate requestDidFailure:self dataTask:task status:status error:error];
            }
        }
            break;
    }
}

- (YVMResponseStatus)responseStatusWithTask:(NSURLSessionDataTask *)task {
    NSInteger statusCode = -1;
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        statusCode = response.statusCode;
    }
    return (YVMResponseStatus)statusCode;
}

- (void)cancel {
    if (_dataTask != nil) {
        [_dataTask cancel];
        _dataTask = nil;
        [self.operationQueue cancelAllOperations];
    }
}

/**
 将通讯返回数据处理为JSON格式
 
 @param responseObject 用于处理的数据
 @return json对象数据
 */
+ (id)parseResponseDataToJSON:(id)responseObject {
    id json = nil;
    
    NSError *error = nil;
    NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    
    NSData *JSONData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
    json = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&error];
    if(error == nil) {
        return json;
    } else {
        return nil;
    }
}



@end
