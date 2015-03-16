//
//  SlidePageTableViewDataSource.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/8.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "RankListProductTableViewDataSource.h"
#import <BmobSDK/Bmob.h>
#import "ProductShowTableViewCell.h"
#import "Global.h"
#import "ProductDetailTableViewController.h"
#import "CommonUtil.h"
#import "SVPullToRefresh.h"
#import "SVProgressHUD.h"

@implementation RankListProductTableViewDataSource

- (instancetype)initWithTableView:(UITableView *)tableView classifyId:(NSString *)classifyId{
    if ([self init]) {
        self.tableView = tableView;
        self.classifyId = classifyId;
        self.dataSourceArray = [NSMutableArray array];
        //                配置上拉无限刷新
        __weak RankListProductTableViewDataSource *weakSelf = self;
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            weakSelf.page++;
            [weakSelf fetchData:PER_PAGE * weakSelf.page];
            [tableView.infiniteScrollingView stopAnimating];
        }];
    }
    return self;
}
- (void)fetchData:(NSInteger)skip {
    //to do name
    NSString *className = @"RankListProduct";
    
    BmobQuery *query = [BmobQuery queryWithClassName:className];
    query.limit = PER_PAGE;
    query.skip = skip;
    [query includeKey:@"product"];
    [query orderByAscending:@"rank"];
    [query whereKey:@"rankListClassify" equalTo:[BmobObject objectWithoutDatatWithClassName:@"RankListClassify" objectId:self.classifyId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            if (array.count == 0) {
                if (self.page == 0) {
                    self.tableView.hidden = YES;
                    UILabel *label = [[UILabel alloc]initWithFrame:self.tableView.frame];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.textColor = [UIColor grayColor];
                    label.font = [UIFont systemFontOfSize:18.0];
                    label.text = NO_DATAS;
                    [self.tableView.superview addSubview:label];
                } else {
                    [SVProgressHUD showSuccessWithStatus:NO_MORE];
                }
            } else {
                [self.dataSourceArray addObjectsFromArray:array];
                [self.tableView reloadData];
            }
        }
    }];
}
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSourceArray.count;
}
//每组1个
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
//单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CommonUtil fetchProductShowCell:[self.dataSourceArray[indexPath.section] objectForKey:@"product"] index:1];
}
//传值
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.viewController.productId = [self.dataSourceArray[tableView.indexPathForSelectedRow.section] objectId];
    [self.viewController performSegueWithIdentifier:@"productDetail" sender:self];
}
//单元格高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 4.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 4.0;
}
@end
