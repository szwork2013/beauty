//
//  StoreDetailTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/2.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "StoreDetailTableViewController.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"

@interface StoreDetailTableViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *imagesScrollView;
//服务器抓取的数据
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *businessHour;
@property (weak, nonatomic) IBOutlet UITextView *descriptTextView;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
//拨号
@property (weak, nonatomic) IBOutlet UIButton *callButton;

//@property (strong, nonatomic) IBOutlet MKMapView *locationMapView;


@end

@implementation StoreDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset=UIEdgeInsetsMake(-36, 0, 0, 0);
    [self fetchStoreData];
    self.callButton.layer.borderColor = [[UIColor colorWithRed:158.0/255.0 green:122.0/255.0 blue:183.0/255.0 alpha:1.0]CGColor];
    self.callButton.layer.borderWidth = 1.0;
    self.callButton.layer.cornerRadius = 5.0;
}
#pragma mark - 服务器抓取
- (void)fetchStoreData {
    BmobQuery *storeQuery = [BmobQuery queryWithClassName:@"Store"];
    [storeQuery getObjectInBackgroundWithId:self.shopObjectId block:^(BmobObject *object, NSError *error) {
        self.nameLabel.text         = [object objectForKey:@"name"];
        self.businessHour.text      = [object objectForKey:@"businessHour"];
        self.phoneLabel.text        = [object objectForKey:@"phone"];
        self.addressLabel.text      = [object objectForKey:@"address"];
//        店铺简介，使用富文本
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 7;
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:16],
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        self.descriptTextView.attributedText = [[NSAttributedString alloc] initWithString:[object objectForKey:@"descript"] attributes:attributes];
        
        //banner
        CGFloat imageWidth = 375.0;
        CGFloat imageHeight = 181.0;
        NSArray *imagesArray = [object objectForKey:@"images"];
        self.imagesScrollView.contentSize = CGSizeMake(imageWidth * imagesArray.count, imageHeight);
        
        for (int i = 0; i < imagesArray.count; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageWidth * i, 0, imageWidth, imageHeight)];
            [imageView setImageWithURL:[NSURL URLWithString:imagesArray[i]]];
//            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.imagesScrollView addSubview:imageView];
        }
        
    }];
}

- (IBAction)callMe:(id)sender {
    NSString *telStr = self.phoneLabel.text;
    if (![telStr isEqualToString:@""]) {
        NSString *telUrlStr = [NSString stringWithFormat:@"telprompt:%@",telStr];
        NSURL *url = [NSURL URLWithString:telUrlStr];
        [[UIApplication sharedApplication]openURL:url];
    }
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
