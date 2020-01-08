//
//  YVMControlConfig.h
//  YVM
//
//  Created by mac on 2019/12/26.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YVMControlConfig : NSObject

@property (nonatomic, weak) id target; /**< 对象 */

@property (nonatomic, copy) NSString *methodName; /**< 方法名 */

@property (nonatomic, copy) NSString *type; /**< 类型 */

@property (nonatomic, assign) NSInteger indexRow;

@property (nonatomic, assign) NSInteger section; /**<  */

@property (nonatomic, assign) UIControlEvents event; /**<  */

@end

NS_ASSUME_NONNULL_END
