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


@interface TryRecordViewController ()

@end

@implementation TryRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UploadImageView *uploadImageView = [[[NSBundle mainBundle]loadNibNamed:@"UploadImageView" owner:self options:nil]firstObject];
    uploadImageView.vc = self;
//    [self.view addSubview:uploadImageView];
    
//    [self upload];
//    NSLog(@"%@",self.productId);
    // Do any additional setup after loading the view.
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
