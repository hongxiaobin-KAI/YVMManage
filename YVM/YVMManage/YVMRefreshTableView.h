//
//  YVMRefreshTableView.h
//  YVM
//
//  Created by mac on 2019/12/25.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YVMCommon.h"

NS_ASSUME_NONNULL_BEGIN

@class YVMRefreshTableView;
@protocol YVMRefreshTableViewDelegate <NSObject>

@required
- (void)refreshTableView:(YVMRefreshTableView *)refreshTableView refreshType:(YVMRefreshType)refreshType;

@optional
- (void)clickRefreshTableView;

@end

@interface YVMRefreshTableView : UITableView

@property (nonatomic, weak) id<YVMRefreshTableViewDelegate> refreshDelegate;

- (instancetype)initWithFrame:(CGRect)frame viewType:(YVMTableType)viewType;

- (void)beginRefreshing;

- (void)endRefreshing;

- (BOOL)isRefreshing;

- (void)noMoreData;

- (void)reloadFooter;

- (void)scrollToBottom:(BOOL)animation;

- (void)setEmptyView:(UIView *)emptyView;

@end

NS_ASSUME_NONNULL_END
