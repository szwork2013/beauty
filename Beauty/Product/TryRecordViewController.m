//
//  TryRecordViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/17.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "TryRecordViewController.h"
#import <BmobSDK/Bmob.h>
#import "UploadImageView.h"
#import "UserService.h"
#import "SVProgressHUD.h"
#import <BmobSDK/BmobProFile.h>

@interface TryRecordViewController ()<UIAlertViewDelegate>
@property (nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sexSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (strong, nonatomic) UploadImageView *uploadImageView;
@property (strong, nonatomic) NSMutableArray *fileUrlArray;
@end


@implementation TryRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//初始化view
    self.uploadImageView = [[[NSBundle mainBundle]loadNibNamed:@"Upload" owner:self options:nil]firstObject];
    self.uploadImageView.vc = self;

    self.uploadImageView.frame = CGRectMake(0, 230.0, self.view.frame.size.width, 130.0);
    [self.view addSubview:self.uploadImageView];
//    点击与滑动手势以去掉键盘
    UITapGestureRecognizer *topScrollView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    UIPanGestureRecognizer *moveScrollView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.scrollView addGestureRecognizer:topScrollView];
    [self.scrollView addGestureRecognizer:moveScrollView];
    
//    [self upload];
//    NSLog(@"%@",self.productId);
    // Do any additional setup after loading the view.
}
//表单验证
- (BOOL)formValid {
    if ([self.nameTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请填写姓名"];
        return NO;
    }
    if ([self.mobileTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请填写电话"];
        return NO;
    }
    return YES;
}
//隐藏键盘
- (void)hideKeyboard:(id)sender {
    [self.nameTextField resignFirstResponder];
    [self.mobileTextField resignFirstResponder];
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
        BmobObject *tryRecord = [BmobObject objectWithClassName:@"TryRecord"];
        [tryRecord setObject:user forKey:@"user"];
        [tryRecord setObject:[BmobObject objectWithoutDatatWithClassName:@"TryEvent" objectId:self.tryEventId] forKey:@"tryEvent"];
        [tryRecord setObject:formContent forKey:@"formContent"];
        [tryRecord setObject:self.uploadImageView.fileUrlArray forKey:@"photos"];
        [tryRecord setObject:[NSNumber numberWithInt:0] forKey:@"state"];
        [tryRecord saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (error) {
                NSLog(@"%@",error);
            } else if (isSuccessful) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"申请成功" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
                
                
            }
        }];
        
    } failBlock:^{
        
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
