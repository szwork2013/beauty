//
//  ImageBrowserViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/17.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "ImageBrowserViewController.h"
#import "UIImageView+AFNetworking.h"

@interface ImageBrowserViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *pageIndicatorLabel;

@end

@implementation ImageBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updatePageIndicator];
    [self loadImage];
    
    //init
    self.naviHidden = YES;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.imageArray.count, self.view.frame.size.height);
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.pageIndicatorLabel.textColor = [UIColor whiteColor];
    self.scrollView.delegate = self;
    [self hideNaviBar];
    // Do any additional setup after loading the view.
}

- (void)loadImage {
    for (int i = 0; i < self.imageArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.bounds = self.view.bounds;
        imageView.center = CGPointMake(self.view.center.x + self.view.frame.size.width * i, self.view.center.y);
        [imageView setImageWithURL:[NSURL URLWithString:self.imageArray[i]]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        //button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.bounds = imageView.bounds;
        button.center = imageView.center;
        [button addTarget:self action:@selector(hideNaviBar) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        
        [self.scrollView addSubview:imageView];
    }
    [self updateImageIndex];
}
- (void)updateImageIndex {
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * self.selectedIndex, 0) animated:YES];
}
- (void)updatePageIndicator {
    self.pageIndicatorLabel.text = [NSString stringWithFormat:@"%zi/%zi",self.selectedIndex + 1,self.imageArray.count];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.selectedIndex = (int)scrollView.contentOffset.x / self.view.frame.size.width;
    [self updatePageIndicator];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 200)];
    view.backgroundColor = [UIColor grayColor  ];
    return view;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"zoom");
}
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    NSLog(@"%.2f",scale);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)hideNaviBar {

//    self.navigationController.navigationBar.hidden = self.naviHidden;
//    self.naviHidden = !self.naviHidden;
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
