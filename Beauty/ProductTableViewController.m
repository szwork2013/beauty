//
//  ProductTableViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/5.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "ProductTableViewController.h"
#import "ProductTryTableViewCell.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+AFNetworking.h"
#import "ProductDetailTableViewController.h"
#import "StarView.h"
#import "Global.h"
#import "SVPullToRefresh.h"
#import "SVProgressHUD.h"
#import "CommonUtil.h"
#import "JSDropDownMenu.h"

@interface ProductTableViewController ()<UITableViewDataSource,UITableViewDelegate,JSDropDownMenuDataSource,JSDropDownMenuDelegate>
@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *productArray;
@property (nonatomic,assign) NSInteger page;
//三大排序方式
@property (nonatomic,strong) NSArray *orderArray;
@property (nonatomic,assign) NSInteger currentOrderIndex;
@property (nonatomic,strong) NSArray *priceArray;
@property (nonatomic,assign) NSInteger currentPriceIndex;
@property (nonatomic,strong) NSArray *brandArray;
@property (nonatomic,assign) NSInteger currentBrandIndex;
@property (nonatomic,strong) NSMutableDictionary *param;
@end

@implementation ProductTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    变量初始化
    self.param = [NSMutableDictionary dictionary];
    [self fetchTitle];
//    生成下拉分类菜单
    [self setupDropDownMenu];
    self.productArray = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self fetchProduct:self.page param:nil];
//    添加无限上拉刷新
    __weak ProductTableViewController *weakSelf = self;
    __weak UITableView *weakTableView = self.tableView;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        weakSelf.page ++;
        [weakSelf fetchProduct:PER_PAGE * weakSelf.page param:weakSelf.param];
        [weakTableView.infiniteScrollingView stopAnimating];
    }];
}
#pragma mark 生成下拉分类菜单
- (void)setupDropDownMenu {
    self.orderArray = @[@{@"orderKey":@"mark",@"title":@"按口碑排序"},@{@"orderKey":@"commentCount",@"title":@"按点评数排序"},@{@"orderKey":@"starCount",@"title":@"按欲望指数排序"}];
    self.priceArray = @[@"100元以下",@"100-500元",@"500元以上"];
    JSDropDownMenu *menu = [[JSDropDownMenu alloc] initWithOrigin:CGPointMake(0, 64) andHeight:44];
    menu.indicatorColor = [UIColor colorWithRed:175.0f/255.0f green:175.0f/255.0f blue:175.0f/255.0f alpha:1.0];
    menu.separatorColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0];
    menu.textColor = [UIColor colorWithRed:83.f/255.0f green:83.f/255.0f blue:83.f/255.0f alpha:1.0f];
    menu.dataSource = self;
    menu.delegate = self;
    [self.view addSubview:menu];
    
    BmobQuery *brandQuery = [BmobQuery queryWithClassName:@"Brand"];
    [brandQuery orderByAscending:@"rank"];
    [brandQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
//        获取品牌列表
        self.brandArray = array;
    }];
}

#pragma mark -
- (NSInteger)numberOfColumnsInMenu:(JSDropDownMenu *)menu {
    return 3;
}

-(BOOL)displayByCollectionViewInColumn:(NSInteger)column{
    return NO;
}

-(BOOL)haveRightTableViewInColumn:(NSInteger)column{
    return NO;
}

-(CGFloat)widthRatioOfLeftColumn:(NSInteger)column{
    return 1;
}
//获取当前选中项
-(NSInteger)currentLeftSelectedRow:(NSInteger)column{
    if (column == 0) {
        return self.currentOrderIndex;
    } else if (column == 1) {
        return self.currentPriceIndex;
    }
    return self.currentBrandIndex;

}
//获取各列行数
- (NSInteger)menu:(JSDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column leftOrRight:(NSInteger)leftOrRight leftRow:(NSInteger)leftRow{
    if (column == 0) {
        return self.orderArray.count;
    } else if (column == 1) {
        return self.priceArray.count;
    }
    return self.brandArray.count;
}
//获取顶部默认标题
- (NSString *)menu:(JSDropDownMenu *)menu titleForColumn:(NSInteger)column{
    if (column == 0) {
        return @"口碑";
    } else if (column == 1) {
        return @"价格";
    }
    return @"品牌";
}
//获取各单元格标题
- (NSString *)menu:(JSDropDownMenu *)menu titleForRowAtIndexPath:(JSIndexPath *)indexPath {
    if (indexPath.column == 0) {
        return [self.orderArray[indexPath.row] objectForKey:@"title"];
    } else if (indexPath.column == 1) {
        return self.priceArray[indexPath.row];
    }
    return [self.brandArray[indexPath.row] objectForKey:@"name"];
}
#pragma mark 点击单元格
- (void)menu:(JSDropDownMenu *)menu didSelectRowAtIndexPath:(JSIndexPath *)indexPath {
    if (indexPath.column == 0) {
        self.currentOrderIndex = indexPath.row;
        [self.param setObject:[self.orderArray[indexPath.row] objectForKey:@"orderKey"] forKey:@"order"];
    } else if (indexPath.column == 1) {
        self.currentPriceIndex = indexPath.row;
        [self.param setObject:[NSNumber numberWithInteger:indexPath.row] forKey:@"price"];
    } else {
        self.currentBrandIndex = indexPath.row;
        [self.param setObject:[self.brandArray[indexPath.row] objectId] forKey:@"brand"];
    }
//    1.清空数据源，2.页码赋值为零，3.重新fetchData
    [self.productArray removeAllObjects];
    self.page = 0;
    [self fetchProduct:self.page param:self.param];
//    刷新表单结果
}

#pragma mark -
#pragma mark 设置分类标题
-(void) fetchTitle{
    BmobQuery *query = [BmobQuery queryWithClassName:@"ProductSecondLevel"];
    [query getObjectInBackgroundWithId:self.secondLevelId block:^(BmobObject *object, NSError *error) {
        self.navigationItem.title = [object objectForKey:@"name"];;
    }];
}

#pragma mark 获取数据
- (void)fetchProduct:(NSInteger)skip param:(NSMutableDictionary *)param {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Product"];
    bquery.skip = skip;
    bquery.limit = PER_PAGE;
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:@"ProductSecondLevel" objectId:self.secondLevelId];
    [bquery whereObjectKey:@"products" relatedTo:obj];
//    筛选条件
//    1.排序方式
    if ([self.param objectForKey:@"order"]) {
        [bquery orderByDescending:[self.param objectForKey:@"order"]];
    } else {
        [bquery orderByAscending:@"rank"];
    }
//    2.价格区间
//    3.品牌
    
    NSArray *averagePriceArray = nil;
//    NSArray *averagePriceArrayMiddle =  @[@{@"averagePrice":@{@"$gt":@100}},@{@"averagePrice":@{@"$lt":@500}}];
//    NSArray *averagePriceArrayMore =  @[@{@"averagePrice":@{@"$gt":@500}}];
    if ([self.param objectForKey:@"price"]) {
        if ([[self.param objectForKey:@"price"] integerValue] == 0) {
            averagePriceArray =  @[@{@"averagePrice":@{@"$lte":@100}}];
        } else if ([[self.param objectForKey:@"price"] integerValue] == 1) {
            averagePriceArray =  @[@{@"averagePrice":@{@"$gte":@100}},@{@"averagePrice":@{@"$lte":@500}}];
        } else {
            averagePriceArray = @[@{@"averagePrice":@{@"$gte":@500}}];
        }
        [bquery addTheConstraintByAndOperationWithArray:averagePriceArray];
    }
    
    if ([self.param objectForKey:@"brand"]) {
        [bquery whereKey:@"brand" equalTo:[BmobObject objectWithoutDatatWithClassName:@"Brand" objectId:[self.param objectForKey:@"brand"]]];
    }
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array.count == 0) {
            if (self.page == 0) {
                [SVProgressHUD showSuccessWithStatus:NO_DATAS];
                [self.productArray removeAllObjects];
            } else {
                [SVProgressHUD showSuccessWithStatus:NO_MORE];
            }
        }else{
            [self.productArray addObjectsFromArray: array];
        }
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//获取条数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.productArray.count;
}

//自定义单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CommonUtil fetchProductShowCell:self.productArray[indexPath.row] index:1];

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"productDetail" sender:self];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ProductDetailTableViewController *vc = segue.destinationViewController;
    vc.productId = [self.productArray[self.tableView.indexPathForSelectedRow.row] objectId];
}


@end
