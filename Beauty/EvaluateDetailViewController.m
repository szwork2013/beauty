//
//  EvaluateDetailViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/7.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "EvaluateDetailViewController.h"
#import <BmobSDK/Bmob.h>
#import "ProductDetailTableViewController.h"

@interface EvaluateDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *productTableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) BmobObject *product;

@end

@implementation EvaluateDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"评测详情";
    [self fetchProduct];
    // Do any additional setup after loading the view.
}

#pragma mark 获取关联的产品信息
- (void)fetchProduct {
    BmobQuery *query = [BmobQuery queryWithClassName:@"Evaluate"];
    [query includeKey:@"product"];
    [query getObjectInBackgroundWithId:self.evaluateId block:^(BmobObject *object, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            self.product = [object objectForKey:@"product"];
            [self.productTableView reloadData];
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - tableview delegate
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"product" forIndexPath:indexPath];
    cell.textLabel.text = [self.product objectForKey:@"name"];
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ProductDetailTableViewController *vc = segue.destinationViewController;
    vc.productId = self.product.objectId;
}



@end
