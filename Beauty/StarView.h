//
//  StarView.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/5.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarView : UIView
@property (nonatomic,strong) NSNumber *count;
-(instancetype)initWithCount:(NSNumber *)count frame:(CGRect)frame;
@end
