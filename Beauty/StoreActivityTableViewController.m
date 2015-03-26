//
//  StoreActivityTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/26.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "StoreActivityTableViewController.h"
#import "ActivityViewController.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"
#import "Global.h"
#import "CommonUtil.h"
#import "SVProgressHUD.h"
#import "SVPullToRefresh.h"
#import "StoreTableViewCell.h"

@interface StoreActivityTableViewController ()
@property (strong ,nonatomic) NSMutableArray *activityArray;
@property (nonatomic,assign) NSInteger page;
@end

@implementation StoreActivityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tabBarController.tabBar setHidden:YES];
    [CommonUtil updateTableViewHeight:self];
    self.navigationItem.title = @"店铺活动";
    self.activityArray = [NSMutableArray array];
    __weak StoreActivityTableViewController *weakSelf = self;
    [self fetchData:0];
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        weakSelf.page++;
        [weakSelf fetchData:PER_PAGE * weakSelf.page];
        [weakSelf.tableView.infiniteScrollingView stopAnimating];
    }];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void) fetchData:(NSUInteger)skip {
    BmobQuery *activityQuery = [BmobQuery queryWithClassName:@"StoreActivity"];
    activityQuery.limit = PER_PAGE;
    activityQuery.skip = skip;
    //关联查询
    [activityQuery whereKey:@"store" equalTo:[BmobObject objectWithoutDatatWithClassName:@"Store" objectId:self.storeId]];
    
    [activityQuery includeKey:@"store"];
    [activityQuery orderByDescending:@"time"];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array.count == 0) {
//            if (self.page == 0) {
//                self.tableView.hidden = YES;
//                UILabel *label = [[UILabel alloc]initWithFrame:self.tableView.frame];
//                label.textAlignment = NSTextAlignmentCenter;
//                label.textColor = [UIColor grayColor];
//                label.font = [UIFont systemFontOfSize:18.0];
//                label.text = NO_DATAS;
//                [self.tableView.superview addSubview:label];
//            } else {
//                [SVProgressHUD showSuccessWithStatus:NO_MORE];
//            }
            [SVProgressHUD showSuccessWithStatus:NO_MORE];
        } else {
            [self.activityArray addObjectsFromArray:array];
            [self.tableView reloadData];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

    return self.activityArray.count;
}
//一组一个
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

//自定义单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoreTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"StoreTableViewCell" owner:self options:nil]firstObject];
    
    BmobObject *activity = self.activityArray[indexPath.section];
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
- (void)tableView:tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"activityDetail" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ActivityViewController *vc = segue.destinationViewController;
    vc.objectId = [self.activityArray[self.tableView.indexPathForSelectedRow.section]objectId];
}


@end
