//
//  WechatProductDetailTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/11.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "WechatProductDetailTableViewController.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"
#import "ProductDetailTableViewController.h"
#import "WechatRecordViewController.h"

@interface WechatProductDetailTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextView *descriptTextView;
@property (weak, nonatomic) IBOutlet UIWebView *webUrlwebView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation WechatProductDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self fetchProduct];
}

- (void)fetchProduct {
    BmobQuery *query = [BmobQuery queryWithClassName:@"WechatProduct"];
    [query includeKey:@"product"];
    [query getObjectInBackgroundWithId:[[NSUserDefaults standardUserDefaults]objectForKey:@"wechatProductId"] block:^(BmobObject *object, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
//            获取头像
            BmobFile *avatarFile = [object objectForKey:@"avatar"];
            [self.avatarImageView setImageWithURL:[NSURL URLWithString:avatarFile.url]];
//            关联查询产品名称
            self.nameLabel.text = [[object objectForKey:@"product"]objectForKey:@"name"];
//            简介
            self.descriptTextView.text = [object objectForKey:@"descript"];
//            网页
            [self.webUrlwebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[object objectForKey:@"webUrl"]]]];
//            产品id，以备跳转时传值用
            self.productId = [[object objectForKey:@"product"]objectId];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)submit:(id)sender {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"username"]) {
        [self performSegueWithIdentifier:@"submit" sender:self];
    } else {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // 共有两条连线，只有跳转往产品详情页时才传productId值
    if ([segue.identifier isEqualToString:@"productDetail"]) {
        
        ProductDetailTableViewController *vc = segue.destinationViewController;
        vc.productId = self.productId;
    } else if ([segue.identifier isEqual:@"submit"]) {        
        WechatRecordViewController *vc = segue.destinationViewController;
        vc.productId = self.productId;
    }
}
@end
