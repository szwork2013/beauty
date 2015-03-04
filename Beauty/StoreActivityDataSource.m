//
//  StoreActivityDataSource.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/1.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "StoreActivityDataSource.h"
#import "StoreTableViewCell.h"
#import <BmobSDK/Bmob.h>

#import <BmobSDK/BmobImage.h>
#import "UIImageView+AFNetworking.h"


@implementation StoreActivityDataSource
-(instancetype) initWithViewController:(StoreViewController *)vc {
    if (self = [self init]) {
        self.storeVC = vc;
    }
    return self;
}

- (void) fetchData:(successBlock)successBlock {
    BmobQuery *activityQuery = [BmobQuery queryWithClassName:@"StoreActivity"];
    [activityQuery includeKey:@"store"];
    [activityQuery orderByDescending:@"time"];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        self.storeActivityArray = array;
        successBlock();
    }];

}
//组眉
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8.0;
}
//组脚
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.storeActivityArray.count;
}
//一组一个
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

//自定义单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoreTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"StoreTableViewCell" owner:self options:nil]firstObject];
//    名称与描述
    BmobObject *activity = self.storeActivityArray[indexPath.section];
    cell.nameLabel.text = [activity objectForKey:@"name"];
    cell.descriptLabel.text = [activity objectForKey:@"descript"];
//    缩略图
    BmobFile *avatar = [activity objectForKey:@"avatar"];

    [BmobImage cutImageBySpecifiesTheWidth:100 * 2 height:100 * 2 quality:100 sourceImageUrl:avatar.url outputType:kBmobImageOutputBmobFile resultBlock:^(id object, NSError *error) {
        BmobFile *thumb = (BmobFile *)object;
        [cell.thumbImageView setImageWithURL:[NSURL URLWithString:thumb.url]];
    }];
    //日期转换
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    cell.timeLabel.text = [formatter stringFromDate:[activity objectForKey:@"time"]];
//    关联查询店铺
    cell.shopNameLabel.text = [[activity objectForKey:@"store"]objectForKey:@"name"];
    return cell;
}

//单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110.0;
}

//单击单元格
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.storeVC performSegueWithIdentifier:@"activity" sender:self];
}


@end
