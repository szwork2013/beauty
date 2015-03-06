//
//  CommonWebView.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/6.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "WebViewBrowserController.h"

@interface WebViewBrowserController ()

@end

@implementation WebViewBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"urlString : %@",self.urlString);
    if (self.urlString == nil || [self.urlString isEqualToString:@""]) {
        self.urlString = @"www.it577.net";
    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
    
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
