//
//  YVMTableViewManage.m
//  YVM
//
//  Created by mac on 2020/1/7.
//  Copyright © 2020 Xiaobin Hong. All rights reserved.
//

#import "YVMTableViewManage.h"

#import "YVMRefreshTableView.h"

#import "YVMControlConfig.h"
#import "YVMManage.h"

#import "NSObject+YVM.h"

#import <objc/message.h>

@interface YVMTableViewManage () <UITableViewDelegate, UITableViewDataSource, YVMRefreshTableViewDelegate, UIScrollViewDelegate> {
    
}

@end

@implementation YVMTableViewManage

- (YVMTableViewManage *)initBind:(YVMRefreshTableView *)table
                   cellClassName:(NSString *)cellClassName
                        interAPI:(NSString *)interAPI
               parseListDictName:(NSString *)parseListDictName
                         objClassName:(NSString *)objClassName
                          vmClassName:(NSString *)vmClassName
                      cellHeight:(CGFloat)cellHeight {
    self = [self initBind:table
            cellClassName:cellClassName
             objClassName:objClassName
              vmClassName:vmClassName
               cellHeight:cellHeight];
    if (self) {
        self.interAPI = interAPI;
        self.parseListDictName = parseListDictName;
        self.requestType = YVMListRequestType_APIRequest;
    }
    return self;
}

- (YVMTableViewManage *)initBind:(YVMRefreshTableView *)table
                   cellClassName:(NSString *)cellClassName
                    objClassName:(NSString *)objClassName
                     vmClassName:(NSString *)vmClassName
                      cellHeight:(CGFloat)cellHeight {
    self = [super init];
    if (self) {
        self.tableView = table;
        self.cellClassName = cellClassName;
        self.objClassName = objClassName;
        self.vmClassName = vmClassName;
        self.cellHeight = cellHeight;
        
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
    self.tableView = nil;
}

- (void)bind {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
}

- (void)clear {
    [super clear];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.tableView.refreshDelegate = nil;
}

#pragma mark UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.listSectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    YVMListSectionManage *sectionManage = self.listSectionArray[section];
    return sectionManage.cellObjArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger index = indexPath.row;
    
    NSString *useClassName = @"";
    YVMListSectionManage *sectionManage = self.listSectionArray[section];
    if (self.isUseVmCellClassName && self.vmCellClassName.length > 0) {
        id vm = sectionManage.cellVmArray[index];
        useClassName = [vm valueForKey:self.vmCellClassName];
        vm = nil;
        
    } else if (self.cellClassName.length > 0) {
        useClassName = self.cellClassName;
        
    }
    if (useClassName.length == 0) {
        useClassName = @"UITableViewCell";
    }
    
    NSString *identifier = useClassName;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        Class cellClass = NSClassFromString(useClassName);
        if (cellClass != nil) {
            cell = [[cellClass alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            return [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:identifier];
        }
        
    }
    
    id vm = sectionManage.cellVmArray[index];
    [YVMManage fillView:cell model:vm];
    [self tableCellAddEvent:cell indexPath:indexPath];
    if (self.YVMTableCellDraw) {
        id obj = sectionManage.cellObjArray[index];
        self.YVMTableCellDraw(obj, vm, cell, indexPath);
        
        obj = nil;
        vm = nil;
    }
    
    useClassName = nil;
    identifier = nil;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger index = indexPath.row;
    YVMListSectionManage *sectionManage = self.listSectionArray[section];
    
    if (self.isUseVmCellHeight) {
        id vm = sectionManage.cellVmArray[index];
        
        NSString *cellHeightStr = @"0";
        if (self.vmCellHeightName == nil) {
            cellHeightStr = [vm valueForKey:@"cellHeight"];
        } else {
            cellHeightStr = [vm valueForKey:self.vmCellHeightName];
        }
        
        if ([cellHeightStr isKindOfClass:[NSString class]]) {
            return cellHeightStr.integerValue;
        } else if ([cellHeightStr isKindOfClass:[NSNumber class]]){
            return cellHeightStr.integerValue;
        }
        
        vm = nil;
        cellHeightStr = nil;
        
        return 0;
    }
    return self.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.YVMTableDidSelect) {
        NSInteger section = indexPath.section;
        NSInteger index = indexPath.row;
        
        YVMListSectionManage *sectionManage = self.listSectionArray[section];
        if (index < sectionManage.cellObjArray.count) {
            id selObj = sectionManage.cellObjArray[index];
            id selVm = sectionManage.cellVmArray[index];
            self.YVMTableDidSelect(selObj, selVm, indexPath);
            
            selObj = nil;
            selVm = nil;
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
        {
            if (self.YVMTableDidDelete) {
                NSInteger section = indexPath.section;
                NSInteger index = indexPath.row;
                YVMListSectionManage *sectionManage = self.listSectionArray[section];
                
                if (index < sectionManage.cellObjArray.count) {
                    id selObj = sectionManage.cellObjArray[index];
                    id selVm = sectionManage.cellVmArray[index];
                    self.YVMTableDidDelete(selObj, selVm, indexPath);
                    
                    selObj = nil;
                    selVm = nil;
                }
            }
        }
            break;
            
        default:
            break;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isUseCellDelete) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

#pragma mark Table Header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat sectionHeadHeight = 0;
    if (self.YVMSectionHeadViewDrawHeight) {
        sectionHeadHeight = self.YVMSectionHeadViewDrawHeight(section);
    }
    return sectionHeadHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionHeader;
    if (self.YVMSectionHeadViewDraw) {
        sectionHeader = self.YVMSectionHeadViewDraw(section);
    }
    
    if (!sectionHeader) {
        sectionHeader = [[UIView alloc] init];
    }
    
    return sectionHeader;
}


#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.YVMDidScroll) {
        self.YVMDidScroll(CGPointZero,CGPointZero,CGPointZero);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.YVMScroll) {
        self.YVMScroll(scrollView.contentOffset, velocity, *targetContentOffset);
    }
}

#pragma mark RefreshTableViewDelegate
- (void)refreshTableView:(YVMRefreshTableView *)refreshTableView refreshType:(YVMRefreshType)refreshType {
    if (refreshType == YVMRefreshType_loadNew && self.sortType == YVMListSortType_ASC) {
        self.indexPage = self.firstPageIndex;
    }
    
    if (refreshType == YVMRefreshType_loadNew) {
        if (self.YVMRefreshNew) {
            self.YVMRefreshNew();
        }
    } else if (refreshType == YVMRefreshType_loadMore) {
        if (self.YVMRefreshMore) {
            self.YVMRefreshMore();
        }
    }
    
    [self loadData];
}

#pragma mark Custom(Override)
- (void)endRefreshing {
    [_tableView endRefreshing];
}

- (void)listViewNoMoreData {
    [_tableView noMoreData];
}

- (void)listViewHasMoreData {
    [_tableView reloadFooter];
}

- (void)reloadListViewLocation:(NSInteger)index pageIndex:(NSInteger)pageIndex {
    [self reloadData];
    
    if (self.sortType == YVMListSortType_DESC) {
        [_tableView layoutIfNeeded];
        
        if (pageIndex == self.firstPageIndex && index > 0) {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0]  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        } else if (index > 0){
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop  animated:NO];
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    } else if (self.sortType == YVMListSortType_Page_DESC) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop  animated:NO];
    }
}

- (void)reloadData {
    [_tableView reloadData];
}

- (void)deleteCellWithIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger index = indexPath.row;
    YVMListSectionManage *sectionManage = self.listSectionArray[section];
    
    [sectionManage.cellObjArray removeObjectAtIndex:index];
    [sectionManage.cellVmArray removeObjectAtIndex:index];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark Custom(Action)
- (void)clickControl:(UIControl *)control {
    if (self.YVMTableCellControlClick) {
        NSInteger row = control.yvmIndex.integerValue;
        NSInteger section = control.yvmSection.integerValue;
        NSInteger tag = control.yvmType.integerValue;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        YVMListSectionManage *sectionManage = self.listSectionArray[section];
        
        if (row < sectionManage.cellObjArray.count) {
            id selObj = sectionManage.cellObjArray[row];
            id selVm = sectionManage.cellVmArray[row];
            self.YVMTableCellControlClick(selObj, selVm, control, indexPath, tag);
            
            selObj = nil;
            selVm = nil;
        }
    }
}

#pragma mark Custom(Private)
- (void)tableCellAddEvent:(id)cell indexPath:(NSIndexPath *)indexPath {
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
        config = nil;
    }
}

@end
