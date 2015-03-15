//
//  LSCanvasView.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/15.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "LSCanvasView.h"
#import "Global.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"

//#import <BmobSDK/Bmob.h>

@implementation LSCanvasView

- (void)setup {
//    初始化成员变量
    _selectIndex = 0;
    _objectIdDictionary = [NSMutableDictionary dictionary];
//        初始化标题数组
    self.titleArray = [NSMutableArray array];
    self.backgroundColor = [UIColor whiteColor];
//        初始化标题Label
    _titleLabel.font = [UIFont systemFontOfSize:16.0];
    _titleLabel.tintColor = [UIColor grayColor];

    [self addSubview:_titleLabel];
//    初始化滚动视图
    self.mainScrollView.delegate = self;
//    初始化分页控件
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    [self addSubview:_pageControl];
//    初始化查看更多按钮
    [_moreButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [_moreButton setTitle:@"查看所有排行榜" forState:UIControlStateNormal];
    _moreButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self addSubview:_moreButton];
    [self loadData];

}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger currentPage = (int)scrollView.contentOffset.x / scrollView.frame.size.width;
    self.selectIndex = currentPage;
    self.titleLabel.text = self.titleArray[currentPage];
    self.pageControl.currentPage = currentPage;
}

- (void)loadData{
    //    获取分类数据
    BmobQuery *query = [BmobQuery queryWithClassName:@"RankListClassify"];
    [query whereKey:@"type" equalTo:[NSNumber numberWithInt:0]];
    [query orderByAscending:@"rank"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            for (int i = 0; i < array.count; i++) {
                BmobObject *classify = array[i];
//                三个产品的背景层
                UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(i * self.mainScrollView.frame.size.width, 0, self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height)];
                [self.mainScrollView addSubview:backgroundView];
                [self.titleArray addObject:[classify objectForKey:@"name"]];
//                NSLog(@"%@",[classify objectForKey:@"name"]);
                //                获取产品数据
                BmobQuery *query = [BmobQuery queryWithClassName:@"RankListProduct"];
                [query includeKey:@"product"];
                query.limit = 3;
                [query orderByAscending:@"rank"];
                [query whereKey:@"rankListClassify" equalTo:classify];
                [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                    for (int j = 0; j < array.count; j++) {
                        BmobObject *rankListProduct = [array[j] objectForKey:@"product"];
                        //    生成图片
                        UIImageView *imageView = [[UIImageView alloc]init];
                        imageView.bounds = CGRectMake(0, 0, 60, 60);
                        CGFloat x = CGRectGetWidth(backgroundView.frame) / 2.0;
                        if (j == 0) {
                            x -= 105.0 / 310.0 * CGRectGetWidth(backgroundView.frame);
                        } else if (j == 2) {
                            x += 105.0 / 310.0 * CGRectGetWidth(backgroundView.frame);
                        }

                        imageView.center = CGPointMake(x, backgroundView.center.y);
//                        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(60 * i, 0, 60, 60)];

                        imageView.layer.cornerRadius = 30.0;
                        imageView.clipsToBounds = YES;
                        imageView.layer.borderColor = [TINYGRAY_COLOR CGColor];
                        imageView.layer.borderWidth = 1.0;
                        BmobFile *imageFile = [rankListProduct objectForKey:@"avatar"];
                        [imageView setImageWithURL:[NSURL URLWithString:imageFile.url]];
                        [backgroundView addSubview:imageView];
//                        角标
                        UIImageView *cornerImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"no%zi",j + 1]]];
                        cornerImageView.frame = CGRectMake(imageView.frame.origin.x - 10, imageView.frame.origin.y, 25.5, 24.0);
                        [backgroundView addSubview:cornerImageView];
                        //按钮
                        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
                        [button setTitle:@"" forState:UIControlStateNormal];
                        button.bounds = imageView.bounds;
                        button.center = imageView.center;
                        button.tag = PRODUCT_TAG * (i + 1) + j;
                        //添加到成员字典
                        [self.objectIdDictionary setValue:rankListProduct.objectId forKey:[NSString stringWithFormat:@"%zi",button.tag]];
                        [button addTarget:self action:@selector(jump:) forControlEvents:UIControlEventTouchUpInside];
                        [backgroundView addSubview:button];
                        if (j < 2) {
                            //  生成分隔线
                            UIView *seperateLineView = [[UIView alloc]init];
                            seperateLineView.backgroundColor = TINYGRAY_COLOR;
                            seperateLineView.bounds = CGRectMake(0, 0, 1, 48);
                            seperateLineView.center = CGPointMake((j + 1) / 3.0 * CGRectGetWidth(backgroundView.frame), backgroundView.center.y);
                            [backgroundView addSubview:seperateLineView];
                        }
                    }
                    
                }];

            }
            //    设置标题
            _titleLabel.text = self.titleArray[_selectIndex];
            //    个数
            _pageControl.numberOfPages = self.titleArray.count;
            //    设置滚动视图内容尺寸
            _mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.mainScrollView.frame) * self.titleArray.count, CGRectGetHeight(self.mainScrollView.frame));
        }
    }];

}

- (void)jump:(UIButton *)button {
//    NSLog(@"%zi",button.tag);
//    NSLog(@"%@",self.objectIdDictionary[[NSString stringWithFormat:@"%zi",button.tag]]);
    self.vc.productId = self.objectIdDictionary[[NSString stringWithFormat:@"%zi",button.tag]];
    [self.vc performSegueWithIdentifier:@"productDetail" sender:self];
}
@end
