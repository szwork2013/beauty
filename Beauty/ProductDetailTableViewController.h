//
//  ProductDetailTableViewController.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/5.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailTableViewController : UITableViewController
@property (nonatomic,strong) NSString *productId;
//推荐商家列表
@property (nonatomic,weak) IBOutlet UITableView *sellerTableView;

@property (nonatomic,strong) NSString *urlString;
@end
