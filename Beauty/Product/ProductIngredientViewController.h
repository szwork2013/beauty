//
//  ProductIngredientViewController.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/22.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductIngredientViewController : UIViewController
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, strong) NSString *productId;
@property (nonatomic, assign) NSInteger count;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
