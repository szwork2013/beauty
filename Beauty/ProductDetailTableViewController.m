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
#import "SellerTableViewCell.h"
#import "WebViewBrowserController.h"

@interface ProductDetailTableViewController ()
@property (nonatomic,weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UILabel *commentLabel;
@property (nonatomic,weak) IBOutlet UILabel *averagePrice;
@property (nonatomic,weak) IBOutlet UIView *starView;
//推荐商家列表
@property (nonatomic,weak) IBOutlet UITableView *sellerTableView;


//商家列表数据源
@property (nonatomic,strong) NSArray *sellerArray;
@end

@implementation ProductDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"产品信息";
//    self.tableView.dataSource = nil;
    [self fetchSeller];
    [self fetchProduct];
}

//获取商家数据

- (void)fetchSeller {
    self.sellerArray = [NSArray array];
    BmobQuery *query = [BmobQuery queryWithClassName:@"ProductSeller"];
    
    [query includeKey:@"seller"];
    [query whereObjectKey:@"product" relatedTo:[BmobObject objectWithoutDatatWithClassName:@"Product" objectId:self.productId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            self.sellerArray = array;
        }
    }];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
//#pragma mark - Table view data source
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
////    if (tableView == self.sellerTableView) {
//        return self.sellerArray.count;
////    }
////    return 1;
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    SellerTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"SellerTableViewCell" owner:self options:nil]firstObject];
//    
////    cell.avatarImageView setImageWithURL:<#(NSURL *)#>
//    BmobObject *seller = self.sellerArray[indexPath.row];
//    cell.nameLabel.text = [[seller objectForKey:@"seller"]objectForKey:@"name"];
//    cell.priceLabel.text = [[seller objectForKey:@"price"]stringValue];
//    cell.descriptLabel.text = [seller objectForKey:@"descipt"];
//
//    [cell.buyButton addTarget:self action:@selector(jumpWebView) forControlEvents:UIControlEventTouchUpInside];
//    
//    return cell;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 100.0;
//}

- (void)jumpWebView{
    [self performSegueWithIdentifier:@"webView" sender:self];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    WebViewBrowserController *vc = segue.destinationViewController;
    vc.urlString = [self.sellerArray[self.sellerTableView.indexPathForSelectedRow.row]objectForKey:@"urlString"];
}


@end
