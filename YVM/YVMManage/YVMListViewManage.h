//
//  YVMListViewManage.h
//  YVM
//
//  Created by mac on 2019/12/26.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YVMNetWorkConfig.h"
#import "YVMListSectionManage.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    YVMListRequestType_LoadLocal,
    YVMListRequestType_APIRequest
} YVMListRequestType;

typedef enum {
    YVMListSortType_ASC, //升序 最新的记录在最后面
    YVMListSortType_DESC, //降序  最新的记录在最前面
    YVMListSortType_Page_DESC //页降序   最新的一页在最前面，但是每一页的记录是升序的
} YVMListSortType;

typedef NSArray*_Nullable(^YVMListLoadDataHandler)(NSInteger page, YVMListSortType sortType);

typedef void(^YVMListLoadDataFinishHandler)(NSDictionary *responseDict, NSArray *listSectionManage, NSInteger indexPage);

@interface YVMListViewManage : NSObject

/////////////////////////      请求相关      ////////////////////////////

@property (nonatomic, copy) NSString *interAPI; /** 请求接口 */

@property (nonatomic, copy) NSString *requestPageName; /** 请求的分页参数名 */

@property (nonatomic, copy) NSString *requestPageSizeName; /** 请求的分页大小参数名 */

@property (nonatomic, assign) NSInteger firstPageIndex; /** 首页使用下标 */

@property (nonatomic, assign) NSInteger pageSize;  /** 请求每页大小 */

@property (nonatomic, copy) NSDictionary *addParam; /** 需要的请求额外参数 */

@property (nonatomic, assign) NSInteger indexPage; /**< 请求页下标 */

@property (nonatomic, assign) YVMListRequestType requestType; /** 请求数据类型   本地获取还是网络请求*/

/////////////////////////       常用解析     ////////////////////////////

@property (nonatomic, strong) NSMutableArray *listSectionArray;  /**<  管理每一部分的 head cell footer 的obj 和vm */

@property (nonatomic, copy) NSString *objClassName; /** cell obj类名 */

@property (nonatomic, copy) NSString *vmClassName; /** cell vm类名 */

@property (nonatomic, copy) NSString *objParseMethodName; /** obj类解析类方法名 */

@property (nonatomic, copy) NSString *vmParseMethodName; /** obj类解析方法名 */

@property (nonatomic, copy) NSString *parsePageDictName; /** 解析服务器返回数据    分页字段名 */

@property (nonatomic, copy) NSString *parseListDictName; /**  解析服务器返回数据   列表数组字段名 */

@property (nonatomic, assign) YVMListSortType sortType; /** cell数据排序方式   按服务器返回排序好的数据 */

/////////////////////////      少用解析       ////////////////////////////

@property (nonatomic, assign) BOOL moreSection;  /**  列表是否使用多部分   默认为NO  */

@property (nonatomic, copy) NSString *headObjClassName;  /** section head obj类型      较少使用 */

@property (nonatomic, copy) NSString *headVmClassName;  /** section head vm类型      较少使用 */

@property (nonatomic, copy) NSString *parseHeadObjDictName;  /**  解析服务器返回数据  parseListDictName数组中   nil   @""则表示parseListDictName直接解析为headObj   如果字段名存在则解析parseListDictName的该字段为headObj     */

@property (nonatomic, copy) NSString *headObjSectionName;  /**< headObj 根据该字段进行分组的 */

@property (nonatomic, copy) NSString *parseCellObjDictName;  /**  解析服务器返回数据  parseListDictName数组中   nil或@""则直接将parseListDictName的每一项直接解析为obj  存在则表示该字段是数组字段，该数组内的每一项将解析为obj     */

@property (nonatomic, copy) NSString *footerObjClassName;  /** section footer obj类型      较少使用 */

@property (nonatomic, copy) NSString *footerVmClassName;  /** section footer vm类型      较少使用 */

@property (nonatomic, copy) NSString *parseFooterObjDictName;  /**  解析服务器返回数据  parseListDictName数组中   nil @""则表示parseListDictName直接解析为footerObj    如果字段名存在，则解析parseListDictName该字段为footerObj     */

/////////////////////////      分页判断相关解析      ////////////////////////////

@property (nonatomic, copy) NSString *pageObjClassName; /**< 需要解析分页处理信息的obj类名 */

@property (nonatomic, copy) NSString *pageObjHasMoreName; /**<  */

@property (nonatomic, assign) NSInteger pageNoMoreValue; /**<  */

/////////////////////////      数据过滤      ////////////////////////////

/**
 过滤字典，凡是Dict符合条件的都过滤    或条件
 例如具体值 @{@"id":@["10000",@"20000"]} 则过滤所有id为10000，20000并且类型为字符串的obj，过滤后也不会生成对应vm
 例如正则表达式 @{@"id":"^[A-Za-z0-9]{6,12}$"} 则过滤满足对应正则表达式，过滤后也不会生成对应vm
 */
@property (nonatomic, copy) NSDictionary *filterFieldDict;

/**
 过滤字段数组  且条件
 例如 @[@"userid"],如果userid相同，则保留第一个，其他过滤
 例如 @[@"userid",@"type"],如果userid,type都相同，则保留第一个，其他过滤
 */
@property (nonatomic, copy) NSArray *filterSameFieldArray; /**< 过滤字段值相同的obj，过滤不会生成对应的vm */

/**
 满足过滤条件的是否显示     YES 为满足条件过滤    NO为满足条件的不过滤 暂不用 后期看需求
 */
//@property (nonatomic, assign) BOOL isFilterShow; /**<  */

/////////////////////////            ////////////////////////////

@property (nonatomic, copy) YVMListLoadDataHandler YVMListLoadData;

@property (nonatomic, copy) YVMListLoadDataFinishHandler YVMListLoadDataFinish;

- (void)reloadNewData;

- (void)loadData;

//只有一个section 可以直接传入obj数组       多section需要传入YVMListSectionManage数组，且YVMListSectionManage中的obj数组需要存在
- (void)loadLocalDataWithObjArray:(NSArray *)array;

- (void)clear;

- (void)clearAllData;


//提供给上层重写
- (void)endRefreshing;

- (void)listViewNoMoreData;

- (void)reloadListViewLocation:(NSInteger)index section:(NSInteger)section pageIndex:(NSInteger)pageIndex;

- (void)reloadData;

- (void)deleteCellWithIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
