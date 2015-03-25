//
//  ActivitySearchViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/25.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "ActivitySearchViewController.h"
#import "Global.h"
#import <BmobSDK/Bmob.h>
#import "CommonUtil.h"
#import "SVProgressHUD.h"
#import "ActivityViewController.h"
#import "StoreTableViewCell.h"

@interface ActivitySearchViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *keyWordsArray;

@end

@implementation ActivitySearchViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    //    初始化边框
    self.searchTextField.layer.borderColor = [MAIN_COLOR CGColor];
    self.searchTextField.layer.borderWidth = 1.0;
    self.searchTextField.layer.cornerRadius = 4.0;
    //    加载热门关键字
    [self loadKeyWords];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
#pragma mark 搜索方法，以关键字为参数，代码块的方法赋值与重载表格
- (void)searchByKeyWord:(NSString *)keyWord {
    BmobQuery *query = [BmobQuery queryWithClassName:@"StoreActivity"];
    [query includeKey:@"store"];
    [query whereKey:@"name" matchesWithRegex:[NSString stringWithFormat:@".*%@.*",keyWord]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array.count == 0) {
            [SVProgressHUD showErrorWithStatus:NO_DATAS];
        } else {
            self.tableView.hidden = NO;
            self.containerView.hidden = YES;
            self.dataArray = array;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark 搜索按钮点击
- (IBAction)searchButtonPress:(id)sender {
    self.tableView.hidden = NO;
    self.containerView.hidden = YES;
    if (![self.searchTextField.text isEqual:@""]) {
        [self searchByKeyWord:self.searchTextField.text];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请先输入要搜索的内容"];
    }
    
    
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
    [query whereKey:@"type" equalTo:[NSNumber numberWithInt:1]];
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
            //            偶数行偏移x坐标
            CGFloat offsetX = self.containerView.frame.size.width / 4.0;
            if ((row / 2.0) > 0) {
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
    
    //    为搜索框赋值
    NSString *keyWord = [self.dataArray[button.tag] objectForKey:@"name"];
    self.searchTextField.text = keyWord;
    [self searchByKeyWord:keyWord];
    //    reload
}
#pragma mark -
#pragma mark 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
#pragma mark 生成单元格
- (UITableViewCell *)tableView:tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     StoreTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"StoreTableViewCell" owner:self options:nil]firstObject];
    //    名称与描述
    BmobObject *activity = self.dataArray[indexPath.row];
    cell.nameLabel.text = [activity objectForKey:@"name"];
    cell.descriptLabel.text = [activity objectForKey:@"descript"];
    //    缩略图
    BmobFile *avatar = [activity objectForKey:@"avatar"];
    
    [BmobImage cutImageBySpecifiesTheWidth:100 * 2 height:100 * 2 quality:100 sourceImageUrl:avatar.url outputType:kBmobImageOutputBmobFile resultBlock:^(id object, NSError *error) {
        BmobFile *thumb = (BmobFile *)object;
        [cell.thumbImageView setImageWithURL:[NSURL URLWithString:thumb.url]];
    }];
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //日期转换
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM-dd"];
    
    cell.timeLabel.text = [formatter stringFromDate:[activity objectForKey:@"time"]];
    //    关联查询店铺
    cell.shopNameLabel.text = [[activity objectForKey:@"store"]objectForKey:@"name"];
    return cell;
}

#pragma mark 表格单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

#pragma mark 表格单元格点击事件
- (void)tableView:tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ActivityViewController *vc = [main instantiateViewControllerWithIdentifier:@"activity"];
    vc.objectId = [self.dataArray[indexPath.row] objectId];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark -
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
