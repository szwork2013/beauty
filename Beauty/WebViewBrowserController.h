//
//  CommonWebView.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/6.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewBrowserController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic,strong) NSString *urlString;
@end
