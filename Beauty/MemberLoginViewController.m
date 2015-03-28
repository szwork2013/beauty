//
//  MemberLoginViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/10.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "MemberLoginViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import <BmobSDK/Bmob.h>
#import "SVProgressHUD.h"

@interface MemberLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextFiled;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSTimer * timer;
@property (assign, nonatomic) int timerNum;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UIButton *fetchButton;
@end

@implementation MemberLoginViewController
-(BOOL)isValidateMobile:(NSString *)mobile{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(17[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    
    if (![phoneTest evaluateWithObject:mobile]) {
        return NO;
    }
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (NSString *)createCode {
    NSString *code = [NSString stringWithFormat:@"%d",arc4random() % 9000 + 1000];
    self.code = code;
    return code;
}

-(void)timerClock{
    self.numLabel.text = [NSString stringWithFormat:@"重发(%d)",--self.timerNum];
    
    if (self.timerNum == 0) {
        self.numLabel.hidden = YES;
        self.fetchButton.hidden = NO;
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}


- (IBAction)fetchCode:(UIButton *)sender {
    
    
    if ([self isValidateMobile:self.phoneTextField.text]) {

        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:[NSString stringWithFormat:@"http://120.24.158.159:8090/sendSMS/%@/%@",self.phoneTextField.text,[self createCode]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self regist];
            [SVProgressHUD showSuccessWithStatus:@"验证码已发送"];
//            并且开始倒数
            //        显示重发倒计时按钮
            self.timerNum = 60;
            sender.hidden = YES;
            self.numLabel.hidden = NO;
            //获取验证码，重发
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerClock) userInfo:nil repeats:YES];
            if ([self.timer isValid]) {
                [self.timer setFireDate:[NSDate date]];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"验证码发送失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"手机号码不正确" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)regist {
    BmobQuery *query = [BmobUser query];
    [query whereKey:@"username" equalTo:self.phoneTextField.text];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            if (number <= 0) {
                BmobUser *bUser = [[BmobUser alloc] init];
                [bUser setUserName:self.phoneTextField.text];
                [bUser setPassword:self.phoneTextField.text];
                [bUser signUpInBackground];
            }
        }
    }];
}

- (IBAction)loginPress:(id)sender {
    
    if ([self.code isEqualToString:self.codeTextFiled.text]) {
//        [BmobUser logout];
//        [BmobUser loginWithUsernameInBackground:self.phoneTextField.text password:self.phoneTextField.text];
        [BmobUser loginWithUsernameInBackground:self.phoneTextField.text password:self.phoneTextField.text block:^(BmobUser *user, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"登录失败" message:@"用户名或密码不正确" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"验证码不正确" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
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
