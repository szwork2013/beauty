//
//  SlidePageTableViewDataSource.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/8.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "SlidePageTableViewDataSource.h"
#import <BmobSDK/Bmob.h>

@implementation SlidePageTableViewDataSource
- (instancetype)initWithViewController:(SlidePageViewController *)viewController {
    if ([self init]) {
        self.viewController = viewController;
    }
    return self;
}
- (instancetype)initWithTableView:(UITableView *)tableView {
    if ([self init]) {
        self.tableView = tableView;
    }
    return self;
}
- (void)fetchData {
    //to do name
    NSString *className = @"WechatProduct";
    
    BmobQuery *query = [BmobQuery queryWithClassName:className];
    [query includeKey:@"product"];
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
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = [[self.dataSourceArray[indexPath.row] objectForKey:@"product"]objectForKey:@"name"];
    return cell;
}
@end
