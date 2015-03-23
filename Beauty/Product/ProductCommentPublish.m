//
//  ProductCommentPublish.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/23.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "ProductCommentPublish.h"
#import "Global.h"
#import <BmobSDK/Bmob.h>
#import "UploadImageView.h"
#import "UserService.h"
#import "SVProgressHUD.h"

@interface ProductCommentPublish ()
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (strong, nonatomic) NSString *placeHolderString;

@property (strong, nonatomic) UploadImageView *uploadImageView;
@property (strong, nonatomic) NSMutableArray *fileUrlArray;
@property (assign, nonatomic) NSInteger score;
@end

@implementation ProductCommentPublish

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"评论";
//    配置contentTextView
    self.placeHolderString = @"说点什么吧~";
    self.contentTextView.layer.borderColor = [MAIN_COLOR CGColor];
    self.contentTextView.layer.borderWidth = 1.0;
    self.contentTextView.layer.cornerRadius = 8.0;
    self.contentTextView.text = self.placeHolderString;
    //初始化view
    self.uploadImageView = [[[NSBundle mainBundle]loadNibNamed:@"Upload" owner:self options:nil]firstObject];
    self.uploadImageView.vc = self;
    
    self.uploadImageView.frame = CGRectMake(0, 260.0, self.view.frame.size.width, 130.0);
    [self.uploadImageView createChosenImagesArray];
    [self.view addSubview:self.uploadImageView];
    
    //    点击与滑动手势以去掉键盘
    UITapGestureRecognizer *tapBackgroundView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    UITapGestureRecognizer *tapContentView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTyping:)];
    UIPanGestureRecognizer *moveContentTextView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:tapBackgroundView];
    [self.contentTextView addGestureRecognizer:moveContentTextView];
    [self.contentTextView addGestureRecognizer:tapContentView];
    // Do any additional setup after loading the view from its nib.
}
//开始录入
- (void)startTyping:(id)sender{
    if ([self.contentTextView.text isEqualToString:self.placeHolderString]) {
        self.contentTextView.text = @"";
    }
    [self.contentTextView becomeFirstResponder];
}
//隐藏键盘
- (void)hideKeyboard:(id)sender {
    [self.contentTextView resignFirstResponder];
}

#pragma mark 点击评分按钮
- (IBAction)scoreButtonPress:(UIButton *)button {
    for (int i = 1; i <= 5; i++) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i];
        if (i <= button.tag) {
            
            [btn setBackgroundImage:[UIImage imageNamed:@"star_full_publish"] forState:UIControlStateNormal];
        } else {
             [btn setBackgroundImage:[UIImage imageNamed:@"star_empty_publish"] forState:UIControlStateNormal];
        }
    }
    self.score = button.tag;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 提交点评
- (IBAction)submit:(id)sender {
    if ([self.contentTextView.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:self.placeHolderString];
        return;
    }
    NSString *content = self.contentTextView.text;
    
    UserService *service = [UserService getInstance];
    [service actionWithUser:^(BmobUser *user) {
        //添加申请信息
        BmobObject *tryRecord = [BmobObject objectWithClassName:@"ProductComment"];
        [tryRecord setObject:user forKey:@"user"];
        [tryRecord setObject:[BmobObject objectWithoutDatatWithClassName:@"Product" objectId:self.productId] forKey:@"product"];
        [tryRecord setObject:content forKey:@"content"];
        [tryRecord setObject:self.uploadImageView.fileUrlArray forKey:@"photos"];
        [tryRecord setObject:[NSNumber numberWithInteger:self.score] forKey:@"score"];
        [tryRecord saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (error) {
                NSLog(@"%@",error);
            } else if (isSuccessful) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"点评成功" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
            }
        }];
        
    } failBlock:^{
        
    }];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
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
