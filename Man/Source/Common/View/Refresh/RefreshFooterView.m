//
//  RefreshFooterView.m
//  Refresh
//
//  Created by lance  on 16-4-10.
//  Copyright (c) 2016年 qpidnetwork. All rights reserved.
//  上拉加载更多

#import "RefreshFooterView.h"


@interface RefreshFooterView()
@property (assign, nonatomic) NSInteger lastRefreshCount;
@end

@implementation RefreshFooterView
NSString *const RefreshFooterPullToRefresh = @"上拉可以加载更多数据";
NSString *const RefreshFooterReleaseToRefresh = @"松开立即加载更多数据";
NSString *const RefreshFooterRefreshing = @"正在帮你加载数据...";



+ (instancetype)footer{
    return [[RefreshFooterView alloc] init];
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.pullToRefreshText = RefreshFooterPullToRefresh;
        self.releaseToRefreshText = RefreshFooterReleaseToRefresh;
        self.refreshingText = RefreshFooterRefreshing;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.statusLabel.frame = self.bounds;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    // 旧的父控件
    [self.superview removeObserver:self forKeyPath:@"contentSize" context:nil];
    
    if (newSuperview) { // 新的父控件
        // 监听
        [newSuperview addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        
        // 重新调整frame
        [self adjustFrameWithContentSize];
    }
}

#pragma mark 重写调整frame
- (void)adjustFrameWithContentSize{
    // 内容的高度
    CGFloat contentHeight = self.scrollView.scrollContentSizeHeight;
    // 表格的高度
    CGFloat scrollHeight = self.scrollView.scrollContentSizeHeight - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom;
    // 设置位置和尺寸
    self.originY = MAX(contentHeight, scrollHeight);
}

#pragma mark 监听UIScrollView的属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    // 不能跟用户交互，直接返回
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;
    
    if ([@"contentSize" isEqualToString:keyPath]) {
        // 调整frame
        [self adjustFrameWithContentSize];
    } else if ([@"contentOffset" isEqualToString:keyPath]) {
        // 如果正在刷新，直接返回
        if (self.state == RefreshStateRefreshing || self.endingRefresh) return;
        
        // 调整状态
        [self adjustStateWithContentOffset];
    }
}

/**
 *  调整状态
 */
- (void)adjustStateWithContentOffset{
    // 当前的contentOffset
    CGFloat currentOffsetY = self.scrollView.scrollOffsetY;
    // 尾部控件刚好出现的offsetY
    CGFloat happenOffsetY = [self happenOffsetY];
    
    // 如果是向下滚动到看不见尾部控件，直接返回
    if (currentOffsetY <= happenOffsetY) return;
    
    if (self.scrollView.isDragging) {
        // 普通 和 即将刷新 的临界点
        CGFloat normal2pullingOffsetY = happenOffsetY + self.sizeHeight;
        
        if (self.state == RefreshStateNormal && currentOffsetY > normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = RefreshStatePulling;
        } else if (self.state == RefreshStatePulling && currentOffsetY <= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = RefreshStateNormal;
        }
    } else if (self.state == RefreshStatePulling) {// 即将刷新 && 手松开
        // 开始刷新
        self.state = RefreshStateRefreshing;
    }
}

#pragma mark - 状态相关
#pragma mark 设置状态
- (void)setState:(RefreshState)state{
    // 1.一样的就直接返回
    if (self.state == state) return;
    
    // 2.保存旧状态
    RefreshState oldState = self.state;
    
    // 3.调用父类方法
    [super setState:state];
    
    // 4.根据状态来设置属性
	switch (state){
		case RefreshStateNormal:{
            // 刷新完毕
            if (RefreshStateRefreshing == oldState) {
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                [UIView animateWithDuration:0.25 animations:^{
                    self.scrollView.scrollInsetBottom = self.scrollViewOriginalInset.bottom;
                }];
            } else {
                // 执行动画
                [UIView animateWithDuration:0.25 animations:^{
                    self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                }];
            }
            
            CGFloat deltaH = [self heightForContentBreakView];
            NSInteger currentCount = [self totalDataCountInScrollView];
            // 刚刷新完毕
            if (RefreshStateRefreshing == oldState && deltaH > 0 && currentCount != self.lastRefreshCount) {
                self.scrollView.scrollOffsetY = self.scrollView.scrollOffsetY;
            }
			break;
        }
            
		case RefreshStatePulling:{
            [UIView animateWithDuration:0.25 animations:^{
                self.arrowImage.transform = CGAffineTransformIdentity;
            }];
			break;
        }
            
        case RefreshStateRefreshing:{
            // 记录刷新前的数量
            self.lastRefreshCount = [self totalDataCountInScrollView];
            
            [UIView animateWithDuration:0.25 animations:^{
                CGFloat bottom = self.sizeHeight + self.scrollViewOriginalInset.bottom;
                CGFloat deltaH = [self heightForContentBreakView];
                if (deltaH < 0) {
                    // 如果内容高度小于view的高度
                    bottom -= deltaH;
                }
                self.scrollView.scrollInsetBottom = bottom;
            }];
			break;
        }
            
        default:
            break;
	}
}

- (NSInteger)totalDataCountInScrollView{
    NSInteger totalCount = 0;
    if ([self.scrollView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.scrollView;
        for (NSInteger section = 0; section < tableView.numberOfSections; section++) {
            totalCount += [tableView numberOfRowsInSection:section];
        }
    }
    return totalCount;
}

#pragma mark 获得scrollView的内容 超出 view 的高度
- (CGFloat)heightForContentBreakView{
    CGFloat h = self.scrollView.frame.size.height - self.scrollViewOriginalInset.bottom - self.scrollViewOriginalInset.top;
    return self.scrollView.contentSize.height - h;
}

#pragma mark - 在父类中用得上
/**
 *  刚好看到上拉刷新控件时的contentOffset.y
 */
- (CGFloat)happenOffsetY{
    CGFloat deltaH = [self heightForContentBreakView];
    if (deltaH > 0) {
        return deltaH - self.scrollViewOriginalInset.top;
    } else {
        return - self.scrollViewOriginalInset.top;
    }
}
@end