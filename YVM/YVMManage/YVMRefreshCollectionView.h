//
//  YVMRefreshCollectionView.h
//  YVM
//
//  Created by mac on 2019/12/25.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YVMCommon.h"

NS_ASSUME_NONNULL_BEGIN

@class YVMRefreshCollectionView;
@protocol YVMRefreshCollectionViewDelegate <NSObject>

@required
- (void)refreshCollectionView:(YVMRefreshCollectionView *)collectionView refreshType:(YVMRefreshType)refreshType;

@optional
- (void)clickRefreshCollectionView;

@end

@interface YVMRefreshCollectionView : UICollectionView

@property (nonatomic, weak) id<YVMRefreshCollectionViewDelegate> refreshDelegate;

- (instancetype)initWithFrame:(CGRect)frame
                       layout:(UICollectionViewLayout *)layout
                     viewType:(YVMCollectionType)viewType;

- (void)beginRefreshing;

- (void)endRefreshing;

- (BOOL)isRefreshing;

- (void)noMoreData;

- (void)scrollToBottom:(BOOL)animation;

- (void)setEmptyView:(UIView *)emptyView;

@end

NS_ASSUME_NONNULL_END
