//
//  YVMNetWorkConfig.h
//  YVM
//
//  Created by mac on 2019/12/11.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YVMCommon.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^YVMNetBlock)(void);

typedef void(^YVMNetDataSuccessBlock)(BOOL isStatusSuccess, NSDictionary *responseDict);

typedef void(^YVMNetDataFailureBlock)(YVMResponseStatus status,NSError *error);

typedef void(^YVMStartListBlock)(NSInteger indexPage);

typedef NSDictionary *_Nullable(^YVMFinishListBlock)(NSInteger indexPage, NSDictionary *responseDict);

@interface YVMNetWorkConfig : NSObject

+ (instancetype)share;

/** YVMNetWorkManager */
@property (nonatomic, copy) NSString *httpBaseUrl;  /**<  请求接口网址 */

@property (nonatomic, copy) NSSet *acceptableContentTypes;  /**< 可接收返回类型 */

@property (nonatomic, copy) NSDictionary *commonParam;  /**< 所有接口默认添加参数  */

@property (nonatomic, assign) BOOL debug;  /**< 是否接口调试模式 */

@property (nonatomic, assign) BOOL useJsonParsing;  /**< 对服务器返回数据进行json解析 默认为YES */


/** YVMRequestManage */
@property (nonatomic, copy) YVMNetBlock startCommonBlock;  /**<  所有通讯开始如果没有start方法将会调用该方法  */

@property (nonatomic, copy) YVMNetDataSuccessBlock successCommonBlock;  /**<  所有通讯成功后有该方法将会调用，没有不调用  */

@property (nonatomic, copy) YVMNetDataFailureBlock failureCommonBlock;  /**<  所有通讯失败后有该方法将会调用，没有不调用  */

@property (nonatomic, assign) BOOL successStatusDeal;  /**<  是否对成功返回的数据进行状态判断  成功状态才进行返回处理 */

@property (nonatomic, assign) NSInteger statusCode;  /**< 成功状态码 */

@property (nonatomic, copy) NSString *status;  /**< 成功状态解析字符串 */

@property (nonatomic, copy) NSString *content;  /**< 去除状态相关字段后的内容字段 */


/** YVMListViewManage */
@property (nonatomic, copy) YVMStartListBlock startListBlock;  /**<  列表开始请求 */

@property (nonatomic, copy) YVMFinishListBlock finishListBlock;  /**<  列表数据请求结束  */

@end

NS_ASSUME_NONNULL_END
