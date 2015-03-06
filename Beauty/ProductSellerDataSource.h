//
//  ProductSellerDataSource.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/6.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductDetailTableViewController.h"

@interface ProductSellerDataSource : NSObject <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) ProductDetailTableViewController *vc;
//商家列表数据源
@property (nonatomic,strong) NSArray *sellerArray;
//主控制器
-(instancetype)initWithViewController:(ProductDetailTableViewController *)vc;
@end
