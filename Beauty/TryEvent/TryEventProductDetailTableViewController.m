//
//  WechatProductDetailTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/11.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "TryEventProductDetailTableViewController.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"
#import "ProductDetailTableViewController.h"
#import "TryRecordViewController.h"
#import "CommonUtil.h"
#import "Global.h"
#import "ProductShowTableViewCell.h"

@interface TryEventProductDetailTableViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextView *descriptTextView;
@property (weak, nonatomic) IBOutlet UIWebView *webUrlwebView;

//描述高度
@property (assign, nonatomic) CGFloat descriptHeight;
//网页高度
@property (assign, nonatomic) CGFloat webHeight;
//产品对象
@property (strong, nonatomic) BmobObject *productObject;
@end

@implementation TryEventProductDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden = YES;

    //    tableview顶部不留空
    self.tableView.contentInset=UIEdgeInsetsMake(-36, 0, 0, 0);
    [self initWebView];
    [self fetchProduct];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CommonUtil updateTableViewHeight:self];
}
- (void)initWebView {
    
    self.webHeight = 51.0;
    self.webUrlwebView.delegate = self;
    self.webUrlwebView.scrollView.scrollEnabled = NO;
}
- (void)fetchProduct {
    BmobQuery *query = [BmobQuery queryWithClassName:@"TryEvent"];
    [query includeKey:@"product"];
    [query whereKey:@"product" equalTo:[BmobObject objectWithoutDatatWithClassName:@"Product" objectId:self.productId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            BmobObject *object = [array firstObject];
//            获取图像
            BmobFile *avatarFile = [object objectForKey:@"avatar"];
            [self.avatarImageView setImageWithURL:[NSURL URLWithString:avatarFile.url]];
            
            self.productObject = [object objectForKey:@"product"];
            
//            简介
            self.descriptTextView.attributedText = [[NSAttributedString alloc] initWithString:[CommonUtil enterChar:[object objectForKey:@"descript"]] attributes:[CommonUtil textViewAttribute]];
            [self.descriptTextView sizeToFit];
            self.descriptHeight = self.descriptTextView.frame.size.height + 8;
            
//            网页
            
            if (![[object objectForKey:@"webUrl"] isEqualToString:@""]) {
                [self.webUrlwebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[object objectForKey:@"webUrl"]]]];
            }
//            产品id，以备跳转时传值用

            //刷新数据源，以适配单元格高度
            [self.tableView reloadData];
        }
    }];
}

//产品单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        return [CommonUtil fetchProductShowCell:self.productObject index:1];
    }
    
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

//高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    产品摘要
    if (indexPath.section == 1 && indexPath.row == 0) {
        return 120.0;
    }
    
//    图片
    if (indexPath.section == 0 && indexPath.row == 0) {
        return SCREEN_WIDTH * 0.46;
    }
    
//    描述
    if (indexPath.section == 2 && indexPath.row == 1) {
        return self.descriptHeight;
    }
    //    网页
    if (indexPath.section == 3 && indexPath.row == 0) {
        return self.webHeight;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"productDetail" sender:self];
    }
}

//网页加载完成代理方法
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.webHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue] + 44;
    [self.tableView reloadData];

}

- (IBAction)submit:(id)sender {
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"username"]) {
        [self performSegueWithIdentifier:@"submit" sender:self];
    } else {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // 共有两条连线
    if ([segue.identifier isEqualToString:@"productDetail"]) {
        ProductDetailTableViewController *vc = segue.destinationViewController;
        vc.productId = self.productId;
    } else if ([segue.identifier isEqual:@"submit"]) {        
        TryRecordViewController *vc = segue.destinationViewController;
        vc.productId = self.productId;
    }
}
@end
