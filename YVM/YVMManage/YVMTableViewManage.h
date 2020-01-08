//
//  YVMTableViewManage.h
//  YVM
//
//  Created by mac on 2020/1/7.
//  Copyright © 2020 Xiaobin Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YVMListViewManage.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^YVMTableNorHandler)(void);

typedef void(^YVMTableHandler)(id obj, id vm, NSIndexPath *indexPath);

typedef id _Nullable(^YVMTableViewHandler)(id obj, id vm, id view, NSIndexPath *indexPath);

typedef void(^YVMTableCellControlHandler)(id obj, id vm, id view, NSIndexPath *indexPath, NSInteger tag);

typedef CGFloat(^YVMTableSectionViewHeightHandler)(NSInteger section);

typedef id _Nullable(^YVMTableSectionViewHandler)(NSInteger section);

/////////////////////////            ////////////////////////////

typedef void(^YVMScrollHandler)(CGPoint offset, CGPoint velocity, CGPoint targetOffset);

/////////////////////////            ////////////////////////////

@class YVMRefreshTableView;
@interface YVMTableViewManage : YVMListViewManage

@property (nonatomic, weak) YVMRefreshTableView *tableView;

@property (nonatomic, copy) NSString *cellClassName; /** cell类名 */

@property (nonatomic, assign) CGFloat cellHeight; /** cell高度 */

@property (nonatomic, assign) BOOL isUseVmCellHeight; /** 是否使用vm中控制的高度 */

@property (nonatomic, assign) BOOL isUseVmCellClassName; /** 是否使用vm中控制的类名 */

@property (nonatomic, copy) NSString *vmCellHeightName; /** vm控制cell高度对应的字段名 */

@property (nonatomic, copy) NSString *vmCellClassName; /** vm控制cell类名对应的字段名 */

/////////////////////////            ////////////////////////////

@property (nonatomic, copy) NSString *cellControlMethod; /**< cell点击委托规则名 */

@property (nonatomic, copy) NSArray *controlAddEventTags; /**< cell中哪些tag的view需要添加到点击方法 */

@property (nonatomic, copy) YVMTableCellControlHandler  YVMTableCellControlClick;

/////////////////////////            ////////////////////////////

@property (nonatomic, assign) BOOL isUseCellDelete; /**< 使用cell自带delete功能 */

@property (nonatomic, copy) YVMTableHandler YVMTableDidSelect;

@property (nonatomic, copy) YVMTableHandler YVMTableDidDelete;

@property (nonatomic, copy) YVMTableViewHandler YVMTableCellDraw;

@property (nonatomic, copy) YVMTableSectionViewHandler YVMSectionHeadViewDraw;

@property (nonatomic, copy) YVMTableSectionViewHeightHandler YVMSectionHeadViewDrawHeight;

/////////////////////////            ////////////////////////////

@property (nonatomic, copy) YVMScrollHandler YVMDidScroll;

@property (nonatomic, copy) YVMScrollHandler YVMScroll;

@property (nonatomic, copy) YVMTableNorHandler YVMRefreshNew;  /**< 刷新 */

@property (nonatomic, copy) YVMTableNorHandler YVMRefreshMore;  /**< 更多 */

/////////////////////////            ////////////////////////////

- (YVMTableViewManage *)initBind:(YVMRefreshTableView *)table
                   cellClassName:(NSString *)cellClassName
                        interAPI:(NSString *)interAPI
               parseListDictName:(NSString *)parseListDictName
                    objClassName:(NSString *)objClassName
                     vmClassName:(NSString *)vmClassName
                      cellHeight:(CGFloat)cellHeight;

- (YVMTableViewManage *)initBind:(YVMRefreshTableView *)table
                   cellClassName:(NSString *)cellClassName
                    objClassName:(NSString *)objClassName
                     vmClassName:(NSString *)vmClassName
                      cellHeight:(CGFloat)cellHeight;

- (void)bind;

@end

NS_ASSUME_NONNULL_END
