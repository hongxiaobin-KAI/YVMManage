//
//  YVMListSectionManage.m
//  YVM
//
//  Created by mac on 2019/12/27.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import "YVMListSectionManage.h"

@implementation YVMListSectionManage

- (instancetype)init {
    self = [super init];
    if (self) {
        NSMutableArray *objArray = [[NSMutableArray alloc] init];
        self.cellObjArray = objArray;
        
        NSMutableArray *vmArray = [[NSMutableArray alloc] init];
        self.cellVmArray = vmArray;
    }
    return self;
}

@end
