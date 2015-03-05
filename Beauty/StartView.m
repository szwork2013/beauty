//
//  StartView.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/5.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "StartView.h"

@implementation StartView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)drawRect:(CGRect)rect {
    //    评分星级
    NSNumber *starFullNum = @3.5;
    CGFloat width = 9.0;
    CGFloat height = 9.0;
    CGFloat margin = 2.0;
    for (int i = 0; i <= 4; i++) {
        UIImageView *emptyImageView = [[UIImageView alloc]initWithFrame:CGRectMake((width + margin) * i, 0, width, height)];
        [emptyImageView setImage:[UIImage imageNamed:@"star_empty"]];
        [self addSubview:emptyImageView];
    }
    for (int i = 0; i < [starFullNum intValue]; i++) {
        UIImageView *fullImageView = [[UIImageView alloc]initWithFrame:CGRectMake((width + margin) * i, 0, width, height)];
        [fullImageView setImage:[UIImage imageNamed:@"star_full"]];
        [self addSubview:fullImageView];
    }
}
@end
