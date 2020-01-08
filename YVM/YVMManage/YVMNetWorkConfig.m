//
//  YVMNetWorkConfig.m
//  YVM
//
//  Created by mac on 2019/12/11.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import "YVMNetWorkConfig.h"

@implementation YVMNetWorkConfig

static id manager = nil;

+ (instancetype)share {
    @synchronized(self){
        if (!manager) {
            manager = [[self allocWithZone:NULL] init];
        }
    }
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        self.useJsonParsing = YES;
        self.successStatusDeal = YES;
        self.status = @"status";
        self.content = @"content";
    }
    return self;
}

@end
