//
//  XHRootViewController.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/14.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "XHRootView.h"

@interface XHRootView ()

@end

@implementation XHRootView


/**start
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
    int currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
