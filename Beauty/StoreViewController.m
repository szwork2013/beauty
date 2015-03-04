//
//  StoreViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/1.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "StoreViewController.h"
#import "StoreActivityDataSource.h"
#import "ActivityViewController.h"
#import <BmobSDK/Bmob.h>

@interface StoreViewController ()
@property (weak, nonatomic) IBOutlet UITableView *storeActivityTableView;
@end

@implementation StoreViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    StoreActivityDataSource *activityDataSource = [[StoreActivityDataSource alloc]initWithViewController:self];
    self.storeActivityTableView.dataSource = activityDataSource;
    self.storeActivityTableView.delegate = activityDataSource;
    
    
    [activityDataSource fetchData:^{
        [self.storeActivityTableView reloadData];
    }];
    

    
        // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 Segue 跳转，传参
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ActivityViewController *activityVC = (ActivityViewController *)segue.destinationViewController;
    
    StoreActivityDataSource *activityDataSource = (StoreActivityDataSource *)self.storeActivityTableView.dataSource;
    BmobObject *activityObject = activityDataSource.storeActivityArray[self.storeActivityTableView.indexPathForSelectedRow.section];
    activityVC.objectId = activityObject.objectId;
}

@end
