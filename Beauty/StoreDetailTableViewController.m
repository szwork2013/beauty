//
//  StoreDetailTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/2.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "StoreDetailTableViewController.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"
#import "CommonUtil.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ImageBrowserViewController.h"
#import "SVProgressHUD.h"
#import "UserService.h"
#import "MemberLoginViewController.h"
#import "CommonDetailTableViewController.h"

@interface StoreDetailTableViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *imagesScrollView;
@property (strong, nonatomic) NSArray *imageArray;
//服务器抓取的数据
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *favorButton;
@property (weak, nonatomic) IBOutlet UILabel *businessHour;
@property (weak, nonatomic) IBOutlet UITextView *descriptTextView;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

//描述高度
@property (assign, nonatomic) CGFloat descriptHeight;

//拨号
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation StoreDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"店铺";
    self.tableView.contentInset=UIEdgeInsetsMake(-36, 0, 0, 0);
    self.tabBarController.tabBar.hidden = YES;
    [self fetchStoreData];
    self.callButton.layer.borderColor = [[UIColor colorWithRed:158.0/255.0 green:122.0/255.0 blue:183.0/255.0 alpha:1.0]CGColor];
    self.callButton.layer.borderWidth = 1.0;
    self.callButton.layer.cornerRadius = 5.0;
//    分页控件
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    
    self.imagesScrollView.delegate = self;
    
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CommonUtil updateTableViewHeight:self];
//    刷新收藏按钮是否是已经收藏
    [self fetchFavorStatus];
}
//可封装到UserService
-(void)fetchFavorStatus {
    BmobObject *store = [BmobObject objectWithoutDatatWithClassName:@"Store" objectId:self.storeId];

    //        判断收藏与否
    UserService *service = [UserService getInstance];
    [service actionWithUser:^(BmobUser *user) {
        BmobQuery *storeQuery = [BmobQuery queryWithClassName:@"Store"];
        [storeQuery whereObjectKey:@"relStoreCollect" relatedTo:user];
        //                从当前会员下所有收藏店铺中遍历，看是否找到当前单元格的遍历
        [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            for (int i = 0; i < array.count; i ++) {
                if ([[array[i] objectId] isEqualToString:[store objectId]]) {
                    [self.favorButton setTitle:@"取消收藏" forState:UIControlStateNormal];
                    break;
                } else {
                    [self.favorButton setTitle:@"收藏" forState:UIControlStateNormal];
                }
            }
        }];
    } failBlock:^{
        
    }];

}
//收藏店铺按钮
- (IBAction)favorButtonPress:(id)sender {
    UserService *service = [UserService getInstance];
    
    [service favorButtonPress:self.storeId successBlock:^{
        //更新当前按钮
        if ([self.favorButton.titleLabel.text isEqualToString:@"收藏"]) {
            [self.favorButton setTitle:@"取消收藏" forState:UIControlStateNormal];
        } else {
            [self.favorButton setTitle:@"收藏" forState:UIControlStateNormal];
        }

    } failBlock:^{
        MemberLoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}


#pragma mark - 服务器抓取
- (void)fetchStoreData {
    BmobQuery *storeQuery = [BmobQuery queryWithClassName:@"Store"];
    [storeQuery getObjectInBackgroundWithId:self.storeId block:^(BmobObject *object, NSError *error) {
        
        self.nameLabel.text         = [object objectForKey:@"name"];
        self.businessHour.text      = [object objectForKey:@"businessHour"];
        self.phoneLabel.text        = [object objectForKey:@"phone"];
        self.addressLabel.text      = [object objectForKey:@"address"];
//        店铺简介，使用富文本
        self.descriptTextView.attributedText = [[NSAttributedString alloc] initWithString:[object objectForKey:@"descript"] attributes:[CommonUtil textViewAttribute]];
        [self.descriptTextView sizeToFit];
//        取得高度
        self.descriptHeight = self.descriptTextView.frame.size.height + 8;
        [self.tableView reloadData];
        //banner
        CGFloat imageWidth = SCREEN_WIDTH;
        CGFloat imageHeight = 180.0;
        NSArray *imagesArray = [object objectForKey:@"images"];
        self.imageArray = imagesArray;
        self.imagesScrollView.contentSize = CGSizeMake(imageWidth * imagesArray.count, imageHeight);
        self.imagesScrollView.showsHorizontalScrollIndicator = NO;
        self.imagesScrollView.showsVerticalScrollIndicator = NO;
        for (int i = 0; i < imagesArray.count; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageWidth * i, 0, imageWidth, imageHeight)];
            [imageView setImageWithURL:[NSURL URLWithString:imagesArray[i]]];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [self.imagesScrollView addSubview:imageView];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.tag = i;
            button.bounds = imageView.frame;
            button.center = imageView.center;
            [button addTarget:self action:@selector(imagePress:) forControlEvents:UIControlEventTouchUpInside];
            [self.imagesScrollView addSubview:button];
            
        }

        
//        设置分页控件
        self.pageControl.numberOfPages = imagesArray.count;
//        获取地图区域
        self.mapView.mapType = MKMapTypeStandard;
        self.mapView.showsUserLocation = YES;
        BmobGeoPoint *point = [object objectForKey:@"location"];
        CLLocationCoordinate2D center = {point.latitude,point.longitude};
        MKCoordinateSpan span;
        span.latitudeDelta = 0.01;
        span.longitudeDelta = 0.01;
        MKCoordinateRegion region = {center,span};
        [self.mapView setRegion:region animated:YES];
        
        [self.tableView reloadData];
// 添加标注
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
        annotation.coordinate = center;
        [self.mapView addAnnotation:annotation];
    }];
}
- (void)imagePress:(UIButton *)button {
    //        点击图片跳转浏览器
    ImageBrowserViewController *vc = [[ImageBrowserViewController alloc]init];
            vc.selectedIndex = button.tag;
    vc.imageArray = self.imageArray;
    [self.navigationController pushViewController:vc animated:YES];
}
//滚动代理
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentPage = (int)scrollView.contentOffset.x / scrollView.frame.size.width;
    self.pageControl.currentPage = currentPage;
}
//高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    描述TextView
    if (indexPath.section == 1 && indexPath.row == 1) {
        return self.descriptHeight;
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark 单元格点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 0) {
        CommonDetailTableViewController *vc = [[UIStoryboard storyboardWithName:@"Product" bundle:nil] instantiateViewControllerWithIdentifier:@"commonDetail"];
        vc.objectId = self.storeId;
        vc.className = @"Store";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)callMe:(id)sender {
    NSString *telStr = self.phoneLabel.text;
    if (![telStr isEqualToString:@""]) {
        NSString *telUrlStr = [NSString stringWithFormat:@"telprompt:%@",telStr];
        NSURL *url = [NSURL URLWithString:telUrlStr];
        [[UIApplication sharedApplication]openURL:url];
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
