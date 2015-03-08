//
//  WechatProductViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/8.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "WechatProductViewController.h"
#import "SlidePageViewController.h"

@interface WechatProductViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation WechatProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationItem.title = @"微商好产品";
    SlidePageViewController *pageViewController = [[SlidePageViewController alloc]initWithNibName:@"SlidePageViewController" bundle:[NSBundle mainBundle]];
    CGRect originRect = pageViewController.view.frame;
    CGRect newRect = CGRectMake(originRect.origin.x, 64, originRect.size.width, originRect.size.height);
    pageViewController.view.frame = newRect;
    [self.view addSubview:pageViewController.view];
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
