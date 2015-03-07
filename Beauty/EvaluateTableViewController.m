//
//  EvaluateTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/6.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "EvaluateTableViewController.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"

@interface EvaluateTableViewController ()
@property (nonatomic, strong) NSArray *EvaluateArray;
@end

@implementation EvaluateTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationItem.title = @"评测室";
    [self fetchEvaluate];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)fetchEvaluate {
    self.EvaluateArray = [NSArray array];
    BmobQuery *query = [BmobQuery queryWithClassName:@"Evaluate"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            self.EvaluateArray = array;
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.EvaluateArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"evaluate" forIndexPath:indexPath];
    UIImageView *avatarImageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *descriptLabel = (UILabel *)[cell viewWithTag:3];
    BmobObject *evaluate = self.EvaluateArray[indexPath.section];
    BmobFile *avatarImage = [evaluate objectForKey:@"avatar"];
    [avatarImageView setImageWithURL:[NSURL URLWithString:avatarImage.url]];
    nameLabel.text = [evaluate objectForKey:@"name"];
    descriptLabel.text = [evaluate objectForKey:@"descript"];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 225.0;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self performSegueWithIdentifier:@"evaluateDetail" sender:self];
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
