//
//  YVMRefreshTableView.m
//  YVM
//
//  Created by mac on 2019/12/25.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import "YVMRefreshTableView.h"
#import "MJRefresh.h"

@interface YVMRefreshTableView () {
    UIView      *_emptyView;
    UIView      *_footerNoMoreView;
}

@end

@implementation YVMRefreshTableView

- (instancetype)initWithFrame:(CGRect)frame viewType:(YVMTableType)viewType {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSetting];
        
        switch (viewType) {
            case YVMTableType_None:
            {
                
            }
                break;
            case YVMTableType_Empty:
            {
                [self getEmptyView];
            }
                break;
            case YVMTableType_Refresh:
            {
                [self initHeaderRefresh];
            }
                break;
            case YVMTableType_More:
            {
                [self initFooterRefresh];
            }
                break;
            case YVMTableType_RefreshEmpty:
            {
                [self initHeaderRefresh];
                [self getEmptyView];
            }
                break;
            case YVMTableType_RefreshMore:
            {
                [self initHeaderRefresh];
                [self initFooterRefresh];
            }
                break;
            case YVMTableType_MoreEmpty:
            {
                [self getEmptyView];
                [self initFooterRefresh];
            }
                break;
            case YVMTableType_RefreshMoreEmpty:
            {
                [self initHeaderRefresh];
                [self getEmptyView];
                [self initFooterRefresh];
            }
                break;
            default:
                break;
        }
    }
    
    return self;
}

- (void)initSetting {
    self.estimatedRowHeight = 0;
    self.estimatedSectionFooterHeight = 0;
    self.estimatedSectionHeaderHeight = 0;
    
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        
    }
}

- (void)setEmptyView:(UIView *)emptyView {
    if (_emptyView) {
        [_emptyView removeFromSuperview];
        _emptyView = nil;
    }
    if (emptyView) {
        _emptyView = emptyView;
        [self addSubview:_emptyView];
    }
}

- (void)initHeaderRefresh {
    __weak typeof(self) weakself = self;
    self.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakself refreshDelegateWithType:YVMRefreshType_loadNew];
    }];
}

- (void)initFooterRefresh {
    // 上拉刷新
    __weak typeof(self) weakself = self;
    self.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakself refreshDelegateWithType:YVMRefreshType_loadMore];
    }];
}

- (UIView *)customNoMoreView {
    if (!_footerNoMoreView) {
        CGRect footerNoMoreViewRect = CGRectMake(0, 0, UI_SCREEN_WIDTH, MJRefreshFooterHeight);
        _footerNoMoreView = [[UIView alloc] initWithFrame:footerNoMoreViewRect];
        [_footerNoMoreView setBackgroundColor:[UIColor clearColor]];
        
        CGRect labelRect = CGRectMake(0, 0, UI_SCREEN_WIDTH, MJRefreshFooterHeight);
        UILabel *textLabel = [[UILabel alloc] initWithFrame:labelRect];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setText:@"已经到底啦"];
        [textLabel setTextAlignment:NSTextAlignmentCenter];
        [textLabel setFont:MJRefreshLabelFont];
        [textLabel setTextColor:MJRefreshLabelTextColor];
        [_footerNoMoreView addSubview:textLabel];
    }
    return _footerNoMoreView;
}

- (void)refreshDelegateWithType:(YVMRefreshType)type {
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(refreshTableView:refreshType:)]) {
        if (type == YVMRefreshType_loadNew) {
            [self.mj_footer setHidden:NO];
            if (self.mj_footer && [self.tableFooterView isKindOfClass:[UILabel class]]) {
                self.tableFooterView = nil;
            }
        }
        [_refreshDelegate refreshTableView:self refreshType:type];
    }
}

- (void)beginRefreshing {
    if (self.mj_header.state == MJRefreshStateRefreshing) {
        [self endRefreshing];
    }
    if (self.mj_header.state == MJRefreshStateIdle) {
        [self.mj_header beginRefreshing];
    }
}

- (void)endRefreshing {
    if (self.mj_header.state == MJRefreshStateRefreshing) {
        [self.mj_header endRefreshing];
    }
    if (self.mj_footer.state == MJRefreshStateRefreshing) {
        [self.mj_footer endRefreshing];
    }
}

- (BOOL)isRefreshing {
    return self.mj_header.state == MJRefreshStateRefreshing;
}

- (void)noMoreData {
    [self.mj_footer endRefreshingWithNoMoreData];
    [self.mj_footer setHidden:YES];
    if (self.mj_footer) {
        NSInteger row = [self numberOfRowsInSection:0];
        CGFloat cellHeight = 0.0f;
        if(row > 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
                cellHeight = [self.delegate tableView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
        }
        if (row * cellHeight > self.mj_size.height && self.tableFooterView == nil) {
            self.tableFooterView = [self customNoMoreView];
        }
    }
}

- (void)reloadFooter {
    [self.mj_footer setHidden:NO];
    self.tableFooterView = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSInteger sectionNum = self.numberOfSections;
    BOOL isEmpty = YES;
    for (NSInteger i = 0; i < sectionNum; i++) {
        if ([self numberOfRowsInSection:i] != 0) {
            isEmpty = NO;
            break;
        }
    }
    [[self getEmptyView] setHidden:isEmpty];
}

- (UIView *)getEmptyView {
    if (!_emptyView) {
        CGRect emptyViewRect = CGRectMake(0, self.mj_size.height - 100, UI_SCREEN_WIDTH, 100);
        _emptyView = [[UIView alloc] initWithFrame:emptyViewRect];
        [_emptyView setBackgroundColor:[UIColor clearColor]];
        
        CGRect labelRect = CGRectMake(0, 0, UI_SCREEN_WIDTH, _emptyView.mj_size.height);
        UILabel *textLabel = [[UILabel alloc] initWithFrame:labelRect];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setText:@"这里什么都没有"];
        [textLabel setTextAlignment:NSTextAlignmentCenter];
        [textLabel setFont:[UIFont systemFontOfSize:14]];
        [textLabel setTextColor:MJRefreshLabelTextColor];
        [_emptyView addSubview:textLabel];
        
        [self addSubview:_emptyView];
    }
    
    return _emptyView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(clickRefreshTableView)]) {
        [_refreshDelegate clickRefreshTableView];
    }
}

- (void)scrollToBottom:(BOOL)animation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger sectionNum = self.numberOfSections;
        if (sectionNum > 0) {
            NSInteger row = [self numberOfRowsInSection:sectionNum - 1] - 1;
            if (row > 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sectionNum - 1];
                [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animation];
            }
        }
    });
}

@end
