//
//  SlidePageTableViewDataSource.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/8.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RankListProductViewController.h"


@interface RankListProductTableViewDataSource : NSObject<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSMutableArray *dataSourceArray;
@property (nonatomic,strong) RankListProductViewController *viewController;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSString *classifyId;
@property (nonatomic,assign) NSInteger page;
- (instancetype)initWithTableView:(UITableView *)tableView classifyId:(NSString *)classifyId;
- (void)fetchData:(NSInteger)skip;
@end
