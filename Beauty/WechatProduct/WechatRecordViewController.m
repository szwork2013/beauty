//
//  WechatRecordViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/12.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "WechatRecordViewController.h"
#import <BmobSDK/Bmob.h>
#import "UserService.h"
#import "SVProgressHUD.h"

/**
 申请代理
 */
@interface WechatRecordViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sexSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;

@end

@implementation WechatRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)formValid {
    if ([self.nameTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请填写姓名"];
        return NO;
    }
    if ([self.mobileTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请填写手机"];
        return NO;
    }
    return YES;
}

- (IBAction)submit:(id)sender {
    if (![self formValid]) {
        return;
    }
//    封装array
    NSMutableArray *formContent = [NSMutableArray array];
    NSString *username = [NSString stringWithFormat:@"姓名:%@",self.nameTextField.text];
    [formContent addObject:username];
    NSString *sex = [NSString stringWithFormat:@"性别:%@",[self.sexSegmentedControl titleForSegmentAtIndex:self.sexSegmentedControl.selectedSegmentIndex]];
    [formContent addObject:sex];
    NSString *mobile = [NSString stringWithFormat:@"电话:%@",self.mobileTextField.text];
    [formContent addObject:mobile];
    
    UserService *service = [UserService getInstance];
    [service actionWithUser:^(BmobUser *user) {
        //添加申请信息
        BmobObject *wechatRecord = [BmobObject objectWithClassName:@"WechatRecord"];
        [wechatRecord setObject:user forKey:@"user"];
        [wechatRecord setObject:[BmobObject objectWithoutDatatWithClassName:@"WechatProduct" objectId:self.productId] forKey:@"wechatProduct"];
        [wechatRecord setObject:formContent forKey:@"formContent"];
        [wechatRecord setObject:[NSNumber numberWithInt:0] forKey:@"state"];
        [wechatRecord saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (error) {
                NSLog(@"%@",error);
            } else if (isSuccessful) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"申请成功" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
                
                
            }
        }];

    }];  
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
