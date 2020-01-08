//
//  YVMCommon.h
//  YVM
//
//  Created by mac on 2019/12/25.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#ifndef YVMCommon_h
#define YVMCommon_h


#endif /* YVMCommon_h */

#define YVMLog(...) printf("%f %s\n",[[NSDate date]timeIntervalSince1970],[[NSString stringWithFormat:__VA_ARGS__]UTF8String]);

#define UI_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define UI_SCREEN_HEIGHT [[UIScreen  mainScreen] bounds].size.height

#ifndef    weakify
#if __has_feature(objc_arc)

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) weak##x = x; \
_Pragma("clang diagnostic pop")

#else

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __block __typeof__(x) block##x = x; \
_Pragma("clang diagnostic pop")

#endif
#endif

#ifndef    strongify
#if __has_feature(objc_arc)

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = weak##x; \
_Pragma("clang diagnostic pop")

#else

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = block##x; \
_Pragma("clang diagnostic pop")

#endif
#endif

//http 常用状态码
typedef enum {
    YVMResponseStatusOhter = -1,
    YVMResponseStatusOk = 200, //成功处理请求
    YVMResponseStatusCreated = 201, //请求成功并创建新资源
    YVMResponseStatusAccepted = 202, //请求成功但未创建资源
    YVMResponseStatusNoContent = 204, //请求成功但未创建资源
    YVMResponseStatusMovedPermanently = 301,//请求url已被转移
    YVMResponseStatusSeeOther = 303,//需对其他位置单独请求响应
    YVMResponseStatusNotModified = 304,//请求资源未被修改
    YVMResponseStatusBadBRequest = 400,//参数错误或服务器无法解析该语法
    YVMResponseStatusUnauthorized = 401,//需要登录
    YVMResponseStatusForbidden = 403,//无权限被服务器拒绝
    YVMResponseStatusNotFound = 404,//请求url不存在
    YVMResponseStatusNotAcceptable = 406,//服务器不支持该url所需表示
    YVMResponseStatusConflict = 409,//服务器处理请求信息发生冲突
    YVMResponseStatusPreconditionFailed = 412,//更新发生冲突
    YVMResponseStatusUnsupportedMediaType = 415,//请求url不支持该请求格式
    YVMResponseStatusInternalServerError = 500,//服务器内部通用错误
    YVMResponseStatusServiceUnavailabl = 503,//服务器暂不可用
} YVMResponseStatus;

typedef enum {
    YVMRefreshType_loadNew,  //重新加载最新
    YVMRefreshType_loadMore  //加载更多
} YVMRefreshType;

typedef enum {
    YVMTableType_None,  //普通 无刷新，无空提示视图，无加载更多
    YVMTableType_Empty,   //空提示视图
    YVMTableType_Refresh,  //下拉刷新
    YVMTableType_More,   //上拉加载
    YVMTableType_RefreshEmpty,   //下拉刷新，空提示视图
    YVMTableType_RefreshMore,    //下拉刷新，上拉加载
    YVMTableType_MoreEmpty,      //上拉加载，空提示视图
    YVMTableType_RefreshMoreEmpty, //下拉刷新，上拉加载，空提示视图
} YVMTableType;

typedef enum {
    YVMCollectionType_None,  //普通 无刷新，无空提示视图，无加载更多
    YVMCollectionType_Empty,   //空提示视图
    YVMCollectionType_Refresh,  //下拉刷新
    YVMCollectionType_More,   //上拉加载
    YVMCollectionType_RefreshEmpty,   //下拉刷新，空提示视图
    YVMCollectionType_RefreshMore,    //下拉刷新，上拉加载
    YVMCollectionType_MoreEmpty,      //上拉加载，空提示视图
    YVMCollectionType_RefreshMoreEmpty, //下拉刷新，上拉加载，空提示视图
} YVMCollectionType;
