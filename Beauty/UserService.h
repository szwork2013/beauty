//
//  UserService.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/12.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>

typedef void(^actionBlock)(BmobUser *user);

@interface UserService : NSObject
+ (instancetype)getInstance;
- (void)actionWithUser:(actionBlock)actionBlock;
- (BOOL)isLogin;
@end
