//
//  YVMCollectionViewManage.h
//  YVM
//
//  Created by mac on 2020/1/7.
//  Copyright © 2020 Xiaobin Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YVMListViewManage.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^YVMCollectionHandler)(id obj, id vm, NSIndexPath *indexPath);

typedef id _Nullable(^YVMCollectionViewHandler)(id obj, id vm, id view, NSIndexPath *indexPath);

typedef void(^YVMCollectionCellControlHandler)(id obj, id vm, id view, NSIndexPath *indexPath, NSInteger tag);

/////////////////////////            ////////////////////////////

typedef void(^YVMScrollHandler)(CGPoint offset, CGPoint velocity, CGPoint targetOffset);

/////////////////////////            ////////////////////////////

@class YVMRefreshCollectionView;
@interface YVMCollectionViewManage : YVMListViewManage

@property (nonatomic, weak) YVMRefreshCollectionView *collectionView;

@property (nonatomic, copy) NSString *cellHeadClassName; /** cellHead类名 */

@property (nonatomic, assign) CGSize cellHeadSize; /**  */

@property (nonatomic, strong) NSObject *cellHeadVm;

@property (nonatomic, copy) NSString *cellFooterClassName; /** cellFooter类名 */

@property (nonatomic, assign) CGSize cellFooterSize; /**  */

@property (nonatomic, strong) NSObject *cellFooterVm;

@property (nonatomic, assign) UIEdgeInsets collectionInsets; /**<  */

/////////////////////////            ////////////////////////////

@property (nonatomic, copy) NSString *cellClassName; /** cell类名 */

@property (nonatomic, assign) CGSize cellSize; /**  */

@property (nonatomic, assign) BOOL isUseVmCellSize; /** 是否使用vm中控制的大小 */

@property (nonatomic, assign) BOOL isUseVmCellClassName; /** 是否使用vm中控制的类名 */

@property (nonatomic, copy) NSString *vmCellSizeName; /** vm控制cell大小对应的字段名 */

@property (nonatomic, copy) NSString *vmCellClassName; /** vm控制cell类名对应的字段名 */

/////////////////////////            ////////////////////////////

@property (nonatomic, copy) NSString *cellControlMethod; /**< cell点击委托规则名 */

@property (nonatomic, copy) NSArray *controlAddEventTags; /**< cell中哪些tag的view需要添加到点击方法 */

@property (nonatomic, copy) YVMCollectionCellControlHandler  YVMCollectionCellControlClick;

/////////////////////////            ////////////////////////////

@property (nonatomic, copy) YVMCollectionHandler YVMCollectionDidSelect;

@property (nonatomic, copy) YVMCollectionViewHandler YVMCollectionCellDraw;

@property (nonatomic, copy) YVMCollectionViewHandler YVMCollectionSectionHeaderDraw;

@property (nonatomic, copy) YVMCollectionViewHandler YVMCollectionSectionFooterDraw;

/////////////////////////            ////////////////////////////

@property (nonatomic, copy) YVMScrollHandler YVMScroll;

/////////////////////////            ////////////////////////////

- (YVMCollectionViewManage *)initBind:(YVMRefreshCollectionView *)table
                        cellClassName:(NSString *)cellClassName
                             interAPI:(NSString *)interAPI
                    parseListDictName:(NSString *)parseListDictName
                         objClassName:(NSString *)objClassName
                          vmClassName:(NSString *)vmClassName
                             cellSize:(CGSize)cellSize;

- (YVMCollectionViewManage *)initBind:(YVMRefreshCollectionView *)table
                        cellClassName:(NSString *)cellClassName
                         objClassName:(NSString *)objClassName
                          vmClassName:(NSString *)vmClassName
                             cellSize:(CGSize)cellSize;

- (void)bind;

@end

NS_ASSUME_NONNULL_END
