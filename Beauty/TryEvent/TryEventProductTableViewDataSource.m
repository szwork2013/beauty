//
//  SlidePageTableViewDataSource.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/8.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "TryEventProductTableViewDataSource.h"
#import <BmobSDK/Bmob.h>
#import "TryEventTableViewCell.h"
#import "Global.h"
#import "TryEventProductDetailTableViewController.h"
#import "CommonUtil.h"
#import "SVPullToRefresh.h"
#import "SVProgressHUD.h"
#import "UIImageView+AFNetworking.h"

@implementation TryEventProductTableViewDataSource

- (instancetype)initWithTableView:(UITableView *)tableView classifyId:(NSInteger)classifyId{
    if ([self init]) {
        self.tableView = tableView;
        self.classifyId = classifyId;
        self.dataSourceArray = [NSMutableArray array];
        //                配置上拉无限刷新
        __weak TryEventProductTableViewDataSource *weakSelf = self;
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
    NSString *className = @"TryEvent";
    
    BmobQuery *query = [BmobQuery queryWithClassName:className];
    query.limit = PER_PAGE;
    query.skip = skip;
    [query includeKey:@"product"];
    [query orderByAscending:@"endTime"];
    if (self.classifyId == 0) {
        [query whereKey:@"endTime" greaterThanOrEqualTo:[NSDate date]];
    } else {
            [query whereKey:@"endTime" lessThanOrEqualTo:[NSDate date]];
    }

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
    TryEventTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"TryEventTableViewCell" owner:self options:nil]firstObject];
    BmobObject *tryEvent = self.dataSourceArray[indexPath.section];
    
    BmobFile *avatar = [tryEvent objectForKey:@"avatar"];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:avatar.url]];
    cell.nameLabel.text = [tryEvent objectForKey:@"name"];
    cell.applyNumberLabel.text = [NSString stringWithFormat:@"%@份",[[tryEvent objectForKey:@"applyNumber"]stringValue]];
    cell.countLabel.text = [NSString stringWithFormat:@"%@人参与",[[tryEvent objectForKey:@"count"]stringValue]];
    if ([CommonUtil daysInterval:[tryEvent objectForKey:@"endTime"]] > 0) {
        cell.endTimeLabel.text = [NSString stringWithFormat:@"还剩%ld天",(long)[CommonUtil daysInterval:[tryEvent objectForKey:@"endTime"]]];
    } else {
        cell.endTimeLabel.text = @"已结束";
    }
    
    return cell;
}
//传值
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.viewController.productId = [[self.dataSourceArray[tableView.indexPathForSelectedRow.section]objectForKey:@"product"] objectId];
    [self.viewController performSegueWithIdentifier:@"tryEventDetail" sender:self];
}
//单元格高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 4.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 4.0;
}
@end
