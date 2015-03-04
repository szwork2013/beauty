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


@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *recommendScrollView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchRecommendScrollView];
    // Do any additional setup after loading the view.
}

-(void) fetchRecommendScrollView {
    BmobQuery *query = [[BmobQuery alloc]initWithClassName:@"Recommend"];
    [query whereKey:@"type" equalTo:[NSNumber numberWithInteger:2]];
    [query orderByAscending:@"rank"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        //get scroll view rect
        CGRect scrollRect = self.recommendScrollView.frame;
        //set scroll view content size
        self.recommendScrollView.contentSize = CGSizeMake(scrollRect.size.width * array.count, scrollRect.size.height);
        for (int i = 0; i < array.count; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i * scrollRect.size.width, 0, scrollRect.size.width, scrollRect.size.height)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            BmobObject *object = array[i];
            BmobFile *image = [object objectForKey:@"image"];

            [imageView setImageWithURL:[NSURL URLWithString:image.url]];
            [self.recommendScrollView addSubview:imageView];
        }
    }];
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
