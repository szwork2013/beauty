//
//  CommonUtil.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/12.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "CommonUtil.h"

@implementation CommonUtil
+ (NSDictionary *)textViewAttribute {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 7;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:14],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    return attributes;
}

+ (NSString *)enterChar:(NSString *)descriptString {
    descriptString = [descriptString stringByReplacingOccurrencesOfString: @"\\n" withString: @"\n"];
    descriptString = [descriptString stringByReplacingOccurrencesOfString: @"\\r" withString: @""];
    return descriptString;
}

+ (ProductShowTableViewCell *)fetchProductShowCell:(BmobObject *)product {
    ProductShowTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductTableViewCell" owner:self options:nil]lastObject];
    BmobFile *avatar = [product objectForKey:@"avatar"];
    [cell.thumbImageView setImageWithURL:[NSURL URLWithString:avatar.url]];
    //缩略图加圆角边框
    cell.thumbImageView.layer.cornerRadius = 40.0;
    cell.thumbImageView.layer.borderColor = [TINYGRAY_COLOR CGColor];
    cell.thumbImageView.layer.borderWidth = 1.0;
    cell.nameLabel.text = [product objectForKey:@"name"];
    cell.commentCountLabel.text = [[product objectForKey:@"commentCount"]stringValue];
    
    cell.averagePriceLabel.text = [NSString stringWithFormat:@"%.1f",[[product objectForKey:@"averagePrice"]floatValue]];
    //        评分星级
    StarView *view = [[StarView alloc]initWithCount:[product objectForKey:@"mark"] frame:CGRectMake(0, 0, 55.0, 11.0)];
    [cell.starView addSubview:view];
    return cell;
}
@end
