//
//  CommonUtil.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/12.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductShowTableViewCell.h"
#import "StoreShowTableViewCell.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"
#import "Global.h"
#import "StarView.h"
@interface CommonUtil : NSObject
+ (NSDictionary *)textViewAttribute;
+ (NSString *)enterChar:(NSString *)descriptString;
+ (ProductShowTableViewCell *)fetchProductShowCell:(BmobObject *)product index:(NSInteger)i;
+ (NSInteger)daysInterval:(NSDate *)date;
+ (StoreShowTableViewCell *)fetchStoreShowCell:(BmobObject *)store;
@end
