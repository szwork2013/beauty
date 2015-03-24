//
//  ProductTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/5.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "ProductTableViewController.h"
#import "ProductTryTableViewCell.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"
#import "ProductDetailTableViewController.h"
#import "StarView.h"
#import "Global.h"
#import "SVPullToRefresh.h"
#import "SVProgressHUD.h"

@interface ProductTableViewController ()
@property (strong,nonatomic) NSMutableArray *productArray;
@property (nonatomic,assign) NSInteger page;
@end

@implementation ProductTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchTitle];
    self.productArray = [NSMutableArray array];
    [self fetchProduct:self.page];
//    添加无限上拉刷新
    __weak ProductTableViewController *weakSelf = self;
    __weak UITableView *weakTableView = self.tableView;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        weakSelf.page ++;
        [weakSelf fetchProduct:PER_PAGE * weakSelf.page];
        [weakTableView.infiniteScrollingView stopAnimating];
    }];
}

-(void) fetchTitle{
    BmobQuery *query = [BmobQuery queryWithClassName:@"ProductSecondLevel"];
    [query getObjectInBackgroundWithId:self.secondLevelId block:^(BmobObject *object, NSError *error) {
        self.navigationItem.title = [object objectForKey:@"name"];;
    }];
    
}

- (void)fetchProduct:(NSInteger)skip {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Product"];
    bquery.skip = skip;
    bquery.limit = PER_PAGE;
    
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:@"ProductSecondLevel" objectId:self.secondLevelId];
    [bquery whereObjectKey:@"products" relatedTo:obj];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array.count == 0) {
            if (self.page == 0) {
                [SVProgressHUD showSuccessWithStatus:NO_DATAS];
            } else {
                [SVProgressHUD showSuccessWithStatus:NO_MORE];
            }
        }else{
            [self.productArray addObjectsFromArray: array];
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.productArray.count;
}

//自定义单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductTryTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductTableViewCell" owner:self options:nil]lastObject];
    BmobObject *product = self.productArray[indexPath.row];
    BmobFile *avatar = [product objectForKey:@"avatar"];
    [cell.thumbImageView setImageWithURL:[NSURL URLWithString:avatar.url]];
    //缩略图加圆角边框
    cell.thumbImageView.layer.cornerRadius = 40.0;
    cell.thumbImageView.layer.borderColor = [TINYGRAY_COLOR CGColor];
    cell.thumbImageView.layer.borderWidth = 1.0;
    cell.nameLabel.text = [product objectForKey:@"name"];
    cell.commentCountLabel.text = [[product objectForKey:@"commentCount"]stringValue];
    
    cell.averagePriceLabel.text = [NSString stringWithFormat:@"%.1f",[[product objectForKey:@"averagePrice"]floatValue]];
    //        评分星级
    StarView *view = [[StarView alloc]initWithCount:[product objectForKey:@"mark"] frame:CGRectMake(0, 0, 55.0, 11.0)];
    [cell.starView addSubview:view];
    return cell;

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"productDetail" sender:self];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ProductDetailTableViewController *vc = segue.destinationViewController;
    vc.productId = [self.productArray[self.tableView.indexPathForSelectedRow.row] objectId];
}


@end
