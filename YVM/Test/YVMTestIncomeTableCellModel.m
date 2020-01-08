//
//  YVMTestIncomeTableCellModel.m
//  YVM
//
//  Created by KAI on 2018/4/10.
//  Copyright © 2018年 KAI. All rights reserved.
//

#import "YVMTestIncomeTableCellModel.h"
#import "YVMTestIncomeObj.h"

@implementation YVMTestIncomeTableCellModel

- (id)initWithObj:(id)obj {
    self = [super init];
    if (self) {
        if ([obj isKindOfClass:[YVMTestIncomeObj class]]) {
            [self parseViewModelWithObj:obj];
        }
    }
    return self;
}

- (void)parseViewModelWithObj:(YVMTestIncomeObj *)obj {
    NSString *firstWord = @"为 ";
    NSString *userName = obj.nickname;
    NSString *action = @" 送礼物";
    
    
    switch (obj.type.integerValue) {
        case 1:
            action = @" 送礼物";
            firstWord = @"收到 ";
            
            break;
        case 2:
            action = @" 解锁相片";
            break;
        case 3:
            firstWord = @"与 ";
            action = @" 视频通话";
            break;
        case 4:
            action = @" 经纪公司提现";
            break;
        case 5:
            action = @" 经纪公司主播提现";
            break;
        case 6:
            action = @" 主播个人提现";
            break;
        default:
            break;
    }
    
    if (obj.total_fee.integerValue/100 == 0) {
        self.gold = [NSString stringWithFormat:@"%ld",obj.total_fee.integerValue/100];
    }else{
        self.gold = [NSString stringWithFormat:@"+%ld",obj.total_fee.integerValue/100];
    }
}

@end
