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
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface StoreViewController ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>
@property (strong ,nonatomic) NSMutableArray *storeActivityArray;
@property (strong ,nonatomic) NSMutableArray *storeNearByArray;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,assign) NSInteger pageNearBy;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) UITableView *nearByTableView;
//城市中文名
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cityButtonItem;
@property (weak, nonatomic) NSString *cityId;
@end

@implementation StoreViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.cityButtonItem.title = @"";
    self.locationManager = [[CLLocationManager alloc]init];
    [self fetchLoaction];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.storeActivityArray = [NSMutableArray array];
    self.storeNearByArray = [NSMutableArray array];
    [self setup];
        // Do any additional setup after loading the view.
}
- (IBAction)switchCity:(id)sender {
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.locationManager stopUpdatingLocation];
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
                    menu.title = @"附近店铺";
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
                    __weak StoreViewController *weakSelf = self;
                    __weak UITableView *weakTableView = tableView;
                if (i == 0) {
                    [self fetchData:0 tableView:tableView];
                    [tableView addInfiniteScrollingWithActionHandler:^{
                        self.page ++;
                        [weakSelf fetchData:PER_PAGE * self.page tableView:weakTableView];
                        [weakTableView.infiniteScrollingView stopAnimating];
                    }];
                } else {
                    
                    [tableView addInfiniteScrollingWithActionHandler:^{
                        self.pageNearBy ++;
                        [weakSelf fetchNearByData:PER_PAGE * self.pageNearBy tableView:weakTableView];
                        [weakTableView.infiniteScrollingView stopAnimating];
                    }];
                    self.nearByTableView = tableView;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//请求地理位置
- (void)fetchLoaction {
    if([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 500;
        self.locationManager.delegate = self;
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)
        {
            //设置定位权限 仅ios8有意义
            [self.locationManager requestWhenInUseAuthorization];// 前台定位
            
            
        }
        [self.locationManager startUpdatingLocation];
    }else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"未开启定位" message:@"请打开设置-隐私-启用地理位置" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    }
}
//成功获取地理位置
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations lastObject];
    self.coordinate = location.coordinate;
    
    [self convertCityName];
    

    [self.locationManager stopUpdatingLocation];

}

//转换成城市名
- (void)convertCityName {
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    CLLocation *location = [[CLLocation alloc]initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            //获取城市
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
//
            //simulate city name
            city = @"北京市";
            self.cityButtonItem.title = city;
            
//            获取邮编

            BmobQuery *query = [BmobQuery queryWithClassName:@"City"];
            [query whereKey:@"name" equalTo:city];
            NSLog(@"city name : %@",city);
            [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                BmobObject *cityObject = [array firstObject];
                self.cityId = [cityObject objectForKey:@"cityId"];
                //    成功获取了地理定位，才去取的附近店铺
                [self fetchNearByData:0 tableView:self.nearByTableView];
            }];
        }
    }];
    

}
//地理位置获取失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"无法定位" message:@"请打开设置-隐私-启用地理位置" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}
//获取附近商铺活动
- (void)fetchNearByData:(NSUInteger)skip tableView:(UITableView *)tableView {
    BmobQuery *query = [BmobQuery queryWithClassName:@"Store"];
    query.limit = PER_PAGE;
    query.skip = skip;
    
    NSDictionary *condictionCityId = @{@"cityId":self.cityId == nil ? [NSNull null] : self.cityId};
    NSDictionary *condictionCityIdEmpty = @{@"cityId":@""};
    NSDictionary *condictionCityIdNull = @{@"cityId":@{@"$exists":[NSNumber numberWithBool:NO]}};
    
    NSArray *array = @[condictionCityId,condictionCityIdEmpty,condictionCityIdNull];
    [query addTheConstraintByOrOperationWithArray:array];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array.count == 0) {
            if (self.pageNearBy == 0) {
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
            [self.storeNearByArray addObjectsFromArray:array];
            [tableView reloadData];
        }
    }];
}

#pragma mark 获取全部店铺数据
- (void) fetchData:(NSUInteger)skip tableView:(UITableView *)tableView {
    BmobQuery *activityQuery = [BmobQuery queryWithClassName:@"StoreActivity"];
    activityQuery.limit = PER_PAGE;
    activityQuery.skip = skip;
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

#pragma mark 代理方法
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
    if (tableView == self.nearByTableView) {
        NSLog(@"count 1: %zi",self.storeNearByArray.count);
        return self.storeNearByArray.count;
    }
    NSLog(@"count 2: %zi",self.storeActivityArray.count);
    return self.storeActivityArray.count;
}
//一组一个
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

//自定义单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.nearByTableView) {
        BmobObject *store = self.storeNearByArray[indexPath.section];
        return [CommonUtil fetchStoreShowCell:store];
    }
    
    StoreTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"StoreTableViewCell" owner:self options:nil]firstObject];

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
