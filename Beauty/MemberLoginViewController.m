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

@interface MemberLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextFiled;
@property (strong, nonatomic) NSString *code;
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
- (IBAction)fetchCode:(id)sender {
    
    
    if ([self isValidateMobile:self.phoneTextField.text]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:[NSString stringWithFormat:@"http://120.24.158.159:8090/sendSMS/%@/%@",self.phoneTextField.text,[self createCode]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self regist];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"验证码已发送" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            
            [alert show];
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
                
//                
//                BmobUser *user = [BmobUser objectWithClassName:@"User"];
//                [user setObject:self.phoneTextField.text forKey:@"username"];
//                [user saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//                    if (error) {
//                        NSLog(@"%@",error);
//                    } else if (isSuccessful) {
////                        [NSUserDefaults standardUserDefaults]objectForKey:@"username"] = self.phoneTextField.text;
//                    } else {
//                        NSLog(@"not regist");
//                    }
//                }];

            } else {
                NSLog(@"s");
            }
        }
    }];

}

- (IBAction)loginPress:(id)sender {
    if ([self.code isEqualToString:self.codeTextFiled.text]) {
        [[NSUserDefaults standardUserDefaults]setObject:self.phoneTextField.text forKey:@"username"];
        [self.navigationController popViewControllerAnimated:YES];
        
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
