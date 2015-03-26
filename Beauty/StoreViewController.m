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
#import "KGModal.h"
#import "StoreDetailTableViewController.h"
#import "UserService.h"
#import "MemberLoginViewController.h"

@interface StoreViewController ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>
@property (strong ,nonatomic) NSMutableArray *storeActivityArray;
@property (strong ,nonatomic) NSMutableArray *storeNearByArray;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,assign) NSInteger pageNearBy;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) UITableView *nearByTableView;
@property (nonatomic, strong) UITableView *activityTableView;
//城市中文名
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cityButtonItem;
@property (weak, nonatomic) NSString *cityId;
@property (strong, nonatomic) NSArray *cityArray;
@end

@implementation StoreViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.cityButtonItem.title = @"广州市";
    self.cityId = @"020";
    [self loadCity];
    self.locationManager = [[CLLocationManager alloc]init];
    [self fetchLoaction];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.storeActivityArray = [NSMutableArray array];
    self.storeNearByArray = [NSMutableArray array];
    [self setup];
        // Do any additional setup after loading the view.
}

- (void)loadCity{
    BmobQuery *query = [BmobQuery queryWithClassName:@"City"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        self.cityArray = array;
    }];
}
//点击城市切换
- (IBAction)switchCity:(id)sender {
    CGFloat width = 300.0;
    CGFloat buttonWidth = 80.0;
    CGFloat buttonHeight = 30.0;
    CGFloat buttonMargin = 20.0;
    UIView *cityView = [[UIView alloc]init];
    cityView.backgroundColor = [UIColor whiteColor];
//    标题
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10.0, 0, width, 50.0)];
    label.textColor = MAIN_COLOR;
    label.font = [UIFont systemFontOfSize:18.0];
    label.text = @"请选择城市";
    [cityView addSubview:label];
//    分隔线
    UIView *seperatedView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame), width, 1)];
    seperatedView.backgroundColor = TINYGRAY_COLOR;
    [cityView addSubview:seperatedView];
//    城市列表
    for (int i = 0; i < self.cityArray.count; i++) {
        int column = i  % 3;
        int row = i / 3;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setTitle:[self.cityArray[i]objectForKey:@"name"] forState:UIControlStateNormal];
        button.bounds = CGRectMake(0, 0, buttonWidth, buttonHeight);
        button.center = CGPointMake(width / 3.0 * (column + 0.5), CGRectGetMaxY(seperatedView.frame) + (buttonHeight + buttonMargin) * row + buttonHeight);
        [button addTarget:self action:@selector(oneCityButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        //button border
        button.layer.borderColor = [MAIN_COLOR CGColor];
        button.layer.borderWidth = 1.0;
        button.layer.cornerRadius = 8.0;
        button.tag = i;
        [cityView addSubview:button];
    }
    
    
    cityView.frame = CGRectMake(0, 0, width, CGRectGetMaxY(seperatedView.frame) + buttonMargin + (buttonHeight + buttonMargin) * ceil(self.cityArray.count / 3.0));
    
    [[KGModal sharedInstance]showWithContentView:cityView andAnimated:YES];
    
}
- (void)oneCityButtonPress:(UIButton *)button {
    NSUInteger tag = button.tag;
    self.cityId = [self.cityArray[tag] objectForKey:@"cityId"];
    
    //关闭窗口
    [[KGModal sharedInstance]hideAnimated:YES];
//    清空数据源，同时将页码重新赋值为零
    [self.storeNearByArray removeAllObjects];
    self.pageNearBy = 0;
//    右上角按钮重新赋值
    self.cityButtonItem.title = [self.cityArray[tag] objectForKey:@"name"];
//    获取新数据
    [self fetchNearByData:0 tableView:self.nearByTableView];
    
    //    清空数据源，同时将页码重新赋值为零
    [self.storeActivityArray removeAllObjects];
    self.page = 0;
    //    获取新数据
    [self fetchData:0 tableView:self.activityTableView];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    //    用于新登录后自刷新
    if (self.nearByTableView) {
        [self.nearByTableView reloadData];
    }
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
                    self.activityTableView = tableView;
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
//            city = @"北京市";
            self.cityButtonItem.title = city;
            
//            获取邮编

            BmobQuery *query = [BmobQuery queryWithClassName:@"City"];
            [query whereKey:@"name" equalTo:city];
//            NSLog(@"city name : %@",city);
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
    [SVProgressHUD showErrorWithStatus:@"请进入设置-隐私-启用地理位置"];
}
- (NSArray *)conditionArray {
    NSDictionary *conditionCityId = @{@"cityId":self.cityId == nil ? [NSNull null] : self.cityId};
    NSDictionary *conditionCityIdEmpty = @{@"cityId":@""};
    NSDictionary *conditionCityIdNull = @{@"cityId":@{@"$exists":[NSNumber numberWithBool:NO]}};
    
    NSArray *array = @[conditionCityId,conditionCityIdEmpty,conditionCityIdNull];
    return array;
}
//获取附近商铺活动
- (void)fetchNearByData:(NSUInteger)skip tableView:(UITableView *)tableView {
    BmobQuery *query = [BmobQuery queryWithClassName:@"Store"];
    query.limit = PER_PAGE;
    query.skip = skip;
    

    [query addTheConstraintByOrOperationWithArray:[self conditionArray]];
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

#pragma mark 获取全部活动数据
- (void) fetchData:(NSUInteger)skip tableView:(UITableView *)tableView {
    BmobQuery *inQuery = [BmobQuery queryWithClassName:@"Store"];
    [inQuery addTheConstraintByOrOperationWithArray:[self conditionArray]];
    BmobQuery *activityQuery = [BmobQuery queryWithClassName:@"StoreActivity"];
    activityQuery.limit = PER_PAGE;
    activityQuery.skip = skip;
    //关联查询
    [activityQuery whereKey:@"store" matchesQuery:inQuery];
    
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
//        NSLog(@"count nearby store: %zi",self.storeNearByArray.count);
        return self.storeNearByArray.count;
    }
//    NSLog(@"count activity: %zi",self.storeActivityArray.count);
    return self.storeActivityArray.count;
}
//一组一个
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (void)switchFavor:(UIButton *)button {
    UserService *service = [UserService getInstance];
    [service favorButtonPress:[self.storeNearByArray[button.tag] objectId] successBlock:^{
        [self.nearByTableView reloadSections:[NSIndexSet indexSetWithIndex:button.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
    } failBlock:^{
        MemberLoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}
//自定义单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.nearByTableView) {
        BmobObject *store = self.storeNearByArray[indexPath.section];
        StoreShowTableViewCell *cell = [CommonUtil fetchStoreShowCell:store];
//        判断收藏与否
        UserService *service = [UserService getInstance];
        [service actionWithUser:^(BmobUser *user) {
                BmobQuery *storeQuery = [BmobQuery queryWithClassName:@"Store"];
                [storeQuery whereObjectKey:@"relStoreCollect" relatedTo:user];
//                从当前会员下所有收藏店铺中遍历，看是否找到当前单元格的遍历
                [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                    for (int i = 0; i < array.count; i ++) {
                        if ([[array[i] objectId] isEqualToString:[store objectId]]) {
                            [cell.favorButton setTitle:@"取消收藏" forState:UIControlStateNormal];
                            break;
                            
                        } else {
                            [cell.favorButton setTitle:@"收藏" forState:UIControlStateNormal];
                        }
                    }
                }];
        } failBlock:^{
            
        }];
        cell.favorButton.tag = indexPath.section;
        [cell.favorButton addTarget:self action:@selector(switchFavor:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
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
    if (tableView == self.nearByTableView) {
        return 130.0;
    }
    return 110.0;
}

//单击单元格
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.activityTableView) {
        [self performSegueWithIdentifier:@"activity" sender:self];
    } else {
        [self performSegueWithIdentifier:@"storeDetail" sender:self];
    }
//    NSLog(@"select id %@",[self.storeActivityArray[indexPath.section] objectId]);
}

/**
 Segue 跳转，传参
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"activity"]) {
        
        ActivityViewController *activityVC = (ActivityViewController *)segue.destinationViewController;
        activityVC.objectId = [self.storeActivityArray[self.activityTableView.indexPathForSelectedRow.section] objectId];
    } else if ([segue.identifier isEqualToString:@"storeDetail"]) {
        StoreDetailTableViewController *storeVC = segue.destinationViewController;
        storeVC.storeId = [self.storeNearByArray[self.activityTableView.indexPathForSelectedRow.section] objectId];

    }
}

@end
