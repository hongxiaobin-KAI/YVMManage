//
//  YVMTestTableViewController.m
//  YVM
//
//  Created by mac on 2020/1/8.
//  Copyright © 2020 Xiaobin Hong. All rights reserved.
//

#import "YVMTestTableViewController.h"

#import "YVMRefreshTableView.h"

#import "YVMListViewManage.h"

#import "YVMCommon.h"

@interface YVMTestTableViewController () {
    YVMRefreshTableView      *_refreshTableView;
    
    
    YVMListViewManage        *_listManage;
}

@end

@implementation YVMTestTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)initTable {
    CGRect refreshTableViewRect = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
    _refreshTableView = [[YVMRefreshTableView alloc] initWithFrame:refreshTableViewRect viewType:YVMTableType_RefreshMoreEmpty];
    [_refreshTableView setBackgroundColor:[UIColor whiteColor]];
    [_refreshTableView setClipsToBounds:YES];
    _refreshTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_refreshTableView];
}

- (void)bindListManage {
    _listManage = [[YVMListViewManage alloc] init];
    _listManage.interAPI = @"1.7.0/dispatch.php";
    _listManage.addParam = @{@"v_class" : @"400" ,@"v_cmd" : @"406", @"shareContent" : @"3db88f97ed3d734b35b12af1a9a5a50d", @"did" : @"f3bca17996cfaa1ec15b9866e8200eee", @"channel_id" : @"88888888", @"bundle_id" : @"com.honglajiao.www", @"e_market_signature" : @"app store", @"userid" : @"132533", @"token_id" : @"3c6dee8ac12f5e5ecd4612dfd8dcf83e"};
    _listManage.requestType = YVMListRequestType_APIRequest;
    _listManage.parseListDictName = @"disburse_info";
    _listManage.pageObjClassName = @"YVMTestPageObj";
    _listManage.parsePageDictName = @"base_info";
    _listManage.objClassName = @"YVMTestIncomeObj";
    _listManage.vmClassName = @"YVMTestIncomeTableCellModel";
    [_listManage loadData];
}

@end
