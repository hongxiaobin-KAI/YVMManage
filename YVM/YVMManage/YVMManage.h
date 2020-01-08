//
//  YVMManage.h
//  YVM
//
//  Created by mac on 2019/12/26.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YVMManage : NSObject

+ (void)fillView:(id)view model:(id)model;

+ (void)fillView:(id)view config:(id)config;

@end

NS_ASSUME_NONNULL_END
