//
//  ProductTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/5.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "ProductTableViewController.h"
#import "ProductTableViewCell.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"
#import "ProductDetailTableViewController.h"


@interface ProductTableViewController ()
@property (strong,nonatomic) NSArray *productArray;

@end

@implementation ProductTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchProduct];
    [self fetchTitle];
}
-(void) fetchTitle{
    BmobQuery *query = [BmobQuery queryWithClassName:@"ProductSecondLevel"];
    [query getObjectInBackgroundWithId:self.secondLevelId block:^(BmobObject *object, NSError *error) {
        self.navigationItem.title = [object objectForKey:@"name"];;
    }];
    
}

- (void)fetchProduct {
    self.productArray = [NSArray array];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Product"];
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:@"ProductSecondLevel" objectId:self.secondLevelId];
    [bquery whereObjectKey:@"products" relatedTo:obj];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        self.productArray = array;
        [self.tableView reloadData];
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
    ProductTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductTableViewCell" owner:self options:nil]firstObject];
    BmobObject *product = self.productArray[indexPath.row];
    BmobFile *avatar = [product objectForKey:@"avatar"];
    [cell.thumbImageView setImageWithURL:[NSURL URLWithString:avatar.url]];
    cell.titleLabel.text = [product objectForKey:@"name"];
    cell.commentCountLabel.text = [[product objectForKey:@"commentCount"]stringValue];
    cell.averagePriceLabel.text = [[product objectForKey:@"averagePrice"]stringValue];
    //    评分星级
    NSNumber *starFullNum = [NSNumber numberWithInteger:ceil([[product objectForKey:@"mark"]floatValue])];
    CGFloat width = 9.0;
    CGFloat height = 9.0;
    CGFloat margin = 2.0;
    for (int i = 0; i <= 4; i++) {
        UIImageView *emptyImageView = [[UIImageView alloc]initWithFrame:CGRectMake((width + margin) * i, 0, width, height)];
        [emptyImageView setImage:[UIImage imageNamed:@"star_empty"]];
        [cell.starView addSubview:emptyImageView];
    }
    //    NSLog(@"%@ %@",[product objectForKey:@"mark"],starFullNum);
    for (int i = 0; i < [starFullNum intValue]; i++) {
        UIImageView *fullImageView = [[UIImageView alloc]initWithFrame:CGRectMake((width + margin) * i, 0, width, height)];
        [fullImageView setImage:[UIImage imageNamed:@"star_full"]];
        [cell.starView addSubview:fullImageView];
    }
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
