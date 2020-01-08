//
//  YVMNetWorkClient.h
//  YVM
//
//  Created by mac on 2019/9/18.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import "YVMNetWorkManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^YVMNetHandler)(void);

typedef void(^YVMNetDataSuccessHandler)(BOOL isStatusSuccess, NSDictionary *responseDict);

typedef void(^YVMNetDataFailureHandler)(YVMResponseStatus status,NSError *error);

@interface YVMNetWorkClient : YVMNetWorkManager

@property (nonatomic, copy, nullable) NSString *yvmId;

@property (nonatomic, copy, nullable) NSString *name;

@property (nonatomic, copy, nullable) YVMNetHandler starting;

@property (nonatomic, copy, nullable) YVMNetDataSuccessHandler successResponse;

@property (nonatomic, copy, nullable) YVMNetDataFailureHandler failureResponse;

@end

NS_ASSUME_NONNULL_END
