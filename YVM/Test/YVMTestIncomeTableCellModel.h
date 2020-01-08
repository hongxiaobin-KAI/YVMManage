//
//  YVMTestIncomeTableCellModel.h
//  YVM
//
//  Created by KAI on 2018/4/10.
//  Copyright © 2018年 KAI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YVMTestIncomeTableCellModel : NSObject

@property (nonatomic, copy) NSString *head;  /**< 头像 */
@property (nonatomic, copy) NSAttributedString *incomeText;  /**< 消费情况 */
@property (nonatomic, copy) NSString *date;  /**< 通话日期 */
@property (nonatomic, copy) NSString *gold;  /**< 消费金额 */

- (id)initWithObj:(id)obj;

@end
