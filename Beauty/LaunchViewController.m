//
//  LaunchViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/4/13.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "LaunchViewController.h"
#import "Global.h"
#import "HomeViewController.h"

@interface LaunchViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    int count = 4;
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * count, SCREEN_HEIGHT);
    for (int i = 0; i < count; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"s%zi.jpg",i]]];
        imageView.frame = CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self.scrollView addSubview:imageView];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpHome)];
    [self.scrollView addGestureRecognizer:tap];
    self.pageControl.numberOfPages = count;
}
- (void)jumpHome {
    if (self.scrollView.contentOffset.x >= 3 * SCREEN_WIDTH) {
        HomeViewController *homeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
        [[[[UIApplication sharedApplication]windows]firstObject] setRootViewController:homeVC];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentPage = (int)scrollView.contentOffset.x / SCREEN_WIDTH;
    self.pageControl.currentPage = currentPage;
}

@end
