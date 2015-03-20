//
//  WechatProductViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/8.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "WechatProductViewController.h"
#import "WechatProductDetailTableViewController.h"
#import <BmobSDK/Bmob.h>
#import "WechatProductTableViewDataSource.h"
#import "XHRootView.h"

@interface WechatProductViewController ()
@end

@implementation WechatProductViewController

- (void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = NO;
    [super viewDidLoad];
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
    
    viewPager.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(viewPager.scrollMenu.frame) + 8, CGRectGetWidth(viewPager.bounds), CGRectGetHeight(viewPager.bounds) - CGRectGetMaxY(viewPager.scrollMenu.frame) - 8)];
    viewPager.scrollView.showsHorizontalScrollIndicator = NO;
    viewPager.scrollView.showsVerticalScrollIndicator = NO;
    viewPager.scrollView.delegate = viewPager;
    viewPager.scrollView.pagingEnabled = YES;
    viewPager.scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [viewPager addSubview:viewPager.scrollView];

    //获取分类
    
    BmobQuery *query = [BmobQuery queryWithClassName:@"WechatClassify"];
    [query orderByAscending:@"rank"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            
            for (int i = 0; i < array.count; i++) {
                //生成导航
                XHMenu *menu = [[XHMenu alloc] init];
                menu.title = [array[i]objectForKey:@"name"];
                
                menu.titleNormalColor = [UIColor grayColor];
                menu.titleFont = [UIFont systemFontOfSize:17.0];
                [viewPager.menus addObject:menu];
//                生成表格
                
                //        初始化tableview
                UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(i * CGRectGetWidth(viewPager.scrollView.bounds), 0, CGRectGetWidth(viewPager.scrollView.bounds), CGRectGetHeight(viewPager.scrollView.bounds)) style:UITableViewStyleGrouped];
                //边距
                tableView.contentInset = UIEdgeInsetsMake(-4, 0, 0, 0);
                //        设置tableview代理类
                WechatProductTableViewDataSource *productDataSource = [[WechatProductTableViewDataSource alloc]initWithTableView:tableView classifyId:[array[i] objectId]];
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
    }];
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    WechatProductDetailTableViewController *vc = segue.destinationViewController;
    vc.productId = self.productId;
}


@end
