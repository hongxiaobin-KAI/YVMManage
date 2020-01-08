//
//  YVMCollectionViewManage.m
//  YVM
//
//  Created by mac on 2020/1/7.
//  Copyright © 2020 Xiaobin Hong. All rights reserved.
//

#import "YVMCollectionViewManage.h"

#import "YVMRefreshCollectionView.h"

#import "YVMControlConfig.h"

#import "NSObject+YVM.h"
#import "YVMManage.h"

#import <objc/message.h>

@interface YVMCollectionViewManage () <UICollectionViewDelegateFlowLayout, YVMRefreshCollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate> {
    NSMutableArray    *_tempClassArray;
}

@end

@implementation YVMCollectionViewManage

- (YVMCollectionViewManage *)initBind:(YVMRefreshCollectionView *)table
                        cellClassName:(NSString *)cellClassName
                             interAPI:(NSString *)interAPI
                    parseListDictName:(NSString *)parseListDictName
                         objClassName:(NSString *)objClassName
                          vmClassName:(NSString *)vmClassName
                             cellSize:(CGSize)cellSize {
    self = [self initBind:table
            cellClassName:cellClassName
             objClassName:objClassName
              vmClassName:vmClassName
                 cellSize:cellSize];
    if (self) {
        self.interAPI = interAPI;
        self.parseListDictName = parseListDictName;
        self.requestType = YVMListRequestType_APIRequest;
    }
    return self;
}

- (YVMCollectionViewManage *)initBind:(YVMRefreshCollectionView *)table
                        cellClassName:(NSString *)cellClassName
                         objClassName:(NSString *)objClassName
                          vmClassName:(NSString *)vmClassName
                             cellSize:(CGSize)cellSize {
    self = [super init];
    if (self) {
        self.collectionView = table;
        self.cellClassName = cellClassName;
        self.objClassName = objClassName;
        self.vmClassName = vmClassName;
        self.cellSize = cellSize;
        
        _tempClassArray = [[NSMutableArray alloc] init];
        
        if (self.cellClassName.length > 0) {
            Class cellClass = NSClassFromString(self.cellClassName);
            [_collectionView registerClass:cellClass forCellWithReuseIdentifier:self.cellClassName];
            
            if (self.cellClassName.length) {
                [_tempClassArray addObject:self.cellClassName];
            }
        }
        
        [self bind];
        [self yVMTableDefaut];
    }
    return self;
}

- (void)yVMTableDefaut {
    self.cellControlMethod = @"addControlConfig:";
}

- (void)dealloc {
    [self clear];
    self.collectionView = nil;
}

- (void)bind {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.refreshDelegate = self;
}

- (void)clear {
    [super clear];
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    self.collectionView.refreshDelegate = nil;
}

- (void)setCellHeadClassName:(NSString *)cellHeadClassName {
    if (![_cellHeadClassName isEqualToString:cellHeadClassName]) {
        _cellHeadClassName = [cellHeadClassName copy];
        [self.collectionView registerClass:NSClassFromString(_cellHeadClassName) forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:_cellHeadClassName];
    }
}

- (void)setCellFooterClassName:(NSString *)cellFooterClassName {
    if (![_cellFooterClassName isEqualToString:cellFooterClassName]) {
        _cellFooterClassName = [cellFooterClassName copy];
        [self.collectionView registerClass:NSClassFromString(_cellFooterClassName) forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_cellFooterClassName];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.YVMScroll) {
        self.YVMScroll(scrollView.contentOffset, velocity, *targetContentOffset);
    }
}

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.listSectionArray.count;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    YVMListSectionManage *sectionManage = self.listSectionArray[section];
    return sectionManage.cellObjArray.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSCAssert(self.cellHeadClassName != nil, @"has cellHeadSize must use cellHeadClassName");
        if (self.cellHeadClassName != nil) {
            UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:self.cellHeadClassName forIndexPath:indexPath];
            NSCAssert(headerView != nil, @"cellHeadClassName must register and exist");
            
            [YVMManage fillView:headerView model:self.cellHeadVm];
            if (self.YVMCollectionSectionHeaderDraw) {
                self.YVMCollectionSectionHeaderDraw(nil, self.cellHeadVm, headerView, indexPath);
            }
            
            return headerView;
        } else {
            return nil;
        }
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        NSCAssert(self.cellFooterClassName != nil, @"has cellFooterSize must use cellFooterClassName");
        if (self.cellFooterClassName != nil) {
            UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:self.cellFooterClassName forIndexPath:indexPath];
            NSCAssert(footerView != nil, @"cellFooterClassName must register and exist");
            
            [YVMManage fillView:footerView model:self.cellFooterVm];
            if (self.YVMCollectionSectionFooterDraw) {
                self.YVMCollectionSectionFooterDraw(nil, self.cellFooterVm, footerView, indexPath);
            }
            
            return footerView;
        } else {
            return [[UICollectionReusableView alloc] init];
        }
    }
    
    return [[UICollectionReusableView alloc] init];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger index = indexPath.row;
    
    YVMListSectionManage *sectionManage = self.listSectionArray[section];
    if (self.isUseVmCellClassName && self.vmCellClassName.length > 0) {
        id vm = sectionManage.cellVmArray[index];
        NSString *cellClassString = [vm valueForKey:self.vmCellClassName];
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellClassString forIndexPath:indexPath];
        if (cell) {
            [YVMManage fillView:cell model:vm];
            if (self.YVMCollectionCellDraw) {
                id obj = sectionManage.cellObjArray[index];
                self.YVMCollectionCellDraw(obj, vm, cell, indexPath);
            }
            return cell;
        }
        return [[UICollectionViewCell alloc] init];
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellClassName forIndexPath:indexPath];
        id vm = sectionManage.cellVmArray[index];
        [YVMManage fillView:cell model:vm];
        if (self.YVMCollectionCellDraw) {
            id obj = sectionManage.cellObjArray[index];
            self.YVMCollectionCellDraw(obj, vm, cell, indexPath);
        }
        return cell;
    }
}

#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.YVMCollectionDidSelect) {
        NSInteger section = indexPath.section;
        NSInteger index = indexPath.row;
        YVMListSectionManage *sectionManage = self.listSectionArray[section];
        
        if (index < sectionManage.cellObjArray.count) {
            id selObj = sectionManage.cellObjArray[index];
            id selVm = sectionManage.cellVmArray[index];
            self.YVMCollectionDidSelect(selObj, selVm, indexPath);
        }
    }
}

#pragma mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isUseVmCellSize) {
        if (self.vmCellSizeName.length > 0) {
            NSInteger section = indexPath.section;
            NSInteger index = indexPath.row;
            YVMListSectionManage *sectionManage = self.listSectionArray[section];
            
            id vm = sectionManage.cellVmArray[index];
            CGSize cellSize = [[vm valueForKey:self.vmCellSizeName] CGSizeValue];
            return cellSize;
        } else {
            return self.cellSize;
        }
        return CGSizeZero;
    } else {
        if (!CGSizeEqualToSize(self.cellSize, CGSizeZero)) {
            return self.cellSize;
        }
        return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (!CGSizeEqualToSize(self.cellHeadSize, CGSizeZero)) {
        return self.cellHeadSize;
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (!CGSizeEqualToSize(self.cellFooterSize, CGSizeZero)) {
        return self.cellHeadSize;
    }
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return self.collectionInsets;
}

#pragma mark RefreshCollectionViewDelegate
- (void)refreshCollectionView:(YVMRefreshCollectionView *)collectionView refreshType:(YVMRefreshType)refreshType {
    if (refreshType == YVMRefreshType_loadNew && self.sortType == YVMListSortType_ASC) {
        self.indexPage = self.firstPageIndex;
    }
    [self loadData];
}

#pragma mark Custom(Override)
- (void)endRefreshing {
    [_collectionView endRefreshing];
}

- (void)listViewNoMoreData {
    [_collectionView noMoreData];
}

- (void)reloadListViewLocation:(NSInteger)index pageIndex:(NSInteger)pageIndex {
    [self reloadData];
    
    if (self.sortType == YVMListSortType_DESC) {
        [_collectionView layoutIfNeeded];
        
        if (pageIndex == self.firstPageIndex && index > 0) {
//            [_collectionView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0]  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        } else if (index > 0){
//            [_collectionView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop  animated:NO];
//            [_collectionView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    } else if (self.sortType == YVMListSortType_Page_DESC) {
//        [_collectionView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop  animated:NO];
    }
}

- (void)reloadData {
    [CATransaction setDisableActions:YES];
    if (self.isUseVmCellClassName && self.vmCellClassName.length) {
        for (NSInteger section = 0; section < self.listSectionArray.count; section++) {
            YVMListSectionManage *sectionManage = self.listSectionArray[section];
            for (NSObject *vm in sectionManage.cellVmArray) {
               NSString *cellClassString = [vm valueForKey:self.vmCellClassName];
                if (![_tempClassArray containsObject:cellClassString] && cellClassString.length) {
                    [_tempClassArray addObject:cellClassString];
                    Class cellClass = NSClassFromString(cellClassString);
                    [_collectionView registerClass:cellClass forCellWithReuseIdentifier:cellClassString];
                }
            }
        }
    }
    [_collectionView reloadData];
    [CATransaction commit];
}

#pragma mark Custom(Action)
- (void)clickControl:(UIControl *)control {
    if (self.YVMCollectionCellControlClick) {
        NSInteger section = control.yvmSection.integerValue;
        NSInteger index = control.yvmIndex.integerValue;
        NSInteger tag = control.yvmType.integerValue;
        YVMListSectionManage *sectionManage = self.listSectionArray[section];
        
        id selObj = sectionManage.cellObjArray[index];
        id selVm = sectionManage.cellVmArray[index];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:section];
        self.YVMCollectionCellControlClick(selObj, selVm, control, indexPath, tag);
    }
}

#pragma mark Custom(Private)
- (void)collectCellAddEvent:(id)cell indexPath:(NSIndexPath *)indexPath {
    for (NSString *tag in self.controlAddEventTags) {
        YVMControlConfig *config = [[YVMControlConfig alloc] init];
        config.indexRow = indexPath.row;
        config.section = indexPath.section;
        config.type = tag;
        config.target = self;
        config.event = UIControlEventTouchUpInside;
        config.methodName = @"clickControl:";
        
        SEL cellMethod = NSSelectorFromString(self.cellControlMethod);
        if ([cell respondsToSelector:cellMethod]) {
            ((void(*)(id, SEL, id))objc_msgSend)(cell, cellMethod, config);
        }
    }
}

@end
