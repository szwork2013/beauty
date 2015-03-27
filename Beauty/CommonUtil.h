//
//  CommonUtil.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/12.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductShowTableViewCell.h"
#import "ProductCommentTableViewCell.h"
#import "StoreShowTableViewCell.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"
#import "Global.h"
#import "StarView.h"
@interface CommonUtil : NSObject
+ (NSDictionary *)textViewAttribute;
+ (NSString *)enterChar:(NSString *)descriptString;
+ (ProductShowTableViewCell *)fetchProductShowCell:(BmobObject *)product index:(NSInteger)i;
+ (ProductCommentTableViewCell *)fetchProductCommentCell:(BmobObject *)comment;
+ (NSInteger)daysInterval:(NSDate *)date;
+ (StoreShowTableViewCell *)fetchStoreShowCell:(BmobObject *)store;
+ (void)updateTableViewHeight:(UIViewController *)vc;
+ (NSString *) compareCurrentTime:(NSDate*) compareDate;
//评价高度
+ (CGFloat)fetchProductCommentCellHeight:(BmobObject *)commentObject;
//产品搜索页
+ (ProductShowTableViewCell *) fetchProductShowCell:(BmobObject *)product;
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
//不带收藏按钮
+ (StoreShowTableViewCell *) fetchStoreShowCellWithoutFavorButton:(BmobObject *)store WithOrderNum:(NSInteger)num;
+ (UIImage *)shrinkImage:(UIImage *)original toSize:(CGSize)size;
@end
