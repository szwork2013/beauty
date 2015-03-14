//
//  XHRootViewController.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/14.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHMenu.h"
#import "XHScrollMenu.h"
@interface XHRootView : UIView<XHScrollMenuDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) XHScrollMenu *scrollMenu;
@property (nonatomic, strong) NSMutableArray *menus;
@property (nonatomic, assign) BOOL shouldObserving;
- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView;
@end
