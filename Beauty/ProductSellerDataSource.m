//
//  ProductSellerDataSource.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/6.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "ProductSellerDataSource.h"
#import <BmobSDK/Bmob.h>
#import "SellerTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation ProductSellerDataSource
-(instancetype)initWithViewController:(ProductDetailTableViewController *)vc{
    self.sellerArray = [NSArray array];
    if ([self init]) {
        self.vc = vc;
        BmobQuery *query = [BmobQuery queryWithClassName:@"ProductSeller"];
        [query includeKey:@"seller"];
        [query whereKey:@"product" equalTo:[BmobObject objectWithoutDatatWithClassName:@"Product" objectId:vc.productId]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            if (error) {
                NSLog(@"%@",error);
            }else{
                self.sellerArray = array;
                [vc.sellerTableView reloadData];
            }
        }];
    }
    return self;
}

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sellerArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SellerTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"SellerTableViewCell" owner:self options:nil]firstObject];
    BmobObject *seller = self.sellerArray[indexPath.row];
    BmobFile *avatar = [[seller objectForKey:@"seller"]objectForKey:@"avatar"];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:avatar.url]];
    cell.nameLabel.text = [[seller objectForKey:@"seller"]objectForKey:@"name"];
    cell.priceLabel.text = [[seller objectForKey:@"price"]stringValue];
    cell.descriptLabel.text = [seller objectForKey:@"descript"];
    cell.buyButton.tag = indexPath.row;
    [cell.buyButton addTarget:self action:@selector(jumpWebView:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (void)jumpWebView:(UIButton *)button{
//    给VC的urlString赋值
    self.vc.urlString = [self.sellerArray[button.tag] objectForKey:@"url"];
    [self.vc performSegueWithIdentifier:@"webView" sender:self];
}
@end
