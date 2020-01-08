//
//  YVMListSectionManage.h
//  YVM
//
//  Created by mac on 2019/12/27.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YVMListSectionManage : NSObject

@property (nonatomic, strong) id sectionHeadObj;  /**<   */

@property (nonatomic, strong) id sectionHeadVm;  /**<  */

@property (nonatomic, strong) NSMutableArray *cellObjArray;  /**<  */

@property (nonatomic, strong) NSMutableArray *cellVmArray;  /**<  */

@property (nonatomic, strong) id sectionFooterObj;  /**<  */

@property (nonatomic, strong) id sectionFooterVm;  /**<  */

@end

NS_ASSUME_NONNULL_END
