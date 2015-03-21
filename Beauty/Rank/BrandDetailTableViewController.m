//
//  BrandDetailTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/16.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "BrandDetailTableViewController.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"
#import "Global.h"
#import "ImageBrowserViewController.h"
#import "CommonUtil.h"
@interface BrandDetailTableViewController () <UIWebViewDelegate>
@property (nonatomic ,strong) BmobObject *brandObject;
@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation BrandDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetch];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CommonUtil updateTableViewHeight:self];
}
- (void)fetch {
    BmobQuery *query = [BmobQuery queryWithClassName:@"Brand"];
    [query getObjectInBackgroundWithId:self.brandId block:^(BmobObject *object, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            self.brandObject = object;
            self.navigationItem.title = [object objectForKey:@"name"];
            self.imageArray = [object objectForKey:@"images"];
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
    if (!self.brandObject) {
        return [super numberOfSectionsInTableView:tableView];
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.brandObject) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    if (section == 1) {
        NSArray *array = [self.brandObject objectForKey:@"images"];
        return [array count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"brand"];
    if (!self.brandObject) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    if (indexPath.section == 0) {
        cell = [[UITableViewCell alloc]init];
        cell.textLabel.text = @"图片详情";
    } else if(indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"webView"];
        UIWebView *webView = (UIWebView *)[cell viewWithTag:21];
        webView.delegate = self;
        webView.scrollView.scrollEnabled = NO;
        if (self.webViewHeight == 0.0) {
            
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.brandObject objectForKey:@"webUrl"]]]];
        }
    } else if (indexPath.section == 1){
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:11];
        NSArray *imageArray = [self.brandObject objectForKey:@"images"];
        [imageView setImageWithURL:[NSURL URLWithString:imageArray[indexPath.row]]];
    }
    

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.brandObject) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    if (indexPath.section == 0) {
        return 44.0;
    } else if (indexPath.section == 2) {
        return self.webViewHeight;
    }
//    图片高度 适配多尺寸
    return (140.0 + MARGIN * 2) / 320.0 * SCREEN_WIDTH;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageBrowserViewController *vc = [[ImageBrowserViewController alloc]init];
    vc.selectedIndex = indexPath.row;
    vc.imageArray = self.imageArray;
    [self.navigationController pushViewController:vc animated:YES];
}

//网页加载完成代理方法
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}


@end
