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
typedef void(^successBlock)(void);
typedef void(^failBlock)(void);
@interface UserService : NSObject
+ (instancetype)getInstance;
- (void)actionWithUser:(actionBlock)actionBlock failBlock:(failBlock)failBlock;
- (void)favorButtonPress:(NSString *)storeId successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock;
- (void)favorButtonPressForProduct:(NSString *)productId successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock;
@end
