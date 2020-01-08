//
//  NSObject+YVM.h
//  YVM
//
//  Created by mac on 2019/12/24.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (YVM)

@property (nonatomic, copy) NSString *yvmId;

@property (nonatomic, copy) NSString *yvmType;

@property (nonatomic, copy) NSString *yvmIndex;

@property (nonatomic, copy) NSString *yvmSection;

@end

NS_ASSUME_NONNULL_END
