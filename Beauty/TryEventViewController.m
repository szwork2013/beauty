//
//  TryEventViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/14.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "TryEventViewController.h"
#import "TryEventProductDetailTableViewController.h"
#import <BmobSDK/Bmob.h>
#import "TryEventProductTableViewDataSource.h"
#import "XHRootView.h"
@interface TryEventViewController ()

@end

@implementation TryEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabBarController.tabBar.hidden = YES;
    [self setup];
}

- (void)setup {
    XHRootView *viewPager = [[XHRootView alloc]init];
    viewPager.bounds = self.view.bounds;
    viewPager.center = self.view.center;
    viewPager.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:viewPager];
    
    viewPager.shouldObserving = YES;
    
    viewPager.scrollMenu = [[XHScrollMenu alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(viewPager.bounds), 36)];
    viewPager.scrollMenu.backgroundColor = [UIColor whiteColor];
    viewPager.scrollMenu.delegate = viewPager;

    [viewPager addSubview:viewPager.scrollMenu];
    
    viewPager.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(viewPager.scrollMenu.frame) + 8, CGRectGetWidth(viewPager.bounds), CGRectGetHeight(viewPager.bounds) - CGRectGetMaxY(viewPager.scrollMenu.frame))];
    viewPager.scrollView.showsHorizontalScrollIndicator = NO;
    viewPager.scrollView.showsVerticalScrollIndicator = NO;
    viewPager.scrollView.delegate = viewPager;
    viewPager.scrollView.pagingEnabled = YES;
    viewPager.scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [viewPager addSubview:viewPager.scrollView];
//    设定分类
    
    for (int i = 0; i < 2; i++) {
        //生成导航
        XHMenu *menu = [[XHMenu alloc] init];
        if (i == 0) {
            menu.title = @"正在试用";
        } else {
            menu.title = @"往期试用";
        }
        menu.titleNormalColor = [UIColor grayColor];
        menu.titleFont = [UIFont boldSystemFontOfSize:17.0];
        [viewPager.menus addObject:menu];
        //                生成表格
        //        初始化tableview
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(i * CGRectGetWidth(viewPager.scrollView.bounds), 0, CGRectGetWidth(viewPager.scrollView.bounds), CGRectGetHeight(viewPager.scrollView.bounds)) style:UITableViewStyleGrouped];
        //边距
        tableView.contentInset = UIEdgeInsetsMake(-4, 0, 0, 0);
        //        设置tableview代理类
        TryEventProductTableViewDataSource *productDataSource = [[TryEventProductTableViewDataSource alloc]initWithTableView:tableView classifyId:i];
        productDataSource.viewController = self;
        //        设置滚动视图代理类
        tableView.delegate = productDataSource;
        tableView.dataSource = productDataSource;
        
        //        获取数据并刷新表格
        [viewPager.scrollView addSubview:tableView];
        [productDataSource fetchData:0];
    }
    [viewPager.scrollView setContentSize:CGSizeMake(viewPager.menus.count * CGRectGetWidth(viewPager.scrollView.bounds), CGRectGetHeight(viewPager.scrollView.bounds))];
    [viewPager startObservingContentOffsetForScrollView:viewPager.scrollView];
    
    viewPager.scrollMenu.menus = viewPager.menus;
    [viewPager.scrollMenu reloadData];
   
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TryEventProductDetailTableViewController *vc = segue.destinationViewController;
    vc.productId = self.productId;
}

@end
