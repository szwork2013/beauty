//
//  RankListBrandTableViewDataSource.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/16.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RankListBrandViewController.h"

@interface RankListBrandTableViewDataSource : NSObject<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSMutableArray *dataSourceArray;
@property (nonatomic,strong) RankListBrandViewController *viewController;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSString *classifyId;
@property (nonatomic,assign) NSInteger page;
- (instancetype)initWithTableView:(UITableView *)tableView classifyId:(NSString *)classifyId;
- (void)fetchData:(NSInteger)skip;

@end
