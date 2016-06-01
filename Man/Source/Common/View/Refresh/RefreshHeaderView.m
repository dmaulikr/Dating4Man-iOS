//
//  RefreshHeaderView.m
//  Refresh
//
//  Created by lance  on 16-4-10.
//  Copyright (c) 2016年 qpidnetwork. All rights reserved.
//  下拉刷新

#import "RefreshHeaderView.h"


@interface RefreshHeaderView()
// 最后的更新时间
@property (nonatomic, strong) NSDate *lastUpdateTime;
@property (nonatomic, weak) UILabel *lastUpdateTimeLabel;
@end

@implementation RefreshHeaderView


NSString *const RefreshHeaderPullToRefresh = @"下拉可以刷新";
NSString *const RefreshHeaderReleaseToRefresh = @"松开立即刷新";
NSString *const RefreshHeaderRefreshing = @"正在帮你刷新...";
#pragma mark - 控件初始化
/**
 *  时间标签
 */
- (UILabel *)lastUpdateTimeLabel{
    if (!_lastUpdateTimeLabel) {
        // 1.创建控件
        UILabel *lastUpdateTimeLabel = [[UILabel alloc] init];
        lastUpdateTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        lastUpdateTimeLabel.font = [UIFont boldSystemFontOfSize:12];
        lastUpdateTimeLabel.textColor = RefreshLabelTextColor;
        lastUpdateTimeLabel.backgroundColor = [UIColor clearColor];
        lastUpdateTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lastUpdateTimeLabel = lastUpdateTimeLabel];
        
        // 2.加载时间
        if(self.dateKey){
            self.lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:self.dateKey];
        } else {
            self.lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"RefreshHeaderView"];
        }
    }
    return _lastUpdateTimeLabel;
}

+ (instancetype)header{
    return [[RefreshHeaderView alloc] init];
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.pullToRefreshText = RefreshHeaderPullToRefresh;
        self.releaseToRefreshText = RefreshHeaderReleaseToRefresh;
        self.refreshingText = RefreshHeaderRefreshing;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat statusX = 0;
    CGFloat statusY = 0;
    CGFloat statusHeight = self.sizeHeight * 0.5;
    CGFloat statusWidth = self.sizeWidth;
    // 1.状态标签
    self.statusLabel.frame = CGRectMake(statusX, statusY, statusWidth, statusHeight);
    
    // 2.时间标签
    CGFloat lastUpdateY = statusHeight;
    CGFloat lastUpdateX = 0;
    CGFloat lastUpdateHeight = statusHeight;
    CGFloat lastUpdateWidth = statusWidth;
    self.lastUpdateTimeLabel.frame = CGRectMake(lastUpdateX, lastUpdateY, lastUpdateWidth, lastUpdateHeight);
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    // 设置自己的位置和尺寸
    self.originY = - self.sizeHeight;
}

#pragma mark - 状态相关
#pragma mark 设置最后的更新时间
- (void)setLastUpdateTime:(NSDate *)lastUpdateTime{
    _lastUpdateTime = lastUpdateTime;
    
    // 1.归档
    if(self.dateKey){
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime forKey:self.dateKey];
    }   else{
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime forKey:@"RefreshHeaderTimeKey"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 2.更新时间
    [self updateTimeLabel];
}

#pragma mark 更新时间字符串
- (void)updateTimeLabel{
    if (!self.lastUpdateTime) return;
    
    // 1.获得年月日
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:_lastUpdateTime];
    NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    // 2.格式化日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([cmp1 day] == [cmp2 day]) { // 今天
        formatter.dateFormat = @"今天 HH:mm";
    } else if ([cmp1 year] == [cmp2 year]) { // 今年
        formatter.dateFormat = @"MM-dd HH:mm";
    } else {
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    NSString *time = [formatter stringFromDate:self.lastUpdateTime];
    
    // 3.显示日期
    self.lastUpdateTimeLabel.text = [NSString stringWithFormat:@"最后更新：%@", time];
}

#pragma mark - 监听UIScrollView的contentOffset属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    // 不能跟用户交互就直接返回
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;

    // 如果正在刷新，直接返回
    if (self.state == RefreshStateRefreshing || self.endingRefresh) return;

    if ([@"contentOffset" isEqualToString:keyPath]) {
        [self adjustStateWithContentOffset];
    }
}

/**
 *  调整状态
 */
- (void)adjustStateWithContentOffset{
    
//    // 在刷新的refreshing状态
//    if (self.state == RefreshStateRefreshing) {
//        if (self.window == nil) return;
//        
//        // 停留解决
//        CGFloat insetT = - self.scrollView.scrollOffsetY > _scrollViewOriginalInset.top ? - self.scrollView.scrollOffsetY : _scrollViewOriginalInset.top;
//        insetT = insetT > self.sizeHeight + _scrollViewOriginalInset.top ? self.sizeHeight + _scrollViewOriginalInset.top : insetT;
//        self.scrollView.scrollInsetTop = insetT;
//        
//        self.insetTDelta = _scrollViewOriginalInset.top - insetT;
//        return;
//    }
//    
    
    // 当前的contentOffset
    CGFloat currentOffsetY = self.scrollView.scrollOffsetY;
    // 头部控件刚好出现的offsetY
    CGFloat happenOffsetY = - self.scrollViewOriginalInset.top;
    
    // 如果是向上滚动到看不见头部控件，直接返回
    if (currentOffsetY >= happenOffsetY) return;
    
    if (self.scrollView.isDragging) {
        // 普通 和 即将刷新 的临界点
        CGFloat normal2pullingOffsetY = happenOffsetY - self.sizeHeight;
        
        if (self.state == RefreshStateNormal && currentOffsetY < normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = RefreshStatePulling;
        } else if (self.state == RefreshStatePulling && currentOffsetY >= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = RefreshStateNormal;
        }
    } else if (self.state == RefreshStatePulling) {
        // 即将刷新 && 手松开
        // 开始刷新
        self.state = RefreshStateRefreshing;
    }
}

#pragma mark 设置状态
- (void)setState:(RefreshState)state{
    // 1.一样的就直接返回
    if (self.state == state) return;
    
    // 2.保存旧状态
    RefreshState oldState = self.state;
    
    // 3.调用父类方法
    [super setState:state];
    
    // 4.根据状态执行不同的操作
	switch (state) {
		case RefreshStateNormal:{
          // 下拉可以刷新
            // 刷新完毕
            if (RefreshStateRefreshing == oldState) {
                self.arrowImage.transform = CGAffineTransformIdentity;
                // 保存刷新时间
                self.lastUpdateTime = [NSDate date];
                
                [UIView animateWithDuration:0.4 animations:^{
                    if (self.scrollViewOriginalInset.top == 0) {
                        self.scrollView.scrollInsetTop = 0;
                    } else if (self.scrollViewOriginalInset.top == self.scrollView.scrollInsetTop) {
                        self.scrollView.scrollInsetTop -= self.sizeHeight;
                    } else {
                        self.scrollView.scrollInsetTop = self.scrollViewOriginalInset.top;
                    }
                }];
            } else {
                // 执行动画
                [UIView animateWithDuration:0.25 animations:^{
                    self.arrowImage.transform = CGAffineTransformIdentity;
                }];
            }
			break;
        }
            
		case RefreshStatePulling:{
            // 松开可立即刷新
            // 执行动画
            [UIView animateWithDuration:0.25 animations:^{
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
            }];
			break;
        }
            
		case RefreshStateRefreshing:{
            // 正在刷新中
            // 执行动画
            [UIView animateWithDuration:0.25 animations:^{
                // 1.增加滚动区域
                CGFloat top = self.scrollViewOriginalInset.top + self.sizeHeight;
                self.scrollView.scrollInsetTop = top;
                
                // 2.设置滚动位置
                self.scrollView.scrollOffsetY = - top;
            }];
			break;
        }
            
        default:
            break;
	}
}
@end