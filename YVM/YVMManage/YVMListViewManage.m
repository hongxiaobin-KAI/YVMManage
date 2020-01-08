//
//  YVMListViewManage.m
//  YVM
//
//  Created by mac on 2019/12/26.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import "YVMListViewManage.h"

#import <objc/message.h>

#import "YVMRequestManage.h"

@implementation YVMListViewManage

- (instancetype)init {
    self = [super init];
    if (self) {
        _listSectionArray = [[NSMutableArray alloc] init];
        [self defautSetting];
        _indexPage = self.firstPageIndex;
    }
    return self;
}

- (void)defautSetting {
    self.parsePageDictName = @"base_info";
    self.objParseMethodName = @"parseObjWithDict:";
    self.vmParseMethodName = @"initWithObj:";
    self.requestPageName = @"page";
    self.requestPageSizeName = @"limit";
    self.firstPageIndex = 1;
    self.pageSize = 10;
    
    self.pageObjClassName = @"WMPageObj";
    self.pageObjHasMoreName = @"is_more";
}

- (void)dealloc {
    [_listSectionArray removeAllObjects];
    _listSectionArray = nil;
    
    [self clear];
}

- (void)clear {
    [YVMRequestManage removeRequest:self];
}

- (void)clearAllData {
    [_listSectionArray removeAllObjects];
    
    [self reloadData];
}

#pragma mark - HTTPRequest   Analysis
/**
 请求总列表
 */
- (void)requestList {
    NSInteger indexPage = _indexPage;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[self.requestPageName] = @(indexPage);
    parameters[self.requestPageSizeName] = @(self.pageSize);
    
    if (self.addParam != nil && [self.addParam isKindOfClass:[NSDictionary class]]) {
        [parameters addEntriesFromDictionary:self.addParam];
    }
    
    @weakify(self)
    [YVMRequestManage addReq:self
                   interface:self.interAPI
                      params:parameters
               requestMethod:YVMRequestMethodPost
                    starting:^{
        @strongify(self)
        [self listStartWithPage:indexPage];
    }
                     success:^(BOOL isStatusSuccess, NSDictionary * _Nonnull responseDict) {
        @strongify(self)
        [self analysisList:responseDict indexPage:indexPage];
        [self endRefreshing];
    }
                     failure:^(YVMResponseStatus status, NSError * _Nonnull error) {
        @strongify(self)
        [self endRefreshing];
    }];
}

- (void)listStartWithPage:(NSInteger)indexPage {
    if ([YVMNetWorkConfig share].startListBlock) {
        [YVMNetWorkConfig share].startListBlock(indexPage);
    }
}

/**
 请求总列表  解析
 */
- (void)analysisList:(NSDictionary *)responseDict indexPage:(NSInteger)indexPage {
    NSDictionary *dealResponseDict = responseDict;
    
    if ([YVMNetWorkConfig share].finishListBlock) {
        dealResponseDict = [[YVMNetWorkConfig share].finishListBlock(indexPage, responseDict) copy];
    }
    
    [self parsePageObjDict:dealResponseDict];
    
    if (indexPage == self.firstPageIndex) {
        [_listSectionArray removeAllObjects];
        YVMListSectionManage *listSectionMange = [[YVMListSectionManage alloc] init];
        [_listSectionArray addObject:listSectionMange];
    }
    
    YVMListSectionManage *sectionManage = [_listSectionArray lastObject];
    NSIndexPath *beforeCountIndex = [NSIndexPath indexPathForRow:sectionManage.cellObjArray.count inSection:_listSectionArray.count];
    NSInteger sortIndex = 0;

    for (NSDictionary *dict in [dealResponseDict objectForKey:self.parseListDictName]) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            if (!self.moreSection) {
                if (indexPage == self.firstPageIndex) {
                    [self parseHeadFooterListSection:sectionManage dict:dict];
                }
                
                if ([self insertListSection:sectionManage cellObjDict:dict sortIndex:sortIndex cellObjDictFieldName:self.parseCellObjDictName]) {
                    sortIndex++;
                }
                
            } else {
                if (self.headObjSectionName.length) {
                    id sectionHeadObj = [self parseObjName:self.headObjClassName withDict:dict objParseMethodName:self.parseHeadObjDictName];
                    
                    if (sectionHeadObj) {
                        if (sectionManage.sectionHeadObj && ![[sectionManage.sectionHeadObj valueForKey:self.headObjSectionName] isEqual:[sectionHeadObj valueForKey:self.headObjSectionName]]) {
                            YVMListSectionManage *listSectionManage = [[YVMListSectionManage alloc] init];
                            [_listSectionArray addObject:listSectionManage];
                            sortIndex = 0;
                            sectionManage = listSectionManage;
                            
                            [self parseHeadFooterListSection:sectionManage dict:dict];
                        } else if (!sectionManage.sectionHeadObj) {
                            [self parseHeadFooterListSection:sectionManage dict:dict];
                        }
                    }
                    
                    if ([self insertListSection:sectionManage cellObjDict:dict sortIndex:sortIndex cellObjDictFieldName:self.parseCellObjDictName]) {
                        sortIndex++;
                    }
                }
            }
        }
    }
    
    NSIndexPath *afterCountIndex = [NSIndexPath indexPathForRow:sectionManage.cellObjArray.count inSection:_listSectionArray.count];
    
    if (self.YVMListLoadDataFinish) {
        self.YVMListLoadDataFinish(dealResponseDict, _listSectionArray, _indexPage);
    }
    
    [self reloadListViewIndexPageWithBeforeCountIndex:beforeCountIndex afterCountIndex:afterCountIndex];
}

- (void)parsePageObjDict:(NSDictionary *)dict {
    id parsePageObj;
    if (self.parsePageDictName.length) {
        parsePageObj = [self parseObjName:self.pageObjClassName withDict:[dict objectForKey:self.parsePageDictName]];
    } else {
        parsePageObj = [self parseObjName:self.pageObjClassName withDict:dict];
    }
    
    if (parsePageObj != nil) {
        NSString *hasMoreValue = [parsePageObj valueForKey:self.pageObjHasMoreName];
        if (self.pageNoMoreValue == hasMoreValue.integerValue) {
            [self listViewNoMoreData];
        } else {
            [self listViewHasMoreData];
        }
    }
}

- (void)parseHeadFooterListSection:(YVMListSectionManage *)sectionManage dict:(NSDictionary *)dict {
    //head
    if (self.headObjClassName.length) {
        sectionManage.sectionHeadObj = [self parseObjName:self.headObjClassName withDict:dict objParseMethodName:self.parseHeadObjDictName];
        sectionManage.sectionHeadVm = [self parseHeadFooterVmWithObj:sectionManage.sectionHeadObj vmClassName:self.headVmClassName];
    }
    
    //footer
    if (self.footerObjClassName.length) {
        sectionManage.sectionFooterObj = [self parseObjName:self.footerObjClassName withDict:dict objParseMethodName:self.parseFooterObjDictName];
        sectionManage.sectionFooterVm = [self parseHeadFooterVmWithObj:sectionManage.sectionFooterObj vmClassName:self.footerVmClassName];
    }
}

- (id)parseHeadFooterObjName:(NSString *)name dict:(NSDictionary *)dict dictFieldName:(NSString *)dictFieldName {
    id parseObj;
    if (dictFieldName.length) {
        parseObj = [self parseObjName:name withDict:[dict objectForKey:dictFieldName]];
    } else {
        parseObj = [self parseObjName:name withDict:dict];
    }
    return parseObj;
}

- (id)parseHeadFooterVmWithObj:(id)obj vmClassName:(NSString *)vmClassName {
    id parseVm;
    if (obj && vmClassName.length) {
        parseVm = [self parseVMWithObj:obj vmClassName:vmClassName];
    }
    return parseVm;
}

- (BOOL)insertListSection:(YVMListSectionManage *)sectionManage cellObjDict:(NSDictionary *)cellObjDict sortIndex:(NSInteger)sortIndex cellObjDictFieldName:(NSString *)cellObjDictFieldName {
    if (cellObjDictFieldName.length) {
        //cell
        NSArray *cellDictArray = [cellObjDict objectForKey:cellObjDictFieldName];
        if ([cellDictArray isKindOfClass:[NSArray class]]) {
            for (NSDictionary *cellObjDict in cellDictArray) {
                if ([cellObjDict isKindOfClass:[NSDictionary class]]) {
                    if ([self insertListSection:sectionManage cellObjDict:cellObjDict sortIndex:sortIndex]) {
                        return YES;
                    }
                }
            }
        }
        
    } else {
        if ([self insertListSection:sectionManage cellObjDict:cellObjDict sortIndex:sortIndex]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)insertListSection:(YVMListSectionManage *)sectionManage cellObjDict:(NSDictionary *)cellObjDict sortIndex:(NSInteger)sortIndex {
    id parseObj = [self parseObjName:self.objClassName withDict:cellObjDict];
    return [self insertListSection:sectionManage parseObj:parseObj sortIndex:sortIndex];
}

- (BOOL)insertListSection:(YVMListSectionManage *)sectionManage parseObj:(id)parseObj sortIndex:(NSInteger)sortIndex {
    if (parseObj != nil) {
        if (![self isFilterSameFieldWithListSection:sectionManage obj:parseObj] && ![self isFilterFieldDictWithObj:parseObj]) {
            if ([self arrayInsertParseVMWithListSection:sectionManage obj:parseObj sortIndex:sortIndex]) {
                return YES;
            }
        }
    }
    return NO;
}

- (id)parseObjName:(NSString *)name withDict:(NSDictionary *)dict {
    return [self parseObjName:name withDict:dict objParseMethodName:self.objParseMethodName];
}

- (id)parseObjName:(NSString *)name withDict:(NSDictionary *)dict objParseMethodName:(NSString *)objParseMethodName {
    if (name.length && [dict isKindOfClass:[NSDictionary class]] && objParseMethodName.length) {
        Class objClass = NSClassFromString(name);
        if (objClass != nil) {
            SEL objSelector = NSSelectorFromString(objParseMethodName);
            if ([objClass respondsToSelector:objSelector]) {
                id parseObj = ((id(*)(id, SEL, NSDictionary *))objc_msgSend)(objClass, objSelector, dict);
                if ([parseObj isKindOfClass:objClass]) {
                    return parseObj;
                }
            }
        }
    }
    return nil;
}

- (id)parseVMWithObj:(id)parseObj {
    return [self parseVMWithObj:parseObj vmClassName:self.vmClassName];
}

- (id)parseVMWithObj:(id)parseObj vmClassName:(NSString *)vmClassName {
    return [self parseVMWithObj:parseObj vmClassName:vmClassName vmParseMethodName:self.vmParseMethodName];
}

- (id)parseVMWithObj:(id)parseObj vmClassName:(NSString *)vmClassName vmParseMethodName:(NSString *)vmParseMethodName {
    if (parseObj && vmClassName.length && vmParseMethodName.length) {
        Class vmClass = NSClassFromString(vmClassName);
        if (vmClass != nil) {
            id vmClassAlloc = [vmClass alloc];
            SEL vmSelector = NSSelectorFromString(vmParseMethodName);
            if ([vmClassAlloc respondsToSelector:vmSelector]) {
                id parseVm = ((id(*)(id, SEL, id))objc_msgSend)(vmClassAlloc, vmSelector, parseObj);
                if ([parseVm isKindOfClass:vmClass]) {
                    return parseVm;
                }
            }
        }
    }
    return nil;
}

- (BOOL)arrayInsertParseVMWithListSection:(YVMListSectionManage *)listSection obj:(id)parseObj sortIndex:(NSInteger)sortIndex {
    id parseVm = [self parseVMWithObj:parseObj];
    if (parseVm != nil) {
        if (self.sortType == YVMListSortType_ASC) {
            [listSection.cellObjArray addObject:parseObj];
            [listSection.cellVmArray addObject:parseVm];
            return NO;
        } else if (self.sortType == YVMListSortType_DESC){
            [listSection.cellObjArray insertObject:parseObj atIndex:0];
            [listSection.cellVmArray insertObject:parseVm atIndex:0];
            return NO;
        } else if (self.sortType == YVMListSortType_Page_DESC) {
            [listSection.cellObjArray insertObject:parseObj atIndex:sortIndex];
            [listSection.cellVmArray insertObject:parseVm atIndex:sortIndex];
            return YES;
        }
    }
    return NO;
}

- (BOOL)isFilterFieldDictWithObj:(id)obj {
    if (self.filterFieldDict.count > 0) {
        NSArray *keyArray = [self.filterFieldDict allKeys];
        for (int i = 0; i < keyArray.count; i++) {
            NSString *filterFieldStr = keyArray[i];
            
            id objfieldValue = [self getFieldValue:filterFieldStr class:obj];
            if (objfieldValue) {
                id filterFieldValue = self.filterFieldDict[filterFieldStr];
                if ([filterFieldValue isKindOfClass:[NSArray class]]) {
                    NSArray *filterFieldValueArray = (NSArray *)filterFieldValue;
                    for (id value in filterFieldValueArray) {
                        if ([value isEqual:objfieldValue]) {
                            return YES;
                        }
                    }
                    
                } else if ([filterFieldValue isKindOfClass:[NSString class]]) {
//                    NSString *filterFieldValueStr = (NSString *)filterFieldValue;
                    //正则表达式 暂不做处理
                }
            }
        }
    }
    return NO;
}

- (NSString *)getStrWithValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    } else if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return @"";
}

- (BOOL)isFilterSameFieldWithListSection:(YVMListSectionManage *)listSection obj:(id)obj {
    if (self.filterSameFieldArray.count > 0) {
        for (id contrastObj in listSection.cellObjArray) {
            for (int i = 0; i < self.filterSameFieldArray.count; i++) {
                NSString *fieldStr = self.filterSameFieldArray[i];
                
                id objFieldValue = [self getFieldValue:fieldStr class:obj];
                id contrastObjFieldValue  = [self getFieldValue:fieldStr class:contrastObj];
                if (![objFieldValue isEqual:contrastObjFieldValue]) {
                    break;
                } else if (i == self.filterSameFieldArray.count - 1) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (id)getFieldValue:(NSString *)fieldStr class:(id)class {
    if ([self hasField:fieldStr class:class]) {
        return [class valueForKey:fieldStr];
    }
    return nil;
}

- (BOOL)hasField:(NSString *)fieldStr class:(id)class {
    if (!fieldStr) {
        return NO;
    }
    SEL fieldSelector = NSSelectorFromString(fieldStr);
    return [class respondsToSelector:fieldSelector];
}

- (BOOL)isValidateRegularExpression:(NSString *)strDestination byExpression:(NSString *)strExpression {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strExpression];
    return [predicate evaluateWithObject:strDestination];
}

#pragma mark - Custom(Public)
- (void)reloadNewData {
    _indexPage = self.firstPageIndex;
    [self loadData];
}

- (void)loadData {
    if (self.requestType == YVMListRequestType_APIRequest) {
        [self requestList];
        
    } else if (self.requestType == YVMListRequestType_LoadLocal) {
        [self loadLocalData];
    }
}

- (void)loadLocalDataWithObjArray:(NSArray *)array {
    if ([[array firstObject] isKindOfClass:[YVMListSectionManage class]]) {
        [self parseVmWithSectionManageArray:array];
    } else {
        [self parseVmWithObjArray:array];
    }
    
    [self reloadData];
}

- (void)loadLocalData {
    NSMutableArray *objArray = [NSMutableArray array];
    if (self.YVMListLoadData) {
        [objArray addObjectsFromArray:self.YVMListLoadData(_indexPage, self.sortType)];
    }
    if (objArray.count == 0) {
        [self endRefreshing];
        return;
    }
    
    YVMListSectionManage *sectionManage = [_listSectionArray lastObject];
    NSIndexPath *beforeCountIndex = [NSIndexPath indexPathForRow:sectionManage.cellObjArray.count inSection:_listSectionArray.count];
    if ([[objArray firstObject] isKindOfClass:[YVMListSectionManage class]]) {
        [self parseVmWithSectionManageArray:objArray];
    } else {
        [self parseVmWithObjArray:objArray];
    }
    sectionManage = [_listSectionArray lastObject];
    NSIndexPath *afterCountIndex = [NSIndexPath indexPathForRow:sectionManage.cellObjArray.count inSection:_listSectionArray.count];
    
    [self reloadListViewIndexPageWithBeforeCountIndex:beforeCountIndex afterCountIndex:afterCountIndex];
    [self endRefreshing];
}

- (void)parseVmWithSectionManageArray:(NSArray *)sectionManageArray {
    for (YVMListSectionManage *sectionManage in sectionManageArray) {
        YVMListSectionManage *findManage;
        if (self.headObjSectionName.length) {
            id headObjSectionValue = [sectionManage valueForKey:self.headObjSectionName];
            for (YVMListSectionManage *compareSectionManage in sectionManageArray) {
                if ([headObjSectionValue isEqual:[compareSectionManage valueForKey:self.headObjSectionName]]) {
                    findManage = compareSectionManage;
                    break;
                }
            }
        }
        if (findManage) {
            NSInteger sortIndex = 0;
            for (id parseObj in sectionManage.cellObjArray) {
                if ([self insertListSection:findManage parseObj:parseObj sortIndex:sortIndex]) {
                    sortIndex++;
                }
            }
            
        } else {
            [_listSectionArray addObject:sectionManage];
            for (id parseObj in sectionManage.cellObjArray) {
                Class objClass = NSClassFromString(self.objClassName);
                if (objClass != nil) {
                    if ([parseObj isKindOfClass:objClass] && parseObj != nil) {
                        if (![self isFilterSameFieldWithListSection:sectionManage obj:parseObj] && ![self isFilterFieldDictWithObj:parseObj]) {
                            id parseVm = [self parseVMWithObj:parseObj];
                            if (parseVm != nil) {
                                [sectionManage.cellVmArray addObject:parseVm];
                            }
                        } else {
                            [sectionManage.cellObjArray removeObject:parseObj];
                        }
                    }
                }
            }
        }
        
        
    }
}

- (void)parseVmWithObjArray:(NSArray *)objArray {
    YVMListSectionManage *sectionManage = [_listSectionArray lastObject];
    NSInteger sortIndex = 0;
    for (id parseObj in objArray) {
        Class objClass = NSClassFromString(self.objClassName);
        if (objClass != nil) {
            if ([parseObj isKindOfClass:objClass] && parseObj != nil) {
                if (![self isFilterSameFieldWithListSection:sectionManage obj:parseObj] && ![self isFilterFieldDictWithObj:parseObj]) {
                    if ([self arrayInsertParseVMWithListSection:sectionManage obj:parseObj sortIndex:sortIndex]) {
                        sortIndex++;
                    }
                }
            }
        }
    }
}

- (void)reloadListViewIndexPageWithBeforeCountIndex:(NSIndexPath *)beforeCountIndex afterCountIndex:(NSIndexPath *)afterCountIndex {
    if ([beforeCountIndex compare:afterCountIndex] != NSOrderedSame) {
        @weakify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
//            [self reloadListViewLocation:afterCount - beforeCount pageIndex:self->_indexPage];
            self->_indexPage++;
        });
    } else if (_indexPage == self.firstPageIndex) {
        [self reloadData];
    }
}

- (void)endRefreshing {
    
}

- (void)listViewNoMoreData {
    
}

- (void)listViewHasMoreData {
    
}

- (void)reloadListViewLocation:(NSInteger)index section:(NSInteger)section pageIndex:(NSInteger)pageIndex {

}

- (void)reloadData {
    
}

- (void)deleteCellWithIndexPath:(NSIndexPath *)indexPath {
    
}

@end
