//
//  PageIndicatorView.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/9.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "PageIndicatorView.h"
#import "Global.h"

@implementation PageIndicatorView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

*/
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title currentColor:(UIColor *)color{
    if ([self initWithFrame:frame]) {
//        [self.nameButton setTitle:title forState:UIControlStateNormal];
//        self.indicatorView.backgroundColor = color;
        self.title = title;
        self.color = color;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor whiteColor];
    
    self.nameButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nameButton.frame = CGRectMake(0, 0, PAGEINDICATOR_WIDTH, 27);
    [self.nameButton setTitle:self.title forState:UIControlStateNormal];
    self.nameButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    self.nameButton.tintColor = [UIColor darkGrayColor];
    
    [self addSubview:self.nameButton];
    
    self.indicatorView = [[UIView alloc]init];
    self.indicatorView.frame = CGRectMake(0, 27, PAGEINDICATOR_WIDTH, 3);
    self.indicatorView.backgroundColor = self.color;
    [self addSubview:self.indicatorView];
    
}
@end
