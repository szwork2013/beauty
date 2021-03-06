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

+ (ProductShowTableViewCell *)fetchProductShowCell:(BmobObject *)product index:(NSInteger)i{
    ProductShowTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductTableViewCell" owner:self options:nil]objectAtIndex:i];
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
//转换颜色值
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

//评价单元格
+ (ProductCommentTableViewCell *)fetchProductCommentCell:(BmobObject *)comment {
    NSArray *skinTypeArray = @[@"混", @"中", @"油", @"干", @"敏"];
    NSArray *skinColorArray = @[[self colorWithHexString:@"#ae5da1" alpha:1.0],[self colorWithHexString:@"#fff100" alpha:1.0],[self colorWithHexString:@"#f39800" alpha:1.0],[self colorWithHexString:@"#ec6944" alpha:1.0],[self colorWithHexString:@"#eb6877" alpha:1.0]];
    ProductCommentTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductCommentTableViewCell" owner:self options:nil]firstObject];
    BmobUser *user = [comment objectForKey:@"user"];
//    头像
    
    BmobFile *avatar = [user objectForKey:@"avatar"];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:avatar.url] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    //缩略图加圆角边框
    cell.avatarImageView.layer.cornerRadius = 25.0;
    cell.avatarImageView.layer.borderColor = [TINYGRAY_COLOR CGColor];
    cell.avatarImageView.layer.borderWidth = 1.0;
    cell.avatarImageView.clipsToBounds = YES;
//用户名
    cell.nicknameLabel.text = [user objectForKey:@"nickname"];
//年龄
    cell.ageLabel.text = [NSString stringWithFormat:@"%d岁",[[user objectForKey:@"age"] intValue]];
//多久前
    cell.createdAtLabel.text = [self compareCurrentTime:comment.createdAt];
//    皮肤特性
    int skinType = [[user objectForKey:@"skinType"]intValue];
    cell.skinTypeLabel.text = skinTypeArray[skinType];
    cell.skinTypeLabel.backgroundColor = skinColorArray[skinType];
    cell.skinTypeLabel.layer.cornerRadius = 11.0;
    cell.skinTypeLabel.clipsToBounds = YES;

//        评分星级
    StarView *view = [[StarView alloc]initWithCount:[comment objectForKey:@"score"] frame:CGRectMake(0, 0, 55.0, 11.0)];
    [cell.starView addSubview:view];
//    评语
    cell.contentTextView.attributedText = [[NSAttributedString alloc] initWithString:[comment objectForKey:@"content"] == nil ? @"" :[comment objectForKey:@"content"] attributes:[self textViewAttribute]];
    [cell.contentTextView sizeToFit];
    
//    点评图片
    CGFloat photoGalleryWidth = SCREEN_WIDTH;
    NSArray *photos = [comment objectForKey:@"photos"];
    CGFloat photoWidth = photoGalleryWidth / 3.0;
    for (int i = 0; i < photos.count; i++) {
        int row = i / 3;
        int column = i % 3;
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.bounds = CGRectMake(0, 0, photoWidth - 5, photoWidth - 5);
        if (column == 0) {
            imageView.center = CGPointMake(photoGalleryWidth / 2.0 - photoWidth, photoWidth / 2.0 + row * photoWidth);
        } else if (column == 1) {
            imageView.center = CGPointMake(photoGalleryWidth / 2.0, photoWidth / 2.0 + row * photoWidth);
        } else {
            imageView.center = CGPointMake(photoGalleryWidth / 2.0 + photoWidth, photoWidth / 2.0 + row * photoWidth);
        }
        
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setImageWithURL:[NSURL URLWithString:[photos objectAtIndex:i]]];
        [cell.photoGalleryContainerView addSubview:imageView];
    }
    cell.contentView.clipsToBounds = YES;
    return cell;

}
//评价高度
+ (CGFloat)fetchProductCommentCellHeight:(BmobObject *)commentObject {
    BmobObject *comment = commentObject;
    NSString *text = [comment objectForKey:@"content"];
    
    CGSize constraint = CGSizeMake(SCREEN_WIDTH - (10 * 2), 20000.0f);
    
    //如果是没有评语，就需要去纠正一下它的偏移量了。
    if ([text isEqualToString:@""] || text == nil) {
        text = @" ";
    }
    CGRect rect = [text boundingRectWithSize:constraint
                                     options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)
                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.5]}
                                     context:NULL];
    
    //photo numbers
    NSArray *photosArray = [comment objectForKey:@"photos"];
    NSInteger photoCount = [photosArray count];
    long row = ceil(photoCount / 3.0);
    CGFloat photoGalleryHeight = row * (SCREEN_WIDTH) / 3.0;
    return 82.0 + rect.size.height + photoGalleryHeight;
}
//产品搜索页
+ (ProductShowTableViewCell *) fetchProductShowCell:(BmobObject *)product {
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

//店铺
+ (StoreShowTableViewCell *)fetchStoreShowCell:(BmobObject *)store {
    StoreShowTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"StoreShowTableViewCell" owner:self options:nil]lastObject];
    BmobFile *avatar = [store objectForKey:@"avatar"];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:avatar.url]];
    //缩略图加圆角边框
    cell.avatarImageView.layer.cornerRadius = 40.0;
    cell.avatarImageView.layer.borderColor = [TINYGRAY_COLOR CGColor];
    cell.avatarImageView.layer.borderWidth = 1.0;
    cell.avatarImageView.clipsToBounds = YES;
    cell.nameLabel.text = [store objectForKey:@"name"];
    cell.descriptLabel.text = [store objectForKey:@"descript"];
    return cell;
}
//店铺不带收藏按钮的
+ (StoreShowTableViewCell *) fetchStoreShowCellWithoutFavorButton:(BmobObject *)store WithOrderNum:(NSInteger)num {
StoreShowTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"StoreShowTableViewCell" owner:self options:nil]objectAtIndex:0];

BmobFile *avatar = [store objectForKey:@"avatar"];

[cell.avatarImageView setImageWithURL:[NSURL URLWithString:avatar.url]];
//缩略图加圆角边框
cell.avatarImageView.layer.cornerRadius = 28.0;
cell.avatarImageView.layer.borderColor = [TINYGRAY_COLOR CGColor];
cell.avatarImageView.clipsToBounds = YES;
cell.avatarImageView.layer.borderWidth = 1.0;
cell.nameLabel.text = [store objectForKey:@"name"];
cell.orderLabel.text = [NSString stringWithFormat:@"%ld.",(long)num + 1];
cell.descriptLabel.text = [store objectForKey:@"descript"];
return cell;
}
//还剩下几天
+ (NSInteger)daysInterval:(NSDate *)date {
    NSDate *now = [NSDate date];
    NSTimeInterval seconds = [date timeIntervalSinceDate:now];
    return seconds / 60 / 60 / 24 + 1;
}
//时间距离现在多久前
+ (NSString *) compareCurrentTime:(NSDate*) compareDate{
    NSString *result = @"";
    NSTimeInterval interval = [compareDate timeIntervalSinceNow];
    interval = - interval;
    long temp = 0;
    if (compareDate != nil) {
        if (interval < 60) {
            result = [NSString stringWithFormat:@"刚刚"];
        } else if ((temp = interval / 60) < 60 ) {
            result = [NSString stringWithFormat:@"%ld分钟前",temp];
        } else if ((temp = temp / 60) < 24){
            result = [NSString stringWithFormat:@"%ld小时前",temp];
        } else if ((temp = temp / 24) < 30){
            result = [NSString stringWithFormat:@"%ld天前",temp];
        } else if ((temp = temp / 30) < 12) {
            result = [NSString stringWithFormat:@"%ld月前",temp];
        } else {
            temp = temp / 12;
            result = [NSString stringWithFormat:@"%ld年前",temp];
        }
        
    }
    return result;
}
//      更新表格视图的高度
+ (void)updateTableViewHeight:(UIViewController *)vc{
    UIView *rootView = [vc.tabBarController.view.subviews objectAtIndex:0];

    CGRect frame = rootView.frame;
    frame.size.height += 49.0;
    rootView.frame = frame;
}
//图片缩放
+ (UIImage *)shrinkImage:(UIImage *)original toSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CGFloat originalAspect = original.size.width / original.size.height;
    CGFloat targetAspect = size.width / size.height;
    CGRect targetRect;
    if (originalAspect > targetAspect) {
        // original is wider than target
        targetRect.size.width = size.width * originalAspect / targetAspect;
        targetRect.size.height = size.height;
        targetRect.origin.x = 0;
        targetRect.origin.y = (size.height - targetRect.size.height) * 0.5;
    } else if (originalAspect < targetAspect) {
        // original is narrower than target
        targetRect.size.width = size.width;
        targetRect.size.height = size.height * targetAspect / originalAspect;
        targetRect.origin.x = (size.width - targetRect.size.width) * 0.5;
        targetRect.origin.y = 0;
    } else {
        // original and target have same aspect ratio
        targetRect = CGRectMake(0, 0, size.width, size.height);
    }
    //    targetRect = CGRectMake(0, 0, .5*original.size.width, .5*original.size.height);
    [original drawInRect:targetRect];
    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return final;
}
@end
