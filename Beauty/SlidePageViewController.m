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
#import "PageIndicatorView.h"

@interface SlidePageViewController ()

@end

@implementation SlidePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableViewArray = [NSMutableArray array];
    //初始化VC中的View尺寸
    self.view.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    self.count = 3;
    //生成若干个tableview
    [self createTableView:(NSInteger)self.count];
    //生成若干个pageIndicator
    [self createPageIndicator];
    self.tableViewContainerScrollView.pagingEnabled = YES;
    self.tableViewContainerScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * self.count, self.tableViewContainerScrollView.frame.size.height);
}
//生成createPageIndicator
- (void)createPageIndicator {
//    self.pageControlScrollView;
//    PageIndicatorView *view = [[[NSBundle mainBundle]loadNibNamed:@"PageIndicator" owner:self options:nil]firstObject];
    PageIndicatorView *pageIndicatorView = [[PageIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 120, 30)];
    pageIndicatorView.backgroundColor = [UIColor whiteColor];
    
    for (int i = 0; i < self.count; i++) {
//        view.frame = CGRectMake(i * view.frame.size.width, 0, view.frame.size.width, view.frame.size.height);
        [self.pageControlScrollView addSubview:pageIndicatorView];
    }
    
    
}
//生成tableview
- (void)createTableView:(NSInteger)count {
    for (int i = 0; i < count; i++) {
        UITableView *tableView = [[UITableView alloc]init];
        tableView.frame = CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, self.tableViewContainerScrollView.frame.size.height);
        
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
