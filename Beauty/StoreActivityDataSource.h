//
//  StoreActivityDataSource.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/1.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreViewController.h"

@interface StoreActivityDataSource : NSObject<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSArray *storeActivityArray;
@property (strong, nonatomic) StoreViewController *storeVC;
typedef void(^successBlock)(void);
/**
 获取数据，并重载tableview
 */
- (void) fetchData:(successBlock)successBlock;
/**
 传入被代理控制器类
 */
-(instancetype) initWithViewController:(StoreViewController *)vc;
@end
