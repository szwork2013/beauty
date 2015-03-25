//
//  MemberTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/10.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "MemberTableViewController.h"
#import <BmobSDK/Bmob.h>
#import "UserService.h"
#import "MyTryViewController.h"
#import "MyCollectViewController.h"
#import "MemberLoginViewController.h"

@interface MemberTableViewController ()
@property (weak, nonatomic) IBOutlet UIButton *nicknameButton;


@property (weak, nonatomic) IBOutlet UIButton *tryCountButton;
@property (weak, nonatomic) IBOutlet UIButton *collectCountButton;
@property (weak, nonatomic) IBOutlet UIButton *tryButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;

@property (assign, nonatomic) NSUInteger collectCount;
@end

@implementation MemberTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset=UIEdgeInsetsMake(-36, 0, 0, 0);
    
}
-(void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
    [super viewWillAppear:animated];
    self.collectCount = 0;
    
    [self fetchUser];
    
}
- (void)fetchUser {
    UserService *service = [UserService getInstance];
    [service actionWithUser:^(BmobUser *user) {
            [self.loginButton setTitle:@"退出登录" forState:UIControlStateNormal];
            [self.nicknameButton setTitle:[user objectForKey:@"nickname"] forState:UIControlStateNormal];
            //                产品收藏
            BmobQuery *productQuery = [BmobQuery queryWithClassName:@"Product"];
            [productQuery whereObjectKey:@"relProductCollect" relatedTo:user];
            [productQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                if (error) {
                    NSLog(@"%@",error);
                } else {
                    self.collectCount += number;
                    [self.collectCountButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)self.collectCount] forState:UIControlStateNormal];
                }
            }];
            //                店铺收藏
            BmobQuery *storeQuery = [BmobQuery queryWithClassName:@"Store"];
            [storeQuery whereObjectKey:@"relStoreCollect" relatedTo:user];
            [storeQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                self.collectCount += number;
                [self.collectCountButton setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)self.collectCount] forState:UIControlStateNormal];
            }];
            //试用
            BmobQuery *tryQuery = [BmobQuery queryWithClassName:@"TryRecord"];
            [tryQuery whereKey:@"user" equalTo:user];
            [tryQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                [self.tryCountButton setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateNormal];
            }];
    } failBlock:^{
        
    }];
}

//退出或登录按钮
- (IBAction)loginButtonPress:(id)sender {
    UserService *service = [UserService getInstance];
    [service actionWithUser:^(BmobUser *user) {

            [BmobUser logout];
            //        还差一个修改头像的变成原来的
            [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
            [self.nicknameButton setTitle:@"点击头像登录" forState:UIControlStateNormal];
            [self.tryCountButton setTitle:@"0" forState:UIControlStateNormal];
            [self.collectCountButton setTitle:@"0" forState:UIControlStateNormal];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"退出成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        
        
    } failBlock:^{
        [self performSegueWithIdentifier:@"login" sender:self];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 1) {
        UserService *service = [UserService getInstance];
        [service actionWithUser:^(BmobUser *user) {
            MyTryViewController *vc = [[MyTryViewController alloc]init];
            vc.user = user;
            [self.navigationController pushViewController:vc animated:YES];
            
        } failBlock:^{
            MemberLoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        UserService *service = [UserService getInstance];
        [service actionWithUser:^(BmobUser *user) {
            MyCollectViewController *vc = [[MyCollectViewController alloc]init];
            vc.user = user;
            [self.navigationController pushViewController:vc animated:YES];
            
        } failBlock:^{
            MemberLoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
}
@end
