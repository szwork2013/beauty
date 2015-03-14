//
//  SlidePageTableViewDataSource.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/8.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "SlidePageTableViewDataSource.h"
#import <BmobSDK/Bmob.h>
#import "ProductShowTableViewCell.h"
#import "StarView.h"
#import "UIImageView+AFNetworking.h"
#import "Global.h"
#import "WechatProductDetailTableViewController.h"
#import "CommonUtil.h"

@implementation SlidePageTableViewDataSource

- (instancetype)initWithTableView:(UITableView *)tableView classifyId:(NSString *)classifyId{
    if ([self init]) {
        self.tableView = tableView;
        self.classifyId = classifyId;
    }
    return self;
}
- (void)fetchData {
    //to do name
    NSString *className = @"WechatProduct";
    
    BmobQuery *query = [BmobQuery queryWithClassName:className];
    [query includeKey:@"product"];
    [query orderByAscending:@"rank"];
    [query whereKey:@"wechatClassify" equalTo:[BmobObject objectWithoutDatatWithClassName:@"WechatClassify" objectId:self.classifyId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            self.dataSourceArray = array;
            [self.tableView reloadData];
            if (array.count == 0) {
                self.tableView.hidden = YES;
                UILabel *label = [[UILabel alloc]initWithFrame:self.tableView.frame];
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = [UIColor grayColor];
                label.font = [UIFont systemFontOfSize:18.0];
                label.text = @"结果空空如也～";
                [self.tableView.superview addSubview:label];
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
//UserDefault传值
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewController performSegueWithIdentifier:@"wechatProductDetail" sender:self];
    [[NSUserDefaults standardUserDefaults]setObject:[self.dataSourceArray[tableView.indexPathForSelectedRow.row] objectId] forKey:@"wechatProductId"];
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
