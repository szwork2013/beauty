//
//  SecondLevelTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/5.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "SecondLevelTableViewController.h"
#import <BmobSDK/Bmob.h>

@interface SecondLevelTableViewController ()
@property (nonatomic,strong) NSArray *secondLevelArray;
@end

@implementation SecondLevelTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchTitle];
    [self fetchSecondLevel];

}
#pragma mark 标题栏
-(void) fetchTitle {
    BmobQuery *query = [BmobQuery queryWithClassName:@"ProductFirstLevel"];
    [query getObjectInBackgroundWithId:self.firstLevelId block:^(BmobObject *object, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            self.navigationItem.title = [object objectForKey:@"name"];

        }
    }];
}

#pragma mark 加载二级分类到tableview
-(void) fetchSecondLevel{
    self.secondLevelArray = [NSArray array];
    BmobQuery *query = [[BmobQuery alloc]initWithClassName:@"ProductSecondLevel"];
    [query whereKey:@"firstLevel" equalTo:self.firstLevelId];
    [query orderByAscending:@"rank"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            self.secondLevelArray = array;
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
    return self.secondLevelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"secondLevel" forIndexPath:indexPath];
    BmobObject *secondLevel = self.secondLevelArray[indexPath.row];
    cell.textLabel.text = [secondLevel objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"共有%@款产品",[[secondLevel objectForKey:@"count"]stringValue]];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
