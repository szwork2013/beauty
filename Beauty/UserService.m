//
//  UserService.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/12.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "UserService.h"

@implementation UserService
+ (instancetype)getInstance {
    static UserService *instance;
    if (instance == nil) {
        instance = [[self alloc]init];
    }
    return instance;
}

- (void)actionWithUser:(actionBlock)actionBlock failBlock:(failBlock)failBlock {
    BmobUser *user = [BmobUser getCurrentUser];
    if (user) {
        actionBlock(user);
    } else {
//        跳转登录页面或其他操作
        failBlock();
    }
}
@end
