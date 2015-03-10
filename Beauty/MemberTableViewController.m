//
//  MemberTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/10.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "MemberTableViewController.h"
#import <BmobSDK/Bmob.h>

@interface MemberTableViewController ()
@property (weak, nonatomic) IBOutlet UIButton *nicknameButton;


@property (weak, nonatomic) IBOutlet UIButton *tryCountButton;
@property (weak, nonatomic) IBOutlet UIButton *collectCountButton;
@property (weak, nonatomic) IBOutlet UIButton *tryButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;

@end

@implementation MemberTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchUser];
    
}
- (void)fetchUser {
    NSString *username = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
    if (username) {
        [self.loginButton setTitle:@"退出登录" forState:UIControlStateNormal];
        //        获取收藏数
        BmobQuery *query = [BmobUser query];
        [query whereKey:@"username" equalTo:username];
        //通过用户手机号码获得用户信息
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            if (error) {
                NSLog(@"%@",error);
            } else {
                BmobObject *user = [array firstObject];
                //获取user基本信息
                [self.nicknameButton setTitle:[user objectForKey:@"nickname"] forState:UIControlStateNormal];
                
;
                //                产品收藏
                BmobQuery *productQuery = [BmobQuery queryWithClassName:@"Product"];
                [productQuery whereObjectKey:@"relProductCollect" relatedTo:user];
                [productQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                    for (BmobObject *product in array) {
                        NSLog(@"%@",[product objectForKey:@"name"]);
                    }
                }];
                //                店铺收藏
                BmobQuery *storeQuery = [BmobQuery queryWithClassName:@"Store"];
                [storeQuery whereObjectKey:@"relStoreCollect" relatedTo:user];
                [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                    for (BmobObject *product in array) {
                        NSLog(@"%@",[product objectForKey:@"name"]);
                    }
                }];
    
                
            }
        }];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
