//
//  YVMTestIncomeObj.m
//  YVM
//
//  Created by KAI on 2018/4/10.
//  Copyright © 2018年 KAI. All rights reserved.
//

#import "YVMTestIncomeObj.h"
#import "MJExtension.h"

@implementation YVMTestIncomeObj

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID": @"id"};
}

+ (instancetype)parseObjWithDict:(NSDictionary *)dict {
    YVMTestIncomeObj *obj = [[self alloc] init];
    [obj mj_setKeyValues:dict];
    return obj;
}

@end
