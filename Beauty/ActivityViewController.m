//
//  ActivityViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/1.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "ActivityViewController.h"
#import <BmobSDK/Bmob.h>
#import <BmobSDK/BmobProFile.h>

#import "SVProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "StoreDetailTableViewController.h"

#define SECTION_IMAGE 1
#define SECTION_WEBVIEW 2
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
//#define IMAGE_HEIGHT (SCREEN_WIDTH * 0.64)
#define IMAGE_HEIGHT 137.0

@interface ActivityViewController ()<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITableView *activityTableView;
@property (strong, nonatomic) NSArray *activityArray;
@property (strong, nonatomic) NSString *shopObjectId;
@end

@implementation ActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activityTableView.dataSource = self;
    self.activityTableView.delegate = self;
    [self fetch];
//    [self testImageView];
}
-(void) testImageView {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 120)];
    [imageView setImageWithURL:[NSURL URLWithString:@"http://lorempixel.com/700/256/fashion/1/"]];
    [self.view addSubview:imageView];
}
//从Bmob上获取数据
- (void)fetch {
    BmobQuery *activityQuery = [BmobQuery queryWithClassName:@"StoreActivity"];
    [activityQuery includeKey:@"store"];
    [activityQuery getObjectInBackgroundWithId:self.objectId block:^(BmobObject *object,NSError *error){
        if (error){
            NSLog(@"error:%@",error);
            [SVProgressHUD showErrorWithStatus:@"获取失败"];
        }else{
            if (object) {
//                活动标题
                self.nameLabel.text = [object objectForKey:@"name"];
//                为数据源赋值
                NSMutableArray *dataArray = [NSMutableArray array];
                [dataArray addObject:[[object objectForKey:@"store"]objectForKey:@"name"]];
                [dataArray addObject:[object objectForKey:@"images"]];
                [dataArray addObject:[object objectForKey:@"webUrl"]];
                self.activityArray = dataArray;
                self.shopObjectId = [[object objectForKey:@"store"] objectId];
                [self.activityTableView reloadData];
            }
        }
    }];
}
#pragma mark - tableview 代理方法
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
//每组单元格个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //第2组是图片列表
    if (section == SECTION_IMAGE) {
        return [self.activityArray[SECTION_IMAGE] count];
    }
    //第1、3组分别是店铺与UIWebView
    return 1;
}
//生成单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"name"];
    
//            店铺名称
    if (indexPath.section == 0) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = self.activityArray[indexPath.section];
//        活动图片
    }else if (indexPath.section == SECTION_IMAGE) {
        NSUInteger margin = 5;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(margin, margin, SCREEN_WIDTH - 2 * margin, IMAGE_HEIGHT)];
        NSString *imageUrl = self.activityArray[SECTION_IMAGE][indexPath.row];
        [BmobImage thumbnailImageBySpecifiesTheLength:SCREEN_WIDTH * 2 quality:100 sourceImageUrl:imageUrl outputType:kBmobImageOutputBmobFile resultBlock:^(id object, NSError *error) {
            BmobFile *imageFile = (BmobFile *)object;
            [imageView setImageWithURL:[NSURL URLWithString:imageFile.url]];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [cell addSubview:imageView];
        }];
        
    }else if (indexPath.section == SECTION_WEBVIEW) {
        UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1391.0)];
//        webView.delegate = self;
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.activityArray[SECTION_WEBVIEW]]]];
        [cell addSubview:webView];
    }

    return cell;
}
//分组名称
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return @"图片详情";
            break;
            
        default:
            break;
    }
    return nil;
}

#pragma mark - tableView delegate

//单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == SECTION_IMAGE) {
        return IMAGE_HEIGHT + 10.0;
    }else if (indexPath.section == SECTION_WEBVIEW) {


        return 1391.0;
    }
    return 55.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIWebView 代理方法
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *height_str= [webView stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"];
    int height = [height_str intValue];
    webView.frame = CGRectMake(0,0,SCREEN_WIDTH,height);
}

//单击单元格
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"storeDetail" sender:self];
    }
}

#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    StoreDetailTableViewController *storeDetailVC = (StoreDetailTableViewController *)segue.destinationViewController;
    storeDetailVC.shopObjectId = self.shopObjectId;
}


@end
