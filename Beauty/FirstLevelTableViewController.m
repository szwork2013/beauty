//
//  FirstLevelTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/17.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "FirstLevelTableViewController.h"
#import <BmobSDK/Bmob.h>
#import "SecondLevelTableViewController.h"
#import "CommonUtil.h"
@interface FirstLevelTableViewController ()
@property (nonatomic, strong) NSArray *firstLevelArray;
@end

@implementation FirstLevelTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden = YES;
    [self fetch];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CommonUtil updateTableViewHeight:self];
}
- (void)fetch {
    BmobQuery *query = [BmobQuery queryWithClassName:@"ProductFirstLevel"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            self.firstLevelArray = array;
            [self.tableView reloadData];
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return self.firstLevelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"firstLevel" forIndexPath:indexPath];
    BmobObject *firstLevel = self.firstLevelArray[indexPath.row];
    cell.textLabel.text = [firstLevel objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"共有%@款产品",[[firstLevel objectForKey:@"count"]stringValue]];
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SecondLevelTableViewController *vc = segue.destinationViewController;
    vc.firstLevelId = [self.firstLevelArray[self.tableView.indexPathForSelectedRow.row]objectId];
}


@end
