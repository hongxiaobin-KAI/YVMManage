//
//  YVMTestIncomeObj.h
//  YVM
//
//  Created by KAI on 2018/4/10.
//  Copyright © 2018年 KAI. All rights reserved.
//

#import "YVMTestBaseObj.h"

@interface YVMTestIncomeObj : YVMTestBaseObj

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *adate;  /**<日期  */
@property (nonatomic, copy) NSString *coin; /**< 金币 */
@property (nonatomic, copy) NSString *type;  /**<    1=>礼物 2=>解锁相片 3=>视频通话 4=>经纪公司提现 5=>经纪公司妹子提现 6=>返利 */
@property (nonatomic, copy) NSString *total_fee;  /**< 总消费 */
@property (nonatomic, copy) NSString *idx;/**< 状态 */
@property (nonatomic, copy) NSString *read_status;  /**<  */
@property (nonatomic, copy) NSString *title;  /**<  */

@property (nonatomic, copy) id remark;  /**< 用户 */

@property (nonatomic, assign) NSInteger gift_id;  /**< 礼物id */

@property (nonatomic, copy) NSString *nickname;  /**< 姓名 */
@property (nonatomic, copy) NSString *avatar;  /**< 头像 */
@property (nonatomic, assign) NSInteger total_consume;  /**< 总消费 */
@property (nonatomic, assign) NSInteger total_treasure;  /**< 总财富 */
@property (nonatomic, assign) NSInteger user_type;  /**< 用户类型 */
@property (nonatomic, copy) NSString *userid;/**<  */

@property (nonatomic, copy) NSString *user_status; /**< 用户类型 */

@property (nonatomic, assign) NSTimeInterval last_login_time; /**< 最后登录时间戳 */

@property (nonatomic, copy) NSString *nodisturb_status; /**< 勿扰状态 */

@end
