//
//  YVMRefreshCollectionView.m
//  YVM
//
//  Created by mac on 2019/12/25.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import "YVMRefreshCollectionView.h"
#import "MJRefresh.h"

@interface YVMRefreshCollectionView () {
    UIView      *_emptyView;
}

@end

@implementation YVMRefreshCollectionView

- (instancetype)initWithFrame:(CGRect)frame
                       layout:(UICollectionViewLayout *)layout
                     viewType:(YVMCollectionType)viewType {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initSetting];
        
        switch (viewType) {
            case YVMCollectionType_None:
            {
                
            }
                break;
            case YVMCollectionType_Empty:
            {
                [self getEmptyView];
            }
                break;
            case YVMCollectionType_Refresh:
            {
                [self initHeaderRefresh];
            }
                break;
            case YVMCollectionType_More:
            {
                [self initFooterRefresh];
            }
                break;
            case YVMCollectionType_RefreshEmpty:
            {
                [self initHeaderRefresh];
                [self getEmptyView];
            }
                break;
            case YVMCollectionType_RefreshMore:
            {
                [self initHeaderRefresh];
                [self initFooterRefresh];
            }
                break;
            case YVMCollectionType_MoreEmpty:
            {
                [self getEmptyView];
                [self initFooterRefresh];
            }
                break;
            case YVMCollectionType_RefreshMoreEmpty:
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
    __weak typeof(self) weakself = self;
    self.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakself refreshDelegateWithType:YVMRefreshType_loadMore];
    }];
}

- (void)refreshDelegateWithType:(YVMRefreshType)type {
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(refreshCollectionView:refreshType:)]) {
        [_refreshDelegate refreshCollectionView:self refreshType:type];
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
        
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSInteger sectionNum = self.numberOfSections;
    BOOL isEmpty = YES;
    for (NSInteger i = 0; i < sectionNum; i++) {
        if ([self numberOfItemsInSection:i] != 0) {
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
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(clickRefreshCollectionView)]) {
        [_refreshDelegate clickRefreshCollectionView];
    }
}

- (void)scrollToBottom:(BOOL)animation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger sectionNum = self.numberOfSections;
        if (sectionNum > 0) {
            NSInteger row = [self numberOfItemsInSection:sectionNum - 1] - 1;
            if (row > 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sectionNum - 1];
                [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:animation];
            }
        }
    });
}


@end
