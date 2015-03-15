//
//  LSCanvasView.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/15.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RankViewController.h"
#define PRODUCT_TAG 10
#define STORE_TAG 100
#define BRAND_TAG 1000
@interface LSCanvasView : UIView <UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) NSMutableDictionary *objectIdDictionary;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong) RankViewController *vc;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) IBOutlet UIButton *moreButton;

- (void)setup;

@end
