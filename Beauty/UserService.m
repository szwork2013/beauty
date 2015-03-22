//
//  UserService.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/12.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "UserService.h"
#import "SVProgressHUD.h"

@implementation UserService
+ (instancetype)getInstance {
    static UserService *instance;
    if (instance == nil) {
        instance = [[self alloc]init];
    }
    return instance;
}

- (void)actionWithUser:(actionBlock)actionBlock failBlock:(failBlock)failBlock {
    BmobUser *user = [BmobUser getCurrentUser];
    if (user) {
        actionBlock(user);
    } else {
//        跳转登录页面或其他操作
        failBlock();
    }
}

- (void)favorButtonPress:(NSString *)storeId successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock {

    [self actionWithUser:^(BmobUser *user) {
        //        判断收藏与否
        BmobQuery *storeQuery = [BmobQuery queryWithClassName:@"Store"];
        [storeQuery whereObjectKey:@"relStoreCollect" relatedTo:user];
        //                从当前会员下所有收藏店铺中遍历，看是否找到当前单元格的遍历
        [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            //设置店铺id
            BmobObject *store = [BmobObject objectWithoutDatatWithClassName:@"Store" objectId:storeId];
            BmobRelation *storeRelation = [[BmobRelation alloc]init];
            NSString *hudStr = @"收藏成功";
            for (int i = 0; i < array.count; i ++) {
                if ([[array[i] objectId] isEqualToString:[store objectId]]) {
                    [storeRelation removeObject:store];
                    hudStr = @"取消收藏成功";
                    break;
                } else {
                    [storeRelation addObject:store];
                }
            }
            //            如果没有找到
            if (array.count == 0) {
                [storeRelation addObject:store];
            }
            [user addRelation:storeRelation forKey:@"relStoreCollect"];
            [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                if (isSuccessful) {
                    
                    successBlock();
                    
                    [SVProgressHUD showSuccessWithStatus:hudStr];
                }
            }];
        }];
        
    } failBlock:^{
        failBlock();
    }];
    
}

- (void)favorButtonPressForProduct:(NSString *)productId successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock {
    
    [self actionWithUser:^(BmobUser *user) {
        //        判断收藏与否
        BmobQuery *storeQuery = [BmobQuery queryWithClassName:@"Product"];
        [storeQuery whereObjectKey:@"relProductCollect" relatedTo:user];
        //                从当前会员下所有收藏店铺中遍历，看是否找到当前单元格的遍历
        [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            //设置店铺id
            BmobObject *store = [BmobObject objectWithoutDatatWithClassName:@"Store" objectId:productId];
            BmobRelation *storeRelation = [[BmobRelation alloc]init];
            NSString *hudStr = @"收藏成功";
            for (int i = 0; i < array.count; i ++) {
                if ([[array[i] objectId] isEqualToString:[store objectId]]) {
                    [storeRelation removeObject:store];
                    hudStr = @"取消收藏成功";
                    break;
                } else {
                    [storeRelation addObject:store];
                }
            }
            //            如果没有找到
            if (array.count == 0) {
                [storeRelation addObject:store];
            }
            [user addRelation:storeRelation forKey:@"relProductCollect"];
            [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                if (isSuccessful) {
                    
                    successBlock();
                    
                    [SVProgressHUD showSuccessWithStatus:hudStr];
                }
            }];
        }];
        
    } failBlock:^{
        failBlock();
    }];
    
}
@end
