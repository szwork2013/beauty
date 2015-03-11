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
#import <BmobSDK/Bmob.h>

@interface SlidePageViewController ()

@end

@implementation SlidePageViewController
//代理分类数组
NSArray *classifyArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableViewArray = [NSMutableArray array];
    //初始化VC中的View尺寸
    self.view.frame = CGRectMake(0, TOPBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - TOPBAR_HEIGHT);
    //    配置tableView滚动视图容器
    self.tableViewContainerScrollView.pagingEnabled = YES;
//    获取分类
    [self fetchWechatClassify];

}
//获取分类
- (void)fetchWechatClassify {
    BmobQuery *query = [BmobQuery queryWithClassName:@"WechatClassify"];
    [query orderByAscending:@"rank"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            self.count = array.count;
            classifyArray = array;
            //生成若干个pageIndicator
            [self createPageIndicator];
//            配置PageIndicatorView
            self.pageControlScrollView.contentSize = CGSizeMake(self.count * PAGEINDICATOR_WIDTH, self.pageControlScrollView.frame.size.height);
            
            //生成若干个tableview
            [self createTableView:(NSInteger)self.count];
            //配置tableView滚动视图容器
            self.tableViewContainerScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * self.count, self.tableViewContainerScrollView.frame.size.height);
        }
    }];
}
//获取分类产品
- (void)fetchWechatProduct {
    
}
//生成createPageIndicator
- (void)createPageIndicator {
//    self.pageControlScrollView;
//    PageIndicatorView *view = [[[NSBundle mainBundle]loadNibNamed:@"PageIndicator" owner:self options:nil]firstObject];
    
    for (int i = 0; i < self.count; i++) {
        BmobObject *classify = classifyArray[i];
        
        PageIndicatorView *pageIndicatorView = [[PageIndicatorView alloc]initWithFrame:CGRectMake(PAGEINDICATOR_WIDTH * i, 0, PAGEINDICATOR_WIDTH, 30) title:[classify objectForKey:@"name"] currentColor:i == 0 ? MAIN_COLOR : [UIColor whiteColor]];
        pageIndicatorView.backgroundColor = [UIColor whiteColor];
        [self.pageControlScrollView addSubview:pageIndicatorView];
    }
    
    
}
//生成tableview
- (void)createTableView:(NSInteger)count {
    for (int i = 0; i < count; i++) {
        UITableView *tableView = [[UITableView alloc]init];
        tableView.frame = CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, self.tableViewContainerScrollView.frame.size.height);
        
        SlidePageTableViewDataSource *slidePageDataSource = [[SlidePageTableViewDataSource alloc]initWithTableView:tableView classifyId:[classifyArray[i] objectId]];
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
