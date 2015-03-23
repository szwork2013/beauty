//
//  ProductIngredientViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/22.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "ProductIngredientViewController.h"
#import "Global.h"
#import <BmobSDK/Bmob.h>

@interface ProductIngredientViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *safeIndexButton;

@property (strong, nonatomic) NSArray *dataArray;
@end

@implementation ProductIngredientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"成分分析";
    self.safeIndexButton.enabled = NO;
    [self safeIndexSummary];
    [self fetch];
}
//获取安全指数
- (void)safeIndexSummary {
    self.safeIndexButton.layer.cornerRadius = 5.0;
    
    NSArray *colorArray = @[kColor3, kColor2, kColor4, kColor0, kColor1];
    BmobQuery *productQuery = [BmobQuery queryWithClassName:@"Product"];
    [productQuery getObjectInBackgroundWithId:self.productId block:^(BmobObject *product, NSError *error) {
        [self.safeIndexButton setTitle:[product objectForKey:@"safeInfo"] forState:UIControlStateNormal];
        self.safeIndexButton.backgroundColor = colorArray[[[product objectForKey:@"safeIndex"]intValue]];

    }];
}
//获取产品成分
- (void)fetch {
    BmobQuery *query = [BmobQuery queryWithClassName:@"ProductIngredient"];
    [query includeKey:@"product"];
    [query orderByAscending:@"updatedAt"];
    query.limit = self.limit;
    [query whereKey:@"product" equalTo:[BmobObject objectWithoutDatatWithClassName:@"Product" objectId:self.productId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        self.dataArray = array;
        [self.tableView reloadData];
    }];
}

-(NSInteger)tableView:tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ingredient" forIndexPath:indexPath];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *effectLabel = (UILabel *)[cell viewWithTag:2];
    UIImageView *scoreImageView = (UIImageView *)[cell viewWithTag:3];
    nameLabel.text = [self.dataArray[indexPath.row] objectForKey:@"name"];
    effectLabel.text = [self.dataArray[indexPath.row] objectForKey:@"effect"];
    scoreImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"safe%d",[[self.dataArray[indexPath.row] objectForKey:@"score"]intValue] + 1]];
    return cell;
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
