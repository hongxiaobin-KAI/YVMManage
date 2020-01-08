//
//  YVMTestBaseObj.m
//  YVM
//
//  Created by KAI on 2019/1/10.
//  Copyright © 2019年 KAI. All rights reserved.
//

#import "YVMTestBaseObj.h"
#import "MJExtension.h"

@implementation YVMTestBaseObj

+ (instancetype)parseObjWithDict:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    id obj = [[self alloc] init];
    [obj mj_setKeyValues:dict];
    return obj;
}

@end
