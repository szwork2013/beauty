//
//  SlidePageTableViewDataSource.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/8.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "SlidePageTableViewDataSource.h"
#import <BmobSDK/Bmob.h>
#import "ProductTryTableViewCell.h"
#import "StarView.h"
#import "UIImageView+AFNetworking.h"

@implementation SlidePageTableViewDataSource
- (instancetype)initWithViewController:(SlidePageViewController *)viewController {
    if ([self init]) {
        self.viewController = viewController;
    }
    return self;
}
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
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductTryTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductTableViewCell" owner:self options:nil]lastObject];
    BmobObject *product = [self.dataSourceArray[indexPath.row] objectForKey:@"product"];
    BmobFile *avatar = [product objectForKey:@"avatar"];
    [cell.thumbImageView setImageWithURL:[NSURL URLWithString:avatar.url]];
    cell.nameLabel.text = [product objectForKey:@"name"];
    cell.commentCountLabel.text = [[product objectForKey:@"comment"]stringValue];
    cell.averagePriceLabel.text = [[product objectForKey:@"averagePrice"]stringValue];
//        评分星级
    StarView *view = [[StarView alloc]initWithCount:[product objectForKey:@"mark"] frame:CGRectMake(0, 0, 55.0, 11.0)];
    [cell.starView addSubview:view];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}
@end
