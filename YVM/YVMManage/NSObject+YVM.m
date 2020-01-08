//
//  NSObject+YVM.m
//  YVM
//
//  Created by mac on 2019/12/24.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import "NSObject+YVM.h"
#import <objc/runtime.h>

@implementation NSObject (YVM)

- (void)setYvmId:(NSString *)yvmId {
    objc_setAssociatedObject(self, "yvmId", yvmId, OBJC_ASSOCIATION_COPY);
}

- (NSString *)yvmId {
    return objc_getAssociatedObject(self, "yvmId");
}

- (void)setYvmType:(NSString *)yvmId {
    objc_setAssociatedObject(self, "yvmType", yvmId, OBJC_ASSOCIATION_COPY);
}

- (NSString *)yvmType {
    return objc_getAssociatedObject(self, "yvmType");
}

- (void)setYvmIndex:(NSString *)yvmIndex {
    objc_setAssociatedObject(self, "yvmIndex", yvmIndex, OBJC_ASSOCIATION_COPY);
}

- (NSString *)yvmIndex {
    return objc_getAssociatedObject(self, "yvmIndex");
}

- (void)setYvmSection:(NSString *)yvmSection {
    objc_setAssociatedObject(self, "yvmSection", yvmSection, OBJC_ASSOCIATION_COPY);
}

- (NSString *)yvmSection {
    return objc_getAssociatedObject(self, "yvmSection");
}

@end
