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
#import "CommonUtil.h"
#import "SVProgressHUD.h"
@interface ProductSearchViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *keyWordsArray;
@end

@implementation ProductSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    初始化边框
    self.searchTextField.layer.borderColor = [MAIN_COLOR CGColor];
    self.searchTextField.layer.borderWidth = 1.0;
    self.searchTextField.layer.cornerRadius = 4.0;
//    加载热门关键字
    [self loadKeyWords];
//    生成表格
    [self createTableView];
}
#pragma mark 搜索按钮点击
- (IBAction)searchButtonPress:(id)sender {
    self.tableView.hidden = NO;
    self.containerView.hidden = YES;
    
    if (![self.searchTextField.text isEqual:@""]) {
        BmobQuery *query = [BmobQuery queryWithClassName:@"Product"];
        [query whereKey:@"name" matchesWithRegex:[NSString stringWithFormat:@".*%@.*",self.searchTextField.text]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            self.dataArray = array;
            NSLog(@"%@",[array[0] objectForKey:@"name"]);
            [self.tableView reloadData];
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请先输入要搜索的内容"];
    }
}
#pragma mark 表格生成并且默认隐藏状态
- (void)createTableView {
    self.tableView.hidden = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


#pragma mark 加载热门关键字
- (void)loadKeyWords {
    NSArray *backgroudColorArray = @[
                                         [CommonUtil colorWithHexString:@"#00b6ef" alpha:153.0 / 255.0],
                                         [CommonUtil colorWithHexString:@"#90c320" alpha:153.0 / 255.0],
                                         [CommonUtil colorWithHexString:@"#ea6001" alpha:153.0 / 255.0],
                                         [CommonUtil colorWithHexString:@"#f9ed44" alpha:153.0 / 255.0],
                                         [CommonUtil colorWithHexString:@"#efc1ea" alpha:153.0 / 255.0],
                                         [CommonUtil colorWithHexString:@"#fdcdcf" alpha:153.0 / 255.0],
                                         [CommonUtil colorWithHexString:@"#78ab25" alpha:153.0 / 255.0],
                                         [CommonUtil colorWithHexString:@"#fab89d" alpha:153.0 / 255.0],
                                         [CommonUtil colorWithHexString:@"#b6c1f7" alpha:153.0 / 255.0],
                                         [CommonUtil colorWithHexString:@"#bae7f8" alpha:153.0 / 255.0]
                                     ];
    BmobQuery *query = [BmobQuery queryWithClassName:@"Recommend"];
    [query orderByAscending:@"rank"];
    [query whereKey:@"type" equalTo:[NSNumber numberWithInt:0]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *keyWordsArray, NSError *error) {
        for (int i = 0 ; i < keyWordsArray.count; i++) {
            self.keyWordsArray = keyWordsArray;
//            生成并设置button风格
            UIButton *keyWordButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [keyWordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            keyWordButton.titleLabel.font = [UIFont systemFontOfSize:19.0];
            keyWordButton.layer.cornerRadius = 4.0;
            [keyWordButton setBackgroundColor:backgroudColorArray[[[keyWordsArray[i] objectForKey:@"backgroundColorType"]intValue]]] ;
            NSString *keyWordStr = [keyWordsArray[i] objectForKey:@"name"];
            [keyWordButton setTitle:keyWordStr forState:UIControlStateNormal];
            keyWordButton.bounds = CGRectMake(0, 0, keyWordStr.length * 19.0 + 30.0, 33.0);
            int row = i / 2;
            int column = i % 2;
            CGFloat offsetX = self.containerView.frame.size.width / 4.0;
            if (row != 0) {
                offsetX += 30.0;
            }
            keyWordButton.center = CGPointMake(offsetX + (1 + 2 * column * self.containerView.frame.size.width) / 4.0, 80.0 + row * 60.0);
            [self.containerView addSubview:keyWordButton];
//            button点击事件
            keyWordButton.tag = i;
            [keyWordButton addTarget:self action:@selector(keyWordButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}
#pragma mark 按钮点击事件
- (void)keyWordButtonPress:(UIButton *)button {
    self.tableView.hidden = NO;
    self.containerView.hidden = YES;
//    reload
}
#pragma mark -
#pragma mark 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BmobObject *object = self.dataArray[indexPath.row];
    return [CommonUtil fetchProductShowCell:object index:1];
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
