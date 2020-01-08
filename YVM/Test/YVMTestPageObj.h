//
//  YVMTestPageObj.h
//  YVM
//
//  Created by KAI on 2018/4/13.
//  Copyright © 2018年 KAI. All rights reserved.
//

#import "YVMTestBaseObj.h"

@interface YVMTestPageObj : YVMTestBaseObj

@property (nonatomic, copy) NSString *did;

@property (nonatomic, copy) NSString *userid;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, assign) NSInteger limit;

@property (nonatomic, assign) NSInteger is_more;

@end
