//
//  PageIndicatorView.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/9.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageIndicatorView : UIView
@property (strong, nonatomic) UIButton *nameButton;
@property (strong, nonatomic) UIView *indicatorView;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) NSString *title;
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title currentColor:(UIColor *)color;
@end
