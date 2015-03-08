//
//  SlidePageTableViewDataSource.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/8.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlidePageViewController.h"

@interface SlidePageTableViewDataSource : NSObject<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray *dataSourceArray;
@property (nonatomic,strong) SlidePageViewController *viewController;
@property (nonatomic,strong) UITableView *tableView;
- (instancetype)initWithTableView:(UITableView *)tableView;
- (void)fetchData;
@end
