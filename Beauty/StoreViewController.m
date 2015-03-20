//
//  StoreViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/1.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "StoreViewController.h"
#import "ActivityViewController.h"
#import <BmobSDK/Bmob.h>
#import "XHRootView.h"
#import "StoreTableViewCell.h"
#import "SVProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "Global.h"
#import "CommonUtil.h"
#import "SVPullToRefresh.h"

@interface StoreViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong ,nonatomic) NSMutableArray *storeActivityArray;
@property (nonatomic,assign) NSInteger page;
@end

@implementation StoreViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.storeActivityArray = [NSMutableArray array];
        // Do any additional setup after loading the view.
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
    

            
            for (int i = 0; i < 2; i++) {
                //生成导航
                XHMenu *menu = [[XHMenu alloc] init];
                if (i == 0) {
                    menu.title = @"店铺活动";
                } else {
                    menu.title = @"附近";
                }
                menu.titleNormalColor = [UIColor grayColor];
                menu.titleFont = [UIFont systemFontOfSize:17.0];
                [viewPager.menus addObject:menu];
                //                生成表格
                //        初始化tableview
                UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(i * CGRectGetWidth(viewPager.scrollView.bounds), 0, CGRectGetWidth(viewPager.scrollView.bounds), CGRectGetHeight(viewPager.scrollView.bounds)) style:UITableViewStyleGrouped];
                //边距
                tableView.contentInset = UIEdgeInsetsMake(-4, 0, 0, 0);
                if (i == 0) {
                    //        设置滚动视图代理类
                    tableView.delegate = self;
                    tableView.dataSource = self;
                    [self fetchData:0 tableView:tableView];
//                    配置上拉无限刷新
                    __weak StoreViewController *weakSelf = self;
                    __weak UITableView *weakTableView = tableView;
                    [tableView addInfiniteScrollingWithActionHandler:^{
                        self.page ++;
                        [weakSelf fetchData:PER_PAGE * self.page tableView:weakTableView];
                        [weakTableView.infiniteScrollingView stopAnimating];
                    }];
                }
                

                
                //        获取数据并刷新表格
                [viewPager.scrollView addSubview:tableView];
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

#pragma mark 代理方法
- (void) fetchData:(NSUInteger)skip tableView:(UITableView *)tableView {
    BmobQuery *activityQuery = [BmobQuery queryWithClassName:@"StoreActivity"];
    activityQuery.limit = PER_PAGE;
    activityQuery.skip = skip;
    NSLog(@"%zi,%zi",self.page,skip);
    [activityQuery includeKey:@"store"];
    [activityQuery orderByDescending:@"time"];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array.count == 0) {
            if (self.page == 0) {
                tableView.hidden = YES;
                UILabel *label = [[UILabel alloc]initWithFrame:tableView.frame];
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = [UIColor grayColor];
                label.font = [UIFont systemFontOfSize:18.0];
                label.text = NO_DATAS;
                [tableView.superview addSubview:label];
            } else {
                [SVProgressHUD showSuccessWithStatus:NO_MORE];
            }
        } else {
            [self.storeActivityArray addObjectsFromArray:array];
            [tableView reloadData];
        }
    }];
    
}
//组眉
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8.0;
}
//组脚
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.storeActivityArray.count;
}
//一组一个
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

//自定义单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoreTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"StoreTableViewCell" owner:self options:nil]firstObject];
    //    名称与描述
    BmobObject *activity = self.storeActivityArray[indexPath.section];
    cell.nameLabel.text = [activity objectForKey:@"name"];
//    NSLog(@"%@",cell.nameLabel.text);
    cell.descriptLabel.text = [activity objectForKey:@"descript"];
    //    缩略图
    BmobFile *avatar = [activity objectForKey:@"avatar"];
    
    [BmobImage cutImageBySpecifiesTheWidth:100 * 2 height:100 * 2 quality:100 sourceImageUrl:avatar.url outputType:kBmobImageOutputBmobFile resultBlock:^(id object, NSError *error) {
        BmobFile *thumb = (BmobFile *)object;
        [cell.thumbImageView setImageWithURL:[NSURL URLWithString:thumb.url]];
    }];
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //日期转换
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM-dd"];
    
    cell.timeLabel.text = [formatter stringFromDate:[activity objectForKey:@"time"]];
    //    关联查询店铺
    cell.shopNameLabel.text = [[activity objectForKey:@"store"]objectForKey:@"name"];
    return cell;
}

//单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110.0;
}

//单击单元格
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"activity" sender:self];
    self.activityId = [self.storeActivityArray[indexPath.section] objectId];
}

/**
 Segue 跳转，传参
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ActivityViewController *activityVC = (ActivityViewController *)segue.destinationViewController;
    activityVC.objectId = self.activityId;
}

@end
