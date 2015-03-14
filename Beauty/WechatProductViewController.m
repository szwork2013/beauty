//
//  WechatProductViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/8.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "WechatProductViewController.h"
#import "SlidePageViewController.h"
#import "WechatProductDetailTableViewController.h"
#import "XHMenu.h"
#import "XHScrollMenu.h"
#import <BmobSDK/Bmob.h>

@interface WechatProductViewController ()<XHScrollMenuDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) XHScrollMenu *scrollMenu;
@property (nonatomic, strong) NSMutableArray *menus;
@property (nonatomic, assign) BOOL shouldObserving;

@end

@implementation WechatProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden = YES;
    [self setup];
//    self.navigationItem.title = @"微商好产品";
//    SlidePageViewController *pageViewController = [[SlidePageViewController alloc]initWithNibName:@"SlidePageViewController" bundle:[NSBundle mainBundle]];
//    pageViewController.sourceViewController = (UITableViewController *)self;
//    [self.view addSubview:pageViewController.view];
}
- (void)setup {
    self.shouldObserving = YES;
    
    _scrollMenu = [[XHScrollMenu alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), 36)];
    _scrollMenu.backgroundColor = [UIColor colorWithWhite:0.902 alpha:1.000];
    _scrollMenu.delegate = self;
    //    _scrollMenu.selectedIndex = 3;
    [self.view addSubview:self.scrollMenu];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_scrollMenu.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(_scrollMenu.frame))];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    
    [self.view addSubview:self.scrollView];

    //获取分类
    
    BmobQuery *query = [BmobQuery queryWithClassName:@"WechatClassify"];
    [query orderByAscending:@"rank"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            
            for (int i = 0; i < array.count; i++) {
                XHMenu *menu = [[XHMenu alloc] init];
                menu.title = [array[i]objectForKey:@"name"];
                
                menu.titleNormalColor = [UIColor grayColor];
                menu.titleSelectedColor = [UIColor darkGrayColor];
                menu.titleFont = [UIFont boldSystemFontOfSize:16];
                [self.menus addObject:menu];
                
                UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
                logoImageView.frame = CGRectMake(i * CGRectGetWidth(_scrollView.bounds), 0, CGRectGetWidth(_scrollView.bounds), CGRectGetHeight(_scrollView.bounds));
                [_scrollView addSubview:logoImageView];
            }
            [_scrollView setContentSize:CGSizeMake(self.menus.count * CGRectGetWidth(_scrollView.bounds), CGRectGetHeight(_scrollView.bounds))];
            [self startObservingContentOffsetForScrollView:_scrollView];
            
            _scrollMenu.menus = self.menus;
            [_scrollMenu reloadData];
            
        }
    }];
    

}
/*start
 */
- (NSMutableArray *)menus {
    if (!_menus) {
        _menus = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _menus;
}
- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView
{
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
}

- (void)stopObservingContentOffset
{
    if (self.scrollView) {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
        self.scrollView = nil;
    }
}

- (void)dealloc {
    [self stopObservingContentOffset];
}

- (void)scrollMenuDidSelected:(XHScrollMenu *)scrollMenu menuIndex:(NSUInteger)selectIndex {
    self.shouldObserving = NO;
    [self menuSelectedIndex:selectIndex];
}

- (void)menuSelectedIndex:(NSUInteger)index {
    CGRect visibleRect = CGRectMake(index * CGRectGetWidth(self.scrollView.bounds), 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.scrollView scrollRectToVisible:visibleRect animated:NO];
    } completion:^(BOOL finished) {
        self.shouldObserving = YES;
    }];
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    int currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    [self.scrollMenu setSelectedIndex:currentPage animated:YES calledDelegate:NO];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"] && self.shouldObserving) {
        //每页宽度
        CGFloat pageWidth = self.scrollView.frame.size.width;
        //根据当前的坐标与页宽计算当前页码
        NSUInteger currentPage = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if (currentPage > self.menus.count - 1)
            currentPage = self.menus.count - 1;
        
        CGFloat oldX = currentPage * CGRectGetWidth(self.scrollView.frame);
        if (oldX != self.scrollView.contentOffset.x) {
            BOOL scrollingTowards = (self.scrollView.contentOffset.x > oldX);
            NSInteger targetIndex = (scrollingTowards) ? currentPage + 1 : currentPage - 1;
            if (targetIndex >= 0 && targetIndex < self.menus.count) {
                CGFloat ratio = (self.scrollView.contentOffset.x - oldX) / CGRectGetWidth(self.scrollView.frame);
                CGRect previousMenuButtonRect = [self.scrollMenu rectForSelectedItemAtIndex:currentPage];
                CGRect nextMenuButtonRect = [self.scrollMenu rectForSelectedItemAtIndex:targetIndex];
                CGFloat previousItemPageIndicatorX = previousMenuButtonRect.origin.x;
                CGFloat nextItemPageIndicatorX = nextMenuButtonRect.origin.x;
                CGRect indicatorViewFrame = self.scrollMenu.indicatorView.frame;
                
                if (scrollingTowards) {
                    indicatorViewFrame.size.width = CGRectGetWidth(previousMenuButtonRect) + (CGRectGetWidth(nextMenuButtonRect) - CGRectGetWidth(previousMenuButtonRect)) * ratio;
                    indicatorViewFrame.origin.x = previousItemPageIndicatorX + (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio;
                } else {
                    indicatorViewFrame.size.width = CGRectGetWidth(previousMenuButtonRect) - (CGRectGetWidth(nextMenuButtonRect) - CGRectGetWidth(previousMenuButtonRect)) * ratio;
                    indicatorViewFrame.origin.x = previousItemPageIndicatorX - (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio;
                }
                
                self.scrollMenu.indicatorView.frame = indicatorViewFrame;
            }
        }
    }
}

/*end*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    WechatProductDetailTableViewController *vc = segue.destinationViewController;
//    vc.wechatProductId = @"";
//}


@end
