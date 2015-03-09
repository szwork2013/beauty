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
- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor whiteColor];
    
    self.nameButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nameButton.frame = CGRectMake(0, 0, 120, 27);
    [self.nameButton setTitle:@"免费代理" forState:UIControlStateNormal];
    self.nameButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    self.nameButton.tintColor = [UIColor darkGrayColor];
    
    [self addSubview:self.nameButton];
    
    self.indicatorView = [[UIView alloc]init];
    self.indicatorView.frame = CGRectMake(0, 27, 120, 3);
    self.indicatorView.backgroundColor = MAIN_COLOR;
    [self addSubview:self.indicatorView];
    
}
@end
