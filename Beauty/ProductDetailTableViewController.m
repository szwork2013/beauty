//
//  ProductDetailTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/5.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "ProductDetailTableViewController.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"
#import "StarView.h"
#import "WebViewBrowserController.h"
#import "ProductSellerDataSource.h"

@interface ProductDetailTableViewController ()
@property (nonatomic,weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UILabel *commentLabel;
@property (nonatomic,weak) IBOutlet UILabel *averagePrice;
@property (nonatomic,weak) IBOutlet UIView *starView;
@property (nonatomic,strong) ProductSellerDataSource *productSellerDataSource;
@end

@implementation ProductDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"产品信息";

    [self fetchProduct];
    self.productSellerDataSource = [[ProductSellerDataSource alloc]initWithViewController:self];
    self.sellerTableView.dataSource = self.productSellerDataSource;
    self.sellerTableView.delegate = self.productSellerDataSource;
}


//获取产品数据
- (void)fetchProduct {
    BmobQuery *query = [BmobQuery queryWithClassName:@"Product"];
    [query getObjectInBackgroundWithId:self.productId block:^(BmobObject *object, NSError *error) {
        BmobFile *image = [object objectForKey:@"avatar"];
        [self.avatarImageView setImageWithURL:[NSURL URLWithString:image.url]];
        self.nameLabel.text = [object objectForKey:@"name"];
        self.commentLabel.text = [[object objectForKey:@"commentCount"]stringValue];
        self.averagePrice.text = [[object objectForKey:@"averagePrice"]stringValue];
        
        StarView *view = [[StarView alloc]initWithCount:[object objectForKey:@"mark"] frame:CGRectMake(0, 0, 55.0, 11.0)];
        [self.starView addSubview:view];
    }];
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 1) {
        return self.productSellerDataSource.sellerArray.count * 100.0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    WebViewBrowserController *vc = segue.destinationViewController;
    vc.urlString = self.urlString;
}


@end
