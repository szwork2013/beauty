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
#import "Global.h"
#import "UIImageView+AFNetworking.h"

@interface EvaluateDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *productTableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) BmobObject *product;
@property (strong, nonatomic) NSArray *imageArray;
@property (assign, nonatomic) CGFloat offsetY;
@property (strong, nonatomic) UIWebView *webView;
@end

@implementation EvaluateDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.offsetY = 0;
    self.webView = [[UIWebView alloc]init];
//    self.webView.scrollView.scrollEnabled = NO;
    [self.scrollView addSubview:self.webView];

    self.navigationItem.title = @"评测详情";
    [self fetchProduct];

    // Do any additional setup after loading the view.
}
#pragma mark 网页加载代理
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.webView sizeToFit];
}
- (void)createImageView {
    CGFloat y = 115.0;
    CGFloat margin = 8.0;
//    __block CGFloat offsetY = 0.0;
    for (int i = 0; i < self.imageArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        __weak UIImageView *_imageView = imageView;
//AFN获取图片缓存，并读取其高度，做自适应
        [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.imageArray[i]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            CGFloat imageHeight = image.size.height;
            CGFloat imageWidth = image.size.width;
            CGFloat imageViewWidth = SCREEN_WIDTH - margin - margin;
            CGFloat imageViewHeight = imageViewWidth / (imageWidth / imageHeight);
            
            _imageView.image = image;
            _imageView.frame = CGRectMake(margin, y + i * margin + self.offsetY, imageViewWidth, imageViewHeight);
            self.offsetY += imageViewHeight;
            UIView *seperatedView = [[UIView alloc]initWithFrame:CGRectMake(margin, _imageView.frame.origin.y + imageViewHeight + margin / 2, imageViewWidth, 1)];
            seperatedView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
//            scrollView添加子视图
            [self.scrollView addSubview:seperatedView];
//            scrollView内容高度增加
            self.webView.frame = CGRectMake(0, y + self.offsetY, SCREEN_WIDTH, 400);
            self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, y + self.offsetY + margin * i + margin + self.webView.scrollView.contentSize.height);
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
 
        /*
         //做缩略图，加速加载过程
        [BmobImage cutImageBySpecifiesTheWidth:375*2 height:128*2 quality:90 sourceImageUrl:self.imageArray[i] outputType:kBmobImageOutputBmobFile resultBlock:^(id object, NSError *error) {
            BmobFile *cutImage = (BmobFile *)object;
            [imageView setImageWithURL:[NSURL URLWithString:cutImage.url]];
            imageView.frame = CGRectMake(0, y + 128 * i, 375, 128);
        }];
        
        NSLog(@"%zi",i);
         */
        [self.scrollView addSubview:imageView];
    }
    

}

//- (void)createWebView:(NSString *)url {
//    self.webView = [[UIWebView alloc]init];
//    webView.frame = CGRectMake(0, self.offsetY, SCREEN_WIDTH, 400);
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
//    [self.scrollView addSubview:webView];
//
//}
#pragma mark 获取关联的产品信息
- (void)fetchProduct {
    BmobQuery *query = [BmobQuery queryWithClassName:@"Evaluate"];
    [query includeKey:@"product"];
    [query getObjectInBackgroundWithId:self.evaluateId block:^(BmobObject *object, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            self.product = [object objectForKey:@"product"];
            self.imageArray = [object objectForKey:@"images"];
            self.nameLabel.text = [object objectForKey:@"name"];
            [self.productTableView reloadData];
            [self createImageView];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[object objectForKey:@"webUrl"]]]];
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
