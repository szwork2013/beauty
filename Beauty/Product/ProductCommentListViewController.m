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
#import "CommonUtil.h"
#import "ProductCommentTableViewCell.h"
#import "StarView.h"
#import "SVPullToRefresh.h"
#import "SVProgressHUD.h"
#define COMMENT_PER_PAGE 10
@interface ProductCommentListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *commentArray;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
//评语高度
@property (strong, nonatomic) NSMutableArray *commentContentHeightArray;
//图片高度
@property (strong, nonatomic) NSMutableArray *commentPhotosHeightArray;
//paged
@property (nonatomic,assign) NSInteger page;
@end

@implementation ProductCommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"所有评价";
    self.commentButton.layer.borderColor = [MAIN_COLOR CGColor];
    self.commentButton.layer.borderWidth = 1.0;
    self.commentButton.layer.cornerRadius = 8.0;
    [self fetchCommentCount];
    self.commentContentHeightArray = [NSMutableArray array];
    self.commentPhotosHeightArray = [ NSMutableArray array];
//    初始化后取评价数
    self.commentArray = [NSMutableArray array];
    [self fetch:0];
    
    //    添加无限上拉刷新
    __weak ProductCommentListViewController *weakSelf = self;
    __weak UITableView *weakTableView = self.tableView;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        weakSelf.page ++;
        [weakSelf fetch:COMMENT_PER_PAGE * weakSelf.page];
        [weakTableView.infiniteScrollingView stopAnimating];
    }];
}
- (void)fetchCommentCount {
    BmobQuery *query = [BmobQuery queryWithClassName:@"ProductComment"];
    [query whereKey:@"product" equalTo:[BmobObject objectWithoutDatatWithClassName:@"Product" objectId:self.productId]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        self.commentCountLabel.text = [NSString stringWithFormat:@"%zi",number];
    }];
}
//网络加载数据
- (void)fetch:(NSInteger)skip {
    BmobQuery *query = [BmobQuery queryWithClassName:@"ProductComment"];
    [query includeKey:@"user"];
    query.limit = COMMENT_PER_PAGE;
    query.skip = skip;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"product" equalTo:[BmobObject objectWithoutDatatWithClassName:@"Product" objectId:self.productId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array.count == 0){
            [SVProgressHUD showSuccessWithStatus:NO_MORE];
        } else {
            for (NSDictionary *commentObject in array) {
                [self.commentArray addObject:commentObject];
                [commentObject objectForKey:@"content"];
                [self.commentContentHeightArray addObject:@""];
            }
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
    cell = [CommonUtil fetchProductCommentCell:comment];
    return cell;
}
#pragma mark 单元格高度
- (CGFloat) tableView:tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BmobObject *comment = self.commentArray[indexPath.row];
    NSString *text = [comment objectForKey:@"content"];
    
    CGSize constraint = CGSizeMake(self.view.frame.size.width - (10 * 2), 20000.0f);
    

    CGRect rect = [text boundingRectWithSize:constraint
                         options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)
                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.5]}
                         context:NULL];
    
    //photo numbers
    NSArray *photosArray = [comment objectForKey:@"photos"];
    NSInteger photoCount = [photosArray count];
    long row = ceil(photoCount / 3.0);
    CGFloat photoGalleryHeight = row * (self.view.frame.size.width - 10 * 2) / 3.0;
    
    return 78.0 + rect.size.height + photoGalleryHeight;
}
//发布评价按钮
- (IBAction)commentButtonPress:(id)sender {
    UserService *service = [UserService getInstance];
    [service actionWithUser:^(BmobUser *user) {
        [self performSegueWithIdentifier:@"publish" sender:self];
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
