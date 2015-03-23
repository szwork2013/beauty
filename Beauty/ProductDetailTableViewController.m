//
//  ProductDetailTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/5.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//


#import "ProductDetailTableViewController.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"
#import "StarView.h"
#import "WebViewBrowserController.h"
#import "ProductSellerDataSource.h"
#import "CommonUtil.h"
#import "UserService.h"
#import "MemberLoginViewController.h"
#import "ProductIngredientViewController.h"
#import "Global.h"

@interface ProductDetailTableViewController ()
@property (nonatomic,weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UILabel *commentLabel;
@property (nonatomic,weak) IBOutlet UILabel *averagePrice;
//2次评分
@property (nonatomic,weak) IBOutlet UIView *starView;
@property (nonatomic,weak) IBOutlet UIView *starViewMid;
@property (weak, nonatomic) IBOutlet UILabel *markRate;

@property (weak, nonatomic) IBOutlet UIButton *favorButton;
@property (nonatomic,strong) ProductSellerDataSource *productSellerDataSource;
//使用方法
@property (weak, nonatomic) IBOutlet UITextView *useMethodTextView;
//使用方法高度
@property (assign, nonatomic) CGFloat useMethodHeight;
//产品规格高度
@property (assign, nonatomic) CGFloat parameterHeight;
//肤质比例
@property (weak, nonatomic) IBOutlet UILabel *skinDistributeLabel0;
@property (weak, nonatomic) IBOutlet UILabel *skinDistributeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *skinDistributeLabel2;
@property (weak, nonatomic) IBOutlet UILabel *skinDistributeLabel3;
@property (weak, nonatomic) IBOutlet UILabel *skinDistributeLabel4;

@property (weak, nonatomic) IBOutlet UIView *skinDistributeView0;
@property (weak, nonatomic) IBOutlet UIView *skinDistributeView1;
@property (weak, nonatomic) IBOutlet UIView *skinDistributeView2;
@property (weak, nonatomic) IBOutlet UIView *skinDistributeView3;
@property (weak, nonatomic) IBOutlet UIView *skinDistributeView4;

//年龄分层
@property (weak, nonatomic) IBOutlet UILabel *ageDistributeLabel0;
@property (weak, nonatomic) IBOutlet UILabel *ageDistributeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *ageDistributeLabel2;
@property (weak, nonatomic) IBOutlet UILabel *ageDistributeLabel3;
@property (weak, nonatomic) IBOutlet UILabel *ageDistributeLabel4;

@property (weak, nonatomic) IBOutlet UIView *ageDistributeView0;
@property (weak, nonatomic) IBOutlet UIView *ageDistributeView1;
@property (weak, nonatomic) IBOutlet UIView *ageDistributeView2;
@property (weak, nonatomic) IBOutlet UIView *ageDistributeView3;
@property (weak, nonatomic) IBOutlet UIView *ageDistributeView4;
@property (weak, nonatomic) IBOutlet UIButton *productCommentButton;
//查看全部成分按钮
@property (weak, nonatomic) IBOutlet UIButton *productIngredientButton;
//成分条数
@property (assign, nonatomic) NSInteger productIngredientCount;

//产品规格
@property (strong, nonatomic) NSArray *productParameter;
@end

@implementation ProductDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"产品信息";
    self.tableView.contentInset=UIEdgeInsetsMake(-36, 0, 0, 0);
    [self fetchProduct];
    self.productSellerDataSource = [[ProductSellerDataSource alloc]initWithViewController:self];
    self.sellerTableView.dataSource = self.productSellerDataSource;
    self.sellerTableView.delegate = self.productSellerDataSource;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CommonUtil updateTableViewHeight:self];
    [self fetchFavorStatus];
}
#pragma mark 获取当前收藏状态
-(void)fetchFavorStatus {
    BmobObject *store = [BmobObject objectWithoutDatatWithClassName:@"Product" objectId:self.productId];
    //        判断收藏与否
    UserService *service = [UserService getInstance];
    [service actionWithUser:^(BmobUser *user) {
        BmobQuery *storeQuery = [BmobQuery queryWithClassName:@"Product"];
        [storeQuery whereObjectKey:@"relProductCollect" relatedTo:user];
        //                从当前会员下所有收藏店铺中遍历，看是否找到当前单元格的遍历
        [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            for (int i = 0; i < array.count; i ++) {
                if ([[array[i] objectId] isEqualToString:[store objectId]]) {
                    [self.favorButton setTitle:@"取消收藏" forState:UIControlStateNormal];
                    break;
                } else {
                    [self.favorButton setTitle:@"收藏" forState:UIControlStateNormal];
                }
            }
        }];
    } failBlock:^{
//        收藏按钮不做改变，也不必跳转到登录页
    }];
}
#pragma mark 收藏按钮点击
- (IBAction)favorButtonPress:(id)sender {
    UserService *service = [UserService getInstance];
    
    [service favorButtonPressForProduct:self.productId successBlock:^{
        //更新当前按钮
        if ([self.favorButton.titleLabel.text isEqualToString:@"收藏"]) {
            [self.favorButton setTitle:@"取消收藏" forState:UIControlStateNormal];
        } else {
            [self.favorButton setTitle:@"收藏" forState:UIControlStateNormal];
        }
        
    } failBlock:^{
        MemberLoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}
#pragma mark 查看全部成分
- (IBAction)showProductIngredient:(id)sender {
//    ProductIngredientViewController *productVC = [[ProductIngredientViewController alloc]initWithNibName:@"ProductIngredientViewController" bundle:nil];
//    [self.navigationController pushViewController:productVC animated:YES];
    UIStoryboard *subStoryBoard = [UIStoryboard storyboardWithName:@"Product" bundle:nil];
    ProductIngredientViewController *vc = [subStoryBoard instantiateViewControllerWithIdentifier:@"ProductIngredient"];
    vc.productId = self.productId;
    [self.navigationController pushViewController:vc animated:YES];
    
}
#pragma mark 查看全部评价
- (IBAction)showProductComment:(id)sender {
}
#pragma mark 点击评价按钮
- (IBAction)productCommentPress:(id)sender {
//    跳转登录或点评页
}
#pragma mark 获取产品数据
- (void)fetchProduct {
    BmobQuery *query = [BmobQuery queryWithClassName:@"Product"];
    [query getObjectInBackgroundWithId:self.productId block:^(BmobObject *product, NSError *error) {
        BmobFile *image = [product objectForKey:@"avatar"];
        [self.avatarImageView setImageWithURL:[NSURL URLWithString:image.url]];
        self.nameLabel.text = [product objectForKey:@"name"];
        self.commentLabel.text = [[product objectForKey:@"commentCount"]stringValue];
        self.averagePrice.text = [[product objectForKey:@"averagePrice"]stringValue];
        StarView *view = [[StarView alloc]initWithCount:[product objectForKey:@"mark"] frame:CGRectMake(0, 0, 55.0, 11.0)];
//        换算评分成百分比
        self.markRate.text = [NSString stringWithFormat:@"%.1f",[[product objectForKey:@"mark"] floatValue] * 20];
        StarView *viewMid = [[StarView alloc]initWithCount:[product objectForKey:@"mark"] frame:CGRectMake(0, 0, 55.0, 11.0)];
//        星级图标，2次。
//        计算肤质比例
        [self calculateSkinDistribute:[product objectForKey:@"skinDistribute"]];
        [self calculateAgeDistribute:[product objectForKey:@"ageDistribute"]];
        //        用户使用方法，富文本
        self.useMethodTextView.attributedText = [[NSAttributedString alloc] initWithString:[product objectForKey:@"useMethod"] attributes:[CommonUtil textViewAttribute]];
        [self.useMethodTextView sizeToFit];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationAutomatic];
        //        取得高度
        self.useMethodHeight = self.useMethodTextView.frame.size.height + 8;
        [self.starView addSubview:view];
        [self.starViewMid addSubview:viewMid];
//        获取成分
        [self fetchIngredientByProductId];
//        获取规格
        [self fetchParameterByProductId];
    }];
}

#pragma mark 计算肤质比例
- (void)calculateSkinDistribute:(NSArray *)skinDistribute {
    //最大比例条的宽度
    CGFloat maxWidth = CGRectGetWidth(self.skinDistributeView1.frame);
    CGFloat maxRate = 0;
    //    得到最大比例值，如85%
    for (NSString *rateStr in skinDistribute) {
        CGFloat rate = [rateStr floatValue];
        if (rate > maxRate) {
            maxRate = rate;
        }
    }
    //    依次为5个比例条赋值，与最大值换算而来，并依次为5个百分比赋值
    NSArray *rateViewArray = @[_skinDistributeView0, _skinDistributeView1, _skinDistributeView2, _skinDistributeView3, _skinDistributeView4];
    NSArray *rateColorArray = @[kColor0, kColor1, kColor2, kColor3, kColor4];
    NSArray *rateLabelArray = @[_skinDistributeLabel0, _skinDistributeLabel1, _skinDistributeLabel2, _skinDistributeLabel3, _skinDistributeLabel4];
    for (int i = 0; i < rateViewArray.count; i++) {
        UIView *rateView = rateViewArray[i];
        UIView *subView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [skinDistribute[i] floatValue] / maxRate * maxWidth, 10.0)];
        subView.backgroundColor = rateColorArray[i];
        [rateView addSubview:subView];
//        完成比例条，以下是百分比赋值
        UILabel *rateLabel = rateLabelArray[i];
        rateLabel.text = [NSString stringWithFormat:@"%.f%%",[skinDistribute[i] floatValue]];
    }
}

#pragma mark 计算年龄分层
- (void)calculateAgeDistribute:(NSArray *)ageDistribute {
    //最大比例条的宽度
    CGFloat maxWidth = CGRectGetWidth(self.ageDistributeView1.frame);
    CGFloat maxRate = 0;
    //    得到最大比例值，如85%
    for (NSString *rateStr in ageDistribute) {
        CGFloat rate = [rateStr floatValue];
        if (rate > maxRate) {
            maxRate = rate;
        }
    }
    //    依次为5个比例条赋值，与最大值换算而来，并依次为5个百分比赋值
    NSArray *rateViewArray = @[_ageDistributeView0, _ageDistributeView1, _ageDistributeView2, _ageDistributeView3, _ageDistributeView4];
    NSArray *rateLabelArray = @[_ageDistributeLabel0, _ageDistributeLabel1, _ageDistributeLabel2, _ageDistributeLabel3, _ageDistributeLabel4];
    for (int i = 0; i < rateViewArray.count; i++) {
        UIView *rateView = rateViewArray[i];
        UIView *subView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [ageDistribute[i] floatValue] / maxRate * maxWidth, 10.0)];
        subView.backgroundColor = MAIN_COLOR;
        [rateView addSubview:subView];
        //        完成比例条，以下是百分比赋值
        UILabel *rateLabel = rateLabelArray[i];
        rateLabel.text = [NSString stringWithFormat:@"%.f%%",[ageDistribute[i] floatValue]];
    }
}


#pragma mark 每行高度
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 1) {
        return self.productSellerDataSource.sellerArray.count * 100.0;
    }
    if (indexPath.section == 5 && indexPath.row == 1) {
        return self.useMethodHeight;
    }
    if (indexPath.section == 4 && indexPath.row == 1) {
        if (self.productIngredientCount == 0) {
            return 60.0;
        }
        return 84.0 + self.productIngredientCount * 44.0;
    }
    if (indexPath.section == 6 && indexPath.row == 1) {
        if (self.productParameter.count == 0) {
            return 44.0;
        }
        return self.productParameter.count * 30.0 + 10.0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//获取成分条数
- (void)fetchIngredientByProductId {
    BmobQuery *query = [BmobQuery queryWithClassName:@"ProductIngredient"];
    [query whereKey:@"product" equalTo:[BmobObject objectWithoutDatatWithClassName:@"Product" objectId:self.productId]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        self.productIngredientCount = number >= 5 ? 5 :number;
        if (number == 0) {
            [self.productIngredientButton setTitle:@"暂时没有成分信息" forState:UIControlStateNormal];
            self.productIngredientButton.enabled = NO;
        }
        [self.tableView reloadData];
    }];
}
#pragma mark 获取规格
- (void)fetchParameterByProductId {
    BmobQuery *query = [BmobQuery queryWithClassName:@"ProductParameter"];
    [query whereKey:@"product" equalTo:[BmobObject objectWithoutDatatWithClassName:@"Product" objectId:self.productId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        self.productParameter = array;
        [self.tableView reloadData];
        
    }];
}
#pragma mark 生成单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    if (indexPath.section == 4 && indexPath.row == 1) {
        UIStoryboard *subStoryBoard = [UIStoryboard storyboardWithName:@"Product" bundle:nil];
        ProductIngredientViewController *vc = [subStoryBoard instantiateViewControllerWithIdentifier:@"ProductIngredient"];
        vc.productId = self.productId;
        vc.limit = 5;
        [cell addSubview:vc.view];
        cell.clipsToBounds = YES;
        return cell;
    }else if (indexPath.section == 6 && indexPath.row == 1) {
        for (int i = 0; i < self.productParameter.count; i++) {
            BmobObject *parameter = self.productParameter[i];
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 10 + i * 30, 80, 20)];
            UILabel *valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame), 10 + i * 30, 200, 20)];
            nameLabel.font = [UIFont systemFontOfSize:14.0];
            nameLabel.textColor = [UIColor grayColor];
            nameLabel.text = [NSString stringWithFormat:@"%@:",[parameter objectForKey:@"name"]];
            //分别设置字体大小，颜色，内容
            valueLabel.font = [UIFont systemFontOfSize:14.0];
            valueLabel.textColor = [UIColor grayColor];
            valueLabel.text = [NSString stringWithFormat:@"%@",[parameter objectForKey:@"value"]];
            if ([parameter objectForKey:@"isHighlight"]) {
                nameLabel.textColor = MAIN_COLOR;
                valueLabel.textColor = MAIN_COLOR;
            }
            [cell.contentView addSubview:nameLabel];
            [cell.contentView addSubview:valueLabel];
        }
        if (self.productParameter.count == 0) {
            UILabel *label = [[UILabel alloc]init];
            label.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2.0 , 22.0);
            label.bounds = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44.0);
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"暂时没有产品规格信息";
            label.textColor = [UIColor grayColor];
            [cell addSubview:label];
        }
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    WebViewBrowserController *vc = segue.destinationViewController;
    vc.urlString = self.urlString;
}


@end
