//
//  SlidePageViewController.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/8.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlidePageViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *tableViewArray;
@property (nonatomic, assign) NSInteger count;
@property (weak, nonatomic) IBOutlet UIScrollView *tableViewContainerScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *pageControlScrollView;
@property (strong, nonatomic) NSMutableArray *pageIndicatorViewArray;

@end
