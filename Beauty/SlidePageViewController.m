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

@interface SlidePageViewController ()<UIScrollViewDelegate>

@end

@implementation SlidePageViewController
//代理分类数组
NSArray *classifyArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableViewArray = [NSMutableArray array];
    //初始化VC中的View尺寸
    self.view.frame = CGRectMake(0, TOPBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - TOPBAR_HEIGHT);
    //设置滚动方法代理
    self.tableViewContainerScrollView.delegate = self;
    //    配置tableView滚动视图容器
    self.tableViewContainerScrollView.pagingEnabled = YES;
//    获取分类
    [self fetchWechatClassify];
    //初始化滑动指标按钮
    self.pageIndicatorViewArray = [NSMutableArray array];
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
//            添加按钮点击事件
            [self addButtonTouchUpInsideEvent];

        }
    }];
}

//生成createPageIndicator
- (void)createPageIndicator {
    for (int i = 0; i < self.count; i++) {
        BmobObject *classify = classifyArray[i];
        PageIndicatorView *pageIndicatorView = [[PageIndicatorView alloc]initWithFrame:CGRectMake(PAGEINDICATOR_WIDTH * i, 0, PAGEINDICATOR_WIDTH, 30) title:[classify objectForKey:@"name"] currentColor:i == 0 ? MAIN_COLOR : [UIColor clearColor]];
        pageIndicatorView.backgroundColor = [UIColor whiteColor];
        pageIndicatorView.indicatorView.backgroundColor = [UIColor blueColor];
//        添加到数组
        [self.pageIndicatorViewArray addObject:pageIndicatorView];
//        添加到父视图
        [self.pageControlScrollView addSubview:pageIndicatorView];
    }
}
//绑定按钮点击事件
- (void)addButtonTouchUpInsideEvent {
    for (int i = 0; i < self.count; i++) {
        PageIndicatorView *pageIndicatorView = self.pageIndicatorViewArray[i];
        [pageIndicatorView.nameButton addTarget:self action:@selector(scrollToSpecificTableView) forControlEvents:UIControlEventTouchUpInside];
    }
}
//滚动到特定的tableview
- (void)scrollToSpecificTableView {
    [self.tableViewContainerScrollView setContentOffset:CGPointMake(0, 375) animated:YES];
}
//生成tableview
- (void)createTableView:(NSInteger)count {
    for (int i = 0; i < count; i++) {
//        初始化tableview
        UITableView *tableView = [[UITableView alloc]init];
        tableView.frame = CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, self.tableViewContainerScrollView.frame.size.height);
//        设置tableview代理类
        SlidePageTableViewDataSource *slidePageDataSource = [[SlidePageTableViewDataSource alloc]initWithTableView:tableView classifyId:[classifyArray[i] objectId]];
        slidePageDataSource.viewController = self;
//        设置滚动视图代理类
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
//滚动tableview的代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableViewContainerScrollView) {
        NSUInteger currentPage = (int)scrollView.contentOffset.x / self.view.frame.size.width;
        PageIndicatorView *currentPageIndicatorView = self.pageIndicatorViewArray[currentPage];
        currentPageIndicatorView.indicatorView.backgroundColor = MAIN_COLOR;
        [currentPageIndicatorView.nameButton setTintColor:[UIColor darkGrayColor]];
//        除了自身，其余几个按钮改变样式
        for (int i = 0; i < self.count; i++) {
            if (i != currentPage) {
                PageIndicatorView* piView = self.pageIndicatorViewArray[i];
                piView.indicatorView.backgroundColor = [UIColor clearColor];
                [piView.nameButton setTintColor:[UIColor grayColor]];
            }
        }
        //            即将拉到底
        if ((currentPage + 1) * PAGEINDICATOR_WIDTH > self.pageControlScrollView.frame.size.width) {
            [self.pageControlScrollView setContentOffset:CGPointMake((currentPage + 1) * PAGEINDICATOR_WIDTH - self.pageControlScrollView.frame.size.width, 0) animated:YES];
        }
        //            即将回到最左边
        if ((currentPage - 1) * PAGEINDICATOR_WIDTH < PAGEINDICATOR_WIDTH) {
            [self.pageControlScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
    
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
