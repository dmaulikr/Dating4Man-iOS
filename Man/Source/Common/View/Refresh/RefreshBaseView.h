//
//  RefreshBaseView.h
//  Refresh刷新的基类,用于刷新
//  
//  Created by lance  on 16-4-10.
//  Copyright (c) 2016年 qpidnetwork. All rights reserved.

#import <UIKit/UIKit.h>

@class RefreshBaseView;

#pragma mark - 控件的刷新状态
typedef enum {
	RefreshStatePulling = 1, // 松开就可以进行刷新的状态
	RefreshStateNormal = 2, // 普通状态
	RefreshStateRefreshing = 3, // 正在刷新中的状态
    RefreshStateWillRefreshing = 4,//即将刷新
} RefreshState;

#pragma mark - 控件的类型
typedef enum {
    RefreshViewTypeHeader = -1, // 头部控件
    RefreshViewTypeFooter = 1 // 尾部控件
} RefreshViewType;

/**
 类的声明
 */
@interface RefreshBaseView : UIView{
    UIEdgeInsets _scrollViewOriginalInset;
}
#pragma mark - 父控件
@property (nonatomic, weak, readonly) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) UIEdgeInsets scrollViewOriginalInset;

#pragma mark - 内部的控件
@property (nonatomic, weak, readonly) UILabel *statusLabel;
@property (nonatomic, weak, readonly) UIImageView *arrowImage;
@property (nonatomic, weak, readonly) UIActivityIndicatorView *activityView;

#pragma mark - 回调
/**
 *  开始进入刷新状态的监听器
 */
@property (nonatomic,weak) id beginRefreshingTaget;
/**
 *  开始进入刷新状态的监听方法
 */
@property (nonatomic,assign) SEL beginRefreshingAction;
/**
 *  开始进入刷新状态就会调用
 */
@property (nonatomic, copy) void (^beginRefreshingCallback)();

#pragma mark - 刷新相关
/**
 *  是否正在刷新
 */
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
/**
 *  开始刷新
 */
- (void)beginRefreshing;
/**
 *  结束刷新
 */
- (void)endRefreshing;

#pragma mark - 交给子类去实现 和 调用
@property (nonatomic,assign) RefreshState state;
/** 处于刷新结束的状态 */
@property (readonly, getter=isEndingRefresh) BOOL endingRefresh;

/**
 *  文字
 */
@property (nonatomic,copy) NSString *pullToRefreshText;
@property (nonatomic,copy) NSString *releaseToRefreshText;
@property (nonatomic,copy) NSString *refreshingText;


@end