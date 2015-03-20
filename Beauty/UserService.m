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
- (BOOL)isLogin {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"username"]) {
        return YES;
    }
    return NO;
}

- (void)actionWithUser:(actionBlock)actionBlock {
    if ([self isLogin]) {
        BmobQuery *query = [BmobUser query];
        [query whereKey:@"username" equalTo:[[NSUserDefaults standardUserDefaults]objectForKey:@"username"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            if (error) {
                NSLog(@"%@",error);
            } else {
                BmobUser *user = [array firstObject];
                actionBlock(user);
            }
        }];
    } else {
        //请先登录
        actionBlock(nil);
    }
    
}
@end
