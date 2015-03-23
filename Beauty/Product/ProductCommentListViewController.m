//
//  ProductCommentListViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/23.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "ProductCommentListViewController.h"
#import <BmobSDK/Bmob.h>
#import "Global.h"
#import "UserService.h"
#import "MemberLoginViewController.h"

@interface ProductCommentListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) NSArray *commentArray;
@end

@implementation ProductCommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commentButton.layer.borderColor = [MAIN_COLOR CGColor];
    self.commentButton.layer.borderWidth = 1.0;
    self.commentButton.layer.cornerRadius = 8.0;
    [self fetch];
    // Do any additional setup after loading the view.
}
//网络加载数据
- (void)fetch {
    BmobQuery *query = [BmobQuery queryWithClassName:@"ProductComment"];
    [query whereKey:@"product" equalTo:[BmobObject objectWithoutDatatWithClassName:@"Product" objectId:self.productId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            self.commentArray = array;
            [self.tableView reloadData];
        }
    }];
}
#pragma mark 获取行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentArray.count;
}

#pragma mark 自定义单元格
- (UITableViewCell *)tableView:tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"comment"];
    BmobObject *comment = self.commentArray[indexPath.row];
    cell.textLabel.text = [comment objectForKey:@"content"];
    return cell;
}
//发布评价按钮
- (IBAction)commentButtonPress:(id)sender {
    UserService *service = [UserService getInstance];
    [service actionWithUser:^(BmobUser *user) {
        [self performSegueWithIdentifier:@"submit" sender:self];
    } failBlock:^{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MemberLoginViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"login"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
