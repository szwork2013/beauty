//
//  HomeViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/3.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "HomeViewController.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"
#import "ProductTableViewCell.h"
#import "Global.h"
#import "SecondLevelTableViewController.h"

@interface HomeViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
//置顶海报轮播
@property (weak, nonatomic) IBOutlet UIScrollView *recommendScrollView;
@property(strong,nonatomic) UIPageControl *pageControl;
//产品试用列表
@property (weak,nonatomic) IBOutlet UITableView *productTableView;
//产品试用数据
@property (strong,nonatomic) NSArray *productArray;
//查看所有图标
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
//产品分类
@property (weak, nonatomic) IBOutlet UIView *categoryView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*propery init*/
    //更多按钮
    self.moreButton.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.moreButton.layer.borderWidth = 1.0;
    self.moreButton.layer.cornerRadius = 4.0;

    [self fetchRecommendScrollView];
    [self fetchProducts];
    [self fetchCategory];
    // Do any additional setup after loading the view.
}
#pragma mark 获取一级分类
-(void) fetchCategory {
    BmobQuery *query = [BmobQuery queryWithClassName:@"ProductFirstLevel"];
    [query orderByAscending:@"rank"];
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            //init width height margin
            CGFloat width = 39.0;
            CGFloat height = width;
            CGFloat margin = 30.0;
            for (int i = 0; i < array.count; i++) {
                int row = i / 5;
                int column = i % 5;
                //image view
                CGRect imageRect = CGRectMake(margin + (margin + width) * column, margin + (margin + height) * row, width, height);
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageRect];
                BmobFile *imageFile = [array[i]objectForKey:@"avatar"];
                [imageView setImageWithURL:[NSURL URLWithString:imageFile.url]];
                [self.categoryView addSubview:imageView];
                //button
                UIButton *button = [[UIButton alloc]initWithFrame:imageRect];
                [button addTarget:self action:@selector(pushSecondLevel) forControlEvents:UIControlEventTouchUpInside];
                [self.categoryView addSubview:button];
                //label
                CGRect labelRect = imageRect;
                labelRect.origin.y += height;
                UILabel *nameLabel = [[UILabel alloc]initWithFrame:labelRect];
                nameLabel.tintColor = [UIColor colorWithWhite:0.6 alpha:1.0];
                nameLabel.font = [UIFont systemFontOfSize:12.0];
                nameLabel.adjustsFontSizeToFitWidth = YES;
                nameLabel.textAlignment = NSTextAlignmentCenter;
                nameLabel.text = [array[i]objectForKey:@"name"];
                [self.categoryView addSubview:nameLabel];
            }
        }
    }];
}

#pragma mark 获取试用产品数据源
-(void) fetchProducts {
    self.productArray = [NSArray array];
    BmobQuery *query = [[BmobQuery alloc]initWithClassName:@"TryEvent"];
    [query includeKey:@"product"];
    [query whereKey:@"endTime" greaterThanOrEqualTo:[NSDate date]];
    [query orderByAscending:@"endTime"];
    query.limit = 4;
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            self.productArray = array;
            [self.productTableView reloadData];
        }
    }];
}

#pragma mark fetch data for banner scrollView
-(void) fetchRecommendScrollView {
    BmobQuery *query = [[BmobQuery alloc]initWithClassName:@"Recommend"];
    [query whereKey:@"type" equalTo:[NSNumber numberWithInteger:2]];
    [query orderByAscending:@"rank"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        //get scroll view rect
        CGRect scrollRect = self.recommendScrollView.frame;
        //set scroll view content size
        self.recommendScrollView.contentSize = CGSizeMake(scrollRect.size.width * array.count, scrollRect.size.height);
        //init ImageView count of array.count
        for (int i = 0; i < array.count; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i * scrollRect.size.width, 0, scrollRect.size.width, scrollRect.size.height)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            BmobObject *object = array[i];
            BmobFile *image = [object objectForKey:@"image"];

            [imageView setImageWithURL:[NSURL URLWithString:image.url]];
            [self.recommendScrollView addSubview:imageView];
        }
        self.pageControl = [[UIPageControl alloc]init];

        CGFloat width = 20 * array.count;
        CGFloat height = 20;
        self.pageControl.frame = CGRectMake(self.view.frame.size.width - width, self.recommendScrollView.frame.size.height - height, width, height);
        self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
        self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        self.pageControl.numberOfPages = array.count;
        self.recommendScrollView.delegate = self;
        [self.mainScrollView addSubview:self.pageControl];
    }];
}
//进入二级分类
-(void) pushSecondLevel {
    [self performSegueWithIdentifier:@"secondLevel" sender:self];
}
#pragma mark Delegate of banner ScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSUInteger currentPage = (int)scrollView.contentOffset.x / self.view.frame.size.width;
    self.pageControl.currentPage = currentPage;
}


#pragma mark - Delegate and Datasouce of ProductTableView
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.productArray.count;
}

#pragma mark 自定义单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"ProductTableViewCell" owner:self options:nil]firstObject];
    BmobObject *product = [self.productArray[indexPath.row]objectForKey:@"product"];
    BmobFile *avatar = [product objectForKey:@"avatar"];
    [cell.thumbImageView setImageWithURL:[NSURL URLWithString:avatar.url]];
    cell.titleLabel.text = [product objectForKey:@"name"];
    cell.commentCountLabel.text = [[product objectForKey:@"commentCount"]stringValue];
    cell.averagePriceLabel.text = [[product objectForKey:@"averagePrice"]stringValue];
//    评分星级
    NSNumber *starFullNum = [NSNumber numberWithInteger:ceil([[product objectForKey:@"mark"]floatValue])];
    CGFloat width = 9.0;
    CGFloat height = 9.0;
    CGFloat margin = 2.0;
    for (int i = 0; i <= 4; i++) {
        UIImageView *emptyImageView = [[UIImageView alloc]initWithFrame:CGRectMake((width + margin) * i, 0, width, height)];
        [emptyImageView setImage:[UIImage imageNamed:@"star_empty"]];
        [cell.starView addSubview:emptyImageView];
    }
//    NSLog(@"%@ %@",[product objectForKey:@"mark"],starFullNum);
    for (int i = 0; i < [starFullNum intValue]; i++) {
        UIImageView *fullImageView = [[UIImageView alloc]initWithFrame:CGRectMake((width + margin) * i, 0, width, height)];
        [fullImageView setImage:[UIImage imageNamed:@"star_full"]];
        [cell.starView addSubview:fullImageView];
    }
    return cell;
}

#pragma mark 单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120.0;
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //which segue works
    SecondLevelTableViewController *vc = (SecondLevelTableViewController *)segue.destinationViewController;
    vc.firstLevelId = @"LeBD666H";
    
}


@end
