//
//  AppDelegate.m
//  YVM
//
//  Created by mac on 2019/9/9.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import "AppDelegate.h"
#import "YVMTestTableViewController.h"

#import "YVMNetWorkConfig.h"

#import "YVMListViewManage.h"

@interface AppDelegate ()

@property (nonatomic, strong) YVMListViewManage *listManage;  /**<  */

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initConfig];
    [self initListManage];
    [self makeController];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)initConfig {
    YVMNetWorkConfig *config = [YVMNetWorkConfig share];
    config.httpBaseUrl = @"https://test.ios.mmv.wemepi.com";
}

- (void)initListManage {
    self.listManage = [[YVMListViewManage alloc] init];
    self.listManage.interAPI = @"1.7.0/dispatch.php";
    self.listManage.addParam = @{@"v_class" : @"400" ,@"v_cmd" : @"406", @"shareContent" : @"3db88f97ed3d734b35b12af1a9a5a50d", @"did" : @"f3bca17996cfaa1ec15b9866e8200eee", @"channel_id" : @"88888888", @"bundle_id" : @"com.honglajiao.www", @"e_market_signature" : @"app store", @"userid" : @"132533", @"token_id" : @"3c6dee8ac12f5e5ecd4612dfd8dcf83e"};
    self.listManage.requestType = YVMListRequestType_APIRequest;
    self.listManage.parseListDictName = @"disburse_info";
    self.listManage.pageObjClassName = @"WMPageObj";
    self.listManage.parsePageDictName = @"base_info";
    self.listManage.objClassName = @"WMIncomeObj";
    self.listManage.vmClassName = @"WMIncomeTableCellModel";
    [self.listManage loadData];
}

- (void)makeController {
    YVMTestTableViewController *controller =  [[YVMTestTableViewController alloc] init];
    UIViewController *navigationController = [[UINavigationController alloc]
                                                      initWithRootViewController:controller];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
}


@end
