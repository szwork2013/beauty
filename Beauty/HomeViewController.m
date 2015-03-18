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
#import "ProductTryTableViewCell.h"
#import "Global.h"
#import "SecondLevelTableViewController.h"
#import "StarView.h"
#import "CommonUtil.h"
#import "TryEventProductDetailTableViewController.h"
#import "ActivityViewController.h"

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
//firstLevelId button
@property (strong, nonatomic) NSMutableDictionary *buttonTagDictionary;
@property (strong, nonatomic) NSString *currentFirstLevelId;
//推荐图片张数
@property (assign, nonatomic) NSUInteger imageCount;
//海报关联的activity
@property (strong, nonatomic) NSMutableDictionary *activityDictionary;
@property (assign, nonatomic) NSString *activityId;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tabBarController.tabBar.hidden = NO;
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
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
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
            self.buttonTagDictionary = [[NSMutableDictionary alloc]init];
            
            //init width height margin
            CGFloat width = 39.0;
            CGFloat height = width;
            CGFloat offsetY = - 10.0;

            for (int i = 0; i < array.count; i++) {
                int row = i / 5;
                int column = i % 5;
                //image view
//                CGRect imageRect = CGRectMake(marginLeft + (marginLeft + height) * column, margin + (margin + width) * row, width, height);
                UIImageView *imageView = [[UIImageView alloc]init];
                imageView.bounds = CGRectMake(0, 0, width, height);
                imageView.center = CGPointMake(SCREEN_WIDTH / 5.0 * (column + 0.5), offsetY + self.categoryView.frame.size.height / 2.0 * (row + 0.5));
                BmobFile *imageFile = [array[i]objectForKey:@"avatar"];
                if (i != 9) {
                    [imageView setImageWithURL:[NSURL URLWithString:imageFile.url]];
                } else {
                    [imageView setImage:[UIImage imageNamed:@"cat_more"]];
                }
                [self.categoryView addSubview:imageView];
                UIButton *button = [[UIButton alloc]initWithFrame:imageView.frame];
                button.tag = i;
                [self.buttonTagDictionary setObject:[array[i] objectId] forKey:[NSNumber numberWithInt:i]];
                [button addTarget:self action:@selector(pushSecondLevel:) forControlEvents:UIControlEventTouchUpInside];
                [self.categoryView addSubview:button];
                //label
                UILabel *nameLabel = [[UILabel alloc]init];
                nameLabel.center = CGPointMake(imageView.center.x, CGRectGetMaxY(imageView.frame) + 22);
                nameLabel.bounds = CGRectMake(0, 0, 60.0, 16.0);
                nameLabel.tintColor = [UIColor colorWithWhite:0.6 alpha:1.0];
                nameLabel.font = [UIFont systemFontOfSize:12.0];
                nameLabel.adjustsFontSizeToFitWidth = YES;
                nameLabel.textAlignment = NSTextAlignmentCenter;
                if (i != 9) {
                    nameLabel.text = [array[i]objectForKey:@"name"];
                } else {
                    nameLabel.text = @"更多";
                }
                
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
    query.limit = 5;
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            self.productArray = array;
            
            [self.productTableView reloadData];
//            配置高度
            self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.contentSize.width, self.mainScrollView.contentSize.height + (array.count - 1) * 120 - 115);
        }
    }];
}

#pragma mark 获取图片轮播
-(void) fetchRecommendScrollView {
    
    BmobQuery *query = [[BmobQuery alloc]initWithClassName:@"Recommend"];
    [query whereKey:@"type" equalTo:[NSNumber numberWithInteger:2]];
    [query includeKey:@"storeActivity"];
    [query orderByAscending:@"rank"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        self.activityDictionary = [[NSMutableDictionary alloc]init];
        self.imageCount = array.count;
        //get scroll view rect
        CGRect scrollRect = self.recommendScrollView.frame;
        //set scroll view content size
        self.recommendScrollView.contentSize = CGSizeMake(scrollRect.size.width * array.count, scrollRect.size.height);
        //init ImageView count of array.count
        for (int i = 0; i < array.count; i++) {
            self.activityDictionary[[NSString stringWithFormat:@"%zi",i]] = [[array[i]objectForKey:@"storeActivity"]objectId];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i * scrollRect.size.width, 0, scrollRect.size.width, scrollRect.size.height)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            BmobObject *object = array[i];
            BmobFile *image = [object objectForKey:@"image"];

            [imageView setImageWithURL:[NSURL URLWithString:image.url]];
            [self.recommendScrollView addSubview:imageView];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.bounds = imageView.bounds;
            button.center = imageView.center;
            [button addTarget:self action:@selector(scrollViewPress:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i;
            [self.recommendScrollView addSubview:button];
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
        [self updateScrollView];
    }];
}

//按钮点击事件
- (void)scrollViewPress:(UIButton *)button {
    self.activityId = [self.activityDictionary objectForKey:[NSString stringWithFormat:@"%zi",button.tag]];
    [self performSegueWithIdentifier:@"activity" sender:self];

}
- (void) updateScrollView
{

    NSTimer *myTimer = nil;
//    [myTimer invalidate];

    NSTimeInterval timeInterval = 3;
    //timer
    myTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self
                                             selector:@selector(handleMaxShowTimer:)
                                             userInfo: nil
                                              repeats:YES];
}

- (void)handleMaxShowTimer:(NSTimer*)theTimer
{
    CGPoint pt = self.recommendScrollView.contentOffset;
    NSUInteger count = self.imageCount;
    if(pt.x == self.recommendScrollView.frame.size.width * (count - 1)){
        [self.recommendScrollView scrollRectToVisible:CGRectMake(0,0,self.recommendScrollView.frame.size.width,self.recommendScrollView.frame.size.height) animated:YES];
        self.pageControl.currentPage = 0;
    } else {
        [self.recommendScrollView scrollRectToVisible:CGRectMake(pt.x+self.recommendScrollView.frame.size.width,0,self.recommendScrollView.frame.size.width,self.recommendScrollView.frame.size.height) animated:YES];
        self.pageControl.currentPage = self.recommendScrollView.contentOffset.x / self.view.frame.size.width + 1;
    }
}

#pragma mark Delegate of banner ScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = self.recommendScrollView.contentOffset.x / self.view.frame.size.width;
}
//左右拖到底的循环
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView.contentOffset.x + scrollView.frame.size.width > scrollView.contentSize.width) {
//        [self.recommendScrollView scrollRectToVisible:CGRectMake(0,0,self.recommendScrollView.frame.size.width,self.recommendScrollView.frame.size.height) animated:YES];
//        self.pageControl.currentPage = 0;
//    } else if (scrollView.contentOffset.x < 0) {
//        [self.recommendScrollView scrollRectToVisible:CGRectMake(self.recommendScrollView.frame.size.width * (self.imageCount - 1),0,self.recommendScrollView.frame.size.width,self.recommendScrollView.frame.size.height) animated:YES];
//        self.pageControl.currentPage = self.imageCount - 1;
//    }
//}

//产品试用单元格点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"tryEventDetail" sender:self];
}
//进入二级分类
-(void) pushSecondLevel:(UIButton *)button {
    if (button.tag == 9) {
        [self performSegueWithIdentifier:@"firstLevel" sender:self];
    } else {
        self.currentFirstLevelId = self.buttonTagDictionary[[NSNumber numberWithLong:button.tag]];
        [self performSegueWithIdentifier:@"secondLevel" sender:self];
    }
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
    ProductShowTableViewCell *cell = [CommonUtil fetchProductShowCell:[self.productArray[indexPath.row]objectForKey:@"product"] index:0];
    return cell;
}

#pragma mark 单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120.0;
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"secondLevel"]) {
        SecondLevelTableViewController *vc = (SecondLevelTableViewController *)segue.destinationViewController;
        vc.firstLevelId = self.currentFirstLevelId;
    } else if ([segue.identifier isEqualToString:@"tryEventDetail"]) {
        TryEventProductDetailTableViewController *vc = segue.destinationViewController;
        vc.productId = [[self.productArray[self.productTableView.indexPathForSelectedRow.row]objectForKey:@"product"] objectId];
    } else if ([segue.identifier isEqualToString:@"firstLevel"]){
        
    } else if ([segue.identifier isEqualToString:@"activity"]) {
        ActivityViewController *vc = segue.destinationViewController;
        vc.objectId = self.activityId;
    }
//    [self setHidesBottomBarWhenPushed:YES];
}


@end
