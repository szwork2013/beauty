//
//  SlidePageViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/8.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "SlidePageViewController.h"
#import "SlidePageTableViewDataSource.h"
#import "Global.h"

@interface SlidePageViewController ()

@end

@implementation SlidePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableViewArray = [NSMutableArray array];
    self.count = 3;
    [self createTableView:(NSInteger)self.count];
    self.tableViewContainerScrollView.pagingEnabled = YES;
    self.tableViewContainerScrollView.contentSize = CGSizeMake(self.tableViewContainerScrollView.frame.size.width * self.count, self.tableViewContainerScrollView.frame.size.height);
    // Do any additional setup after loading the view from its nib.
}
- (void)createTableView:(NSInteger)count {
    for (int i = 0; i < count; i++) {
        UITableView *tableView = [[UITableView alloc]init];
        CGRect parentRect = self.tableViewContainerScrollView.frame;
        tableView.frame = CGRectMake(i * parentRect.size.width, 0, parentRect.size.width, parentRect.size.height);
        
        SlidePageTableViewDataSource *slidePageDataSource = [[SlidePageTableViewDataSource alloc]initWithTableView:tableView];
        slidePageDataSource.viewController = self;
        tableView.delegate = slidePageDataSource;
        tableView.dataSource = slidePageDataSource;
//        获取数据并刷新表格
        [self.tableViewContainerScrollView addSubview:tableView];
        [slidePageDataSource fetchData];
        [self.tableViewArray addObject:tableView];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
