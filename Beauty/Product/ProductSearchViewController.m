//
//  ProductSearchViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/25.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "ProductSearchViewController.h"
#import "Global.h"
#import <BmobSDK/Bmob.h>

@interface ProductSearchViewController ()

@end

@implementation ProductSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    初始化边框
    self.searchTextField.layer.borderColor = [MAIN_COLOR CGColor];
//    加载热门关键字
    [self loadKeyWords];
}
#pragma mark 搜索按钮点击
- (IBAction)searchButtonPress:(id)sender {
    if (YES) {
        
    }
}
#pragma mark 加载热门关键字
- (void)loadKeyWords {
    BmobQuery *query = [BmobQuery queryWithClassName:@"Recommend"];
    [query orderByAscending:@"rank"];
    [query whereKey:@"type" equalTo:[NSNumber numberWithInt:0]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *keyWordsArray, NSError *error) {
        for (int i = 0 ; i < keyWordsArray.count; i++) {
            UIButton *keyWordButton = [UIButton buttonWithType:UIButtonTypeSystem];
            keyWordButton.titleLabel.font = [UIFont systemFontOfSize:19.0];
            keyWordButton.layer.cornerRadius = 4.0;
            [keyWordButton setBackgroundColor:[UIColor redColor]] ;
            NSString *keyWordStr = [keyWordsArray[i] objectForKey:@"name"];
            [keyWordButton setTitle:keyWordStr forState:UIControlStateNormal];
            keyWordButton.bounds = CGRectMake(0, 0, keyWordStr.length * 19.0 + 20.0, 23.0);
            int row = i / 2;
            int column = i % 2;
            keyWordButton.center = CGPointMake(self.container.frame.size.width / 4.0 + column * self.container.frame.size.width / 4.0 * 3, 50.0 + row * 30.0);
            [self.container addSubview:keyWordButton];
            
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
