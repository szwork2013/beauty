//
//  RankViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/15.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "RankViewController.h"
#import "LSCanvasView.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"
#import "ProductDetailTableViewController.h"

@interface RankViewController ()

@end

@implementation RankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden = YES;
    [self setup];
    
    // Do any additional setup after loading the view.
}
- (void)setup {
//    初始化视图
    LSCanvasView *productCanvasView = [[[NSBundle mainBundle]loadNibNamed:@"LSCanvasView" owner:self options:nil]firstObject];
    productCanvasView.frame = CGRectMake(8, 64 + 8, CGRectGetWidth(self.view.frame) - 16, 170);
    [self.view addSubview:productCanvasView];
    [productCanvasView setup];
    productCanvasView.vc = self;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ProductDetailTableViewController *vc = segue.destinationViewController;
    vc.productId = self.productId;
}


@end
