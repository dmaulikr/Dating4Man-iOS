//
//  RefreshBaseView.m
//  Refresh刷新的基类,用于刷新
//
//  Created by lance  on 16-4-10.
//  Copyright (c) 2016年 qpidnetwork. All rights reserved.

#import "RefreshBaseView.h"
#import <objc/message.h>



@interface  RefreshBaseView()
{
    __weak UILabel *_statusLabel;
    __weak UIImageView *_arrowImage;
    __weak UIActivityIndicatorView *_activityView;
    BOOL _endingRefresh;
}
@end

@implementation RefreshBaseView
#pragma mark - 控件初始化
/**
 *  状态标签
 */
- (UILabel *)statusLabel{
    if (!_statusLabel) {
        UILabel *statusLabel = [[UILabel alloc] init];
        statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        statusLabel.font = [UIFont boldSystemFontOfSize:13];
        statusLabel.textColor = RefreshLabelTextColor;
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_statusLabel = statusLabel];
    }
    return _statusLabel;
}

/**
 *  箭头图片
 */
- (UIImageView *)arrowImage{
    if (!_arrowImage) {
        UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RefreshSrcName(@"arrow.png")]];
        arrowImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_arrowImage = arrowImage];
    }
    return _arrowImage;
}

/**
 *  状态标签
 */
- (UIActivityIndicatorView *)activityView{
    if (!_activityView) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.bounds = self.arrowImage.bounds;
        activityView.autoresizingMask = self.arrowImage.autoresizingMask;
        [self addSubview:_activityView = activityView];
    }
    return _activityView;
}

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.height = 64.0;
    if (self = [super initWithFrame:frame]) {
        // 1.自己的属性
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        // 2.设置默认状态
        self.state = RefreshStateNormal;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    // 1.箭头
    CGFloat arrowX = self.sizeWidth * 0.5 - 100;
    self.arrowImage.center = CGPointMake(arrowX, self.sizeHeight * 0.5);
    
    // 2.指示器
    self.activityView.center = self.arrowImage.center;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    // 旧的父控件
    [self.superview removeObserver:self forKeyPath:@"contentOffset" context:nil];
    
    if (newSuperview) { // 新的父控件
        [newSuperview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        
        // 设置宽度
        self.sizeWidth = newSuperview.sizeWidth;
        // 设置位置
        self.originX = 0;
        
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;
        // 设置永远支持垂直弹簧效果
        _scrollView.alwaysBounceVertical = YES;
        // 记录UIScrollView最开始的contentInset
        _scrollViewOriginalInset = _scrollView.contentInset;
    }
}

#pragma mark - 显示到屏幕上
- (void)drawRect:(CGRect)rect{
    if (self.state == RefreshStateWillRefreshing) {
        self.state = RefreshStateRefreshing;
    }
}

#pragma mark - 刷新相关
#pragma mark 是否正在刷新
- (BOOL)isRefreshing{
    return RefreshStateRefreshing == self.state;
}

#pragma mark 开始刷新
- (void)beginRefreshing{
    if (self.state == RefreshStateRefreshing) {
        // 回调
        if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
            msgSend(msgTarget(self.beginRefreshingTaget), self.beginRefreshingAction, self);
        }
        
        if (self.beginRefreshingCallback) {
            self.beginRefreshingCallback();
        }
    } else {
        if (self.window) {
            self.state = RefreshStateRefreshing;
        } else {

            _state = RefreshStateWillRefreshing;
    //保证在viewWillAppear等方法中也能刷新
            [self setNeedsDisplay];
        }
    }
}

#pragma mark 结束刷新
- (void)endRefreshing{
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.state = RefreshStateNormal;
    });
}

#pragma mark - 设置状态
- (void)setPullToRefreshText:(NSString *)pullToRefreshText{
    _pullToRefreshText = [pullToRefreshText copy];
    [self settingLabelText];
}
- (void)setReleaseToRefreshText:(NSString *)releaseToRefreshText{
    _releaseToRefreshText = [releaseToRefreshText copy];
    [self settingLabelText];
}
- (void)setRefreshingText:(NSString *)refreshingText{
    _refreshingText = [refreshingText copy];
    [self settingLabelText];
}



- (void)settingLabelText{
	switch (self.state) {
		case RefreshStateNormal:
            // 设置文字
            self.statusLabel.text = self.pullToRefreshText;
			break;
		case RefreshStatePulling:
            // 设置文字
            self.statusLabel.text = self.releaseToRefreshText;
			break;
        case RefreshStateRefreshing:
            // 设置文字
            self.statusLabel.text = self.refreshingText;
			break;
        default:
            break;
	}
}

- (void)setState:(RefreshState)state{
    // 0.存储当前的contentInset
    if (self.state != RefreshStateRefreshing) {
        _scrollViewOriginalInset = self.scrollView.contentInset;
    }
    
    // 1.一样的就直接返回(暂时不返回)
    if (self.state == state) return;
    
    // 2.旧状态
    RefreshState oldState = self.state;
    
    // 3.存储状态
    _state = state;
    
    // 4.根据状态执行不同的操作
    switch (state) {
		case RefreshStateNormal: // 普通状态
        {
            if (oldState == RefreshStateRefreshing) {
                // 正在结束刷新
                _endingRefresh = YES;
                
                [UIView animateWithDuration:0.4 * 0.6 animations:^{
                    self.activityView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    // 停止转圈圈
                    [self.activityView stopAnimating];
                    
                    // 恢复alpha
                    self.activityView.alpha = 1.0;
                }];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 等头部回去
                    // 显示箭头
                    self.arrowImage.hidden = NO;
                    
                    // 停止转圈圈
                    [self.activityView stopAnimating];
                    
                    // 设置文字
                    [self settingLabelText];
                    
                    // 结束刷新完毕
                    _endingRefresh = NO;
                });
                // 直接返回
                return;
            } else {
                // 显示箭头
                self.arrowImage.hidden = NO;
                
                // 停止转圈圈
                [self.activityView stopAnimating];
            }
			break;
        }
            
        case RefreshStatePulling:
            break;
            
		case RefreshStateRefreshing:
        {
            // 开始转圈圈
			[self.activityView startAnimating];
            // 隐藏箭头
			self.arrowImage.hidden = YES;
            
            // 回调
            if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
                msgSend(msgTarget(self.beginRefreshingTaget), self.beginRefreshingAction, self);
            }
            
            if (self.beginRefreshingCallback) {
                self.beginRefreshingCallback();
            }
			break;
        }
        default:
            break;
	}
    
    // 5.设置文字
    [self settingLabelText];
}
@end