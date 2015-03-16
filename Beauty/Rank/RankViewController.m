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
#import "Global.h"
#import "StoreDetailTableViewController.h"
#import "BrandDetailTableViewController.h"
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
    CGFloat canvasHeight = 170.0;
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    scrollView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width - 2 * MARGIN, (canvasHeight + MARGIN ) * 3);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
//    初始化视图
    LSCanvasView *productCanvasView = [[[NSBundle mainBundle]loadNibNamed:@"LSCanvasView" owner:self options:nil]firstObject];
    productCanvasView.frame = CGRectMake(MARGIN, 0 + MARGIN, CGRectGetWidth(self.view.frame) - MARGIN * 2, canvasHeight);
    [scrollView addSubview:productCanvasView];
    productCanvasView.type = [NSNumber numberWithInt:0];
    [productCanvasView setup];
    productCanvasView.vc = self;
    
//    初始化店铺
    LSCanvasView *storeCanvasView = [[[NSBundle mainBundle]loadNibNamed:@"LSCanvasView" owner:self options:nil]firstObject];
    storeCanvasView.frame = CGRectMake(MARGIN, CGRectGetMaxY(productCanvasView.frame) + MARGIN, CGRectGetWidth(self.view.frame) - MARGIN * 2, canvasHeight);
    [scrollView addSubview:storeCanvasView];
    storeCanvasView.type = [NSNumber numberWithInt:1];
    [storeCanvasView setup];
    storeCanvasView.vc = self;
    
    //    初始化品牌
    LSCanvasView *brandCanvasView = [[[NSBundle mainBundle]loadNibNamed:@"LSCanvasView" owner:self options:nil]firstObject];
    brandCanvasView.frame = CGRectMake(MARGIN, CGRectGetMaxY(storeCanvasView.frame) + MARGIN, CGRectGetWidth(self.view.frame) - MARGIN * 2, canvasHeight);
    [scrollView addSubview:brandCanvasView];
    brandCanvasView.type = [NSNumber numberWithInt:2];
    [brandCanvasView setup];
    brandCanvasView.vc = self;
    
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
//    if ([segue.identifier isEqualToString:@"rankListProduct"]) {
//        
//    } else if ([segue.identifier isEqualToString:@"rankListStore"]){
//        
//    } else if ([segue.identifier isEqualToString:@"rankListBrand"]) {
//        
//    } else
    
    if ([segue.identifier isEqualToString:@"productDetail"]) {
        ProductDetailTableViewController *vc = segue.destinationViewController;
        vc.productId = self.productId;
    } else if ([segue.identifier isEqualToString:@"storeDetail"]) {
        StoreDetailTableViewController *vc = segue.destinationViewController;
        vc.storeId = self.storeId;
    }  else if ([segue.identifier isEqualToString:@"brandDetail"]) {
        BrandDetailTableViewController *vc = segue.destinationViewController;
        vc.brandId = self.brandId;
    }
}


@end
