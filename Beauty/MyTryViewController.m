//
//  MyTryViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/25.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "MyTryViewController.h"
#import "XHRootView.h"
#import "SVProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "Global.h"
#import "CommonUtil.h"
#import "SVPullToRefresh.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "UserService.h"
#import "TryEventTableViewCell.h"
#import "TryEventProductDetailTableViewController.h"
@interface MyTryViewController () <UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>
@property (strong ,nonatomic) NSMutableArray *arrayOfValid;
@property (strong ,nonatomic) NSMutableArray *arrayOfMine;
@property (nonatomic,assign) NSInteger pageOfValid;
@property (nonatomic,assign) NSInteger pageOfMine;
@property (nonatomic, strong) UITableView *tableViewOfValid;
@property (nonatomic, strong) UITableView *tableViewOfMine;
@end

@implementation MyTryViewController

- (void)viewDidLoad {
    self.navigationItem.title = @"我的试用";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.arrayOfValid = [NSMutableArray array];
    self.arrayOfMine = [NSMutableArray array];
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
    
    
    
    for (int i = 0; i < 2; i++) {
        //生成导航
        XHMenu *menu = [[XHMenu alloc] init];
        if (i == 0) {
            menu.title = @"正在试用";
        } else {
            menu.title = @"我的试用";
        }
        menu.titleNormalColor = [UIColor grayColor];
        menu.titleFont = [UIFont systemFontOfSize:17.0];
        [viewPager.menus addObject:menu];
        //                生成表格
        //        初始化tableview
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(i * CGRectGetWidth(viewPager.scrollView.bounds), 0, CGRectGetWidth(viewPager.scrollView.bounds), CGRectGetHeight(viewPager.scrollView.bounds)) style:UITableViewStyleGrouped];
        //边距
        tableView.contentInset = UIEdgeInsetsMake(-4, 0, 0, 0);
        //                if (i == 0) {
        //        设置滚动视图代理类
        tableView.delegate = self;
        tableView.dataSource = self;
        
        //                    配置上拉无限刷新
        __weak MyTryViewController *weakSelf = self;
        __weak UITableView *weakTableView = tableView;
        if (i == 0) {
            [self fetchDataForValid:0 tableView:tableView];
            [tableView addInfiniteScrollingWithActionHandler:^{
                self.pageOfValid ++;
                [weakSelf fetchDataForValid:PER_PAGE * self.pageOfValid tableView:weakTableView];
                [weakTableView.infiniteScrollingView stopAnimating];
            }];
            self.tableViewOfValid = tableView;
        } else {
            [self fetchDataForMine:0 tableView:tableView];
            [tableView addInfiniteScrollingWithActionHandler:^{
                self.pageOfMine ++;
                [weakSelf fetchDataForMine:PER_PAGE * self.pageOfMine tableView:weakTableView];
                [weakTableView.infiniteScrollingView stopAnimating];
            }];
            self.tableViewOfMine = tableView;
        }
        
        //                }
        
        
        
        //        获取数据并刷新表格
        [viewPager.scrollView addSubview:tableView];
    }
    [viewPager.scrollView setContentSize:CGSizeMake(viewPager.menus.count * CGRectGetWidth(viewPager.scrollView.bounds), CGRectGetHeight(viewPager.scrollView.bounds))];
    [viewPager startObservingContentOffsetForScrollView:viewPager.scrollView];
    viewPager.scrollMenu.menus = viewPager.menus;
    [viewPager.scrollMenu reloadData];
}

#pragma mark 获取正在试用
- (void) fetchDataForValid:(NSUInteger)skip tableView:(UITableView *)tableView {
    BmobQuery *query = [BmobQuery queryWithClassName:@"TryEvent"];
    query.limit = PER_PAGE;
    query.skip = skip;
    [query includeKey:@"product"];
    [query orderByAscending:@"endTime"];
    [query whereKey:@"endTime" greaterThanOrEqualTo:[NSDate date]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            if (array.count == 0) {
                if (self.pageOfValid == 0) {
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
                [self.arrayOfValid addObjectsFromArray:array];
                [tableView reloadData];
            }
        }
    }];
    
}
//获取我的试用
- (void)fetchDataForMine:(NSUInteger)skip tableView:(UITableView *)tableView {
    BmobQuery *query = [BmobQuery queryWithClassName:@"TryRecord"];
    
    query.limit = PER_PAGE;
    query.skip = skip;
    
    [query includeKey:@"tryEvent"];
    [query whereKey:@"user" equalTo:self.user];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array.count == 0) {
            if (self.pageOfMine == 0) {
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
            for (NSDictionary *tryRecord in array) {
                BmobObject *tryEvent = [tryRecord objectForKey:@"tryEvent"];
                [self.arrayOfMine addObject:tryEvent];
            }
            [tableView reloadData];
        }
    }];
}
#pragma mark -
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableViewOfValid) {
        return self.arrayOfValid.count;
    }
    return self.arrayOfMine.count;
}
//每组1个
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
//单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TryEventTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"TryEventTableViewCell" owner:self options:nil]firstObject];
    BmobObject *tryEvent = nil;
    if (tableView == self.tableViewOfValid) {
        tryEvent = self.arrayOfValid[indexPath.section];
    } else {
        tryEvent = self.arrayOfMine[indexPath.section];
    }
    BmobFile *avatar = [tryEvent objectForKey:@"avatar"];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:avatar.url]];
    cell.nameLabel.text = [tryEvent objectForKey:@"name"];
    cell.applyNumberLabel.text = [NSString stringWithFormat:@"%@份",[[tryEvent objectForKey:@"applyNumber"]stringValue]];
    cell.countLabel.text = [NSString stringWithFormat:@"%@人参与",[[tryEvent objectForKey:@"count"]stringValue]];
    if ([CommonUtil daysInterval:[tryEvent objectForKey:@"endTime"]] > 0) {
        cell.endTimeLabel.text = [NSString stringWithFormat:@"还剩%ld天",(long)[CommonUtil daysInterval:[tryEvent objectForKey:@"endTime"]]];
    } else {
        cell.endTimeLabel.text = @"已结束";
    }
    
    return cell;
}
//传值
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TryEventProductDetailTableViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"tryEvent"];
    if (tableView == self.tableViewOfValid) {
        vc.productId = [[self.arrayOfValid[tableView.indexPathForSelectedRow.section]objectForKey:@"product"] objectId];
    } else {
        vc.productId = [[self.arrayOfMine[tableView.indexPathForSelectedRow.section]objectForKey:@"product"] objectId];
    }
    [self.navigationController pushViewController:vc animated:YES];
}
//单元格高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 4.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 4.0;
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
