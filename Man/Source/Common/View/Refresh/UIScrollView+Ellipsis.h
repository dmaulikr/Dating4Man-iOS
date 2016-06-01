//
//  UIScrollView+Ellipsis.h
//  Refresh
//
//  Created by lance  on 16-4-10.
//  Copyright (c) 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (Ellipsis)

#pragma mark - scrollContentInset
/** 额外头部 */
@property (nonatomic,assign) CGFloat scrollInsetTop;
/** 额外底部 */
@property (nonatomic,assign) CGFloat scrollInsetBottom;
/** 额外左 */
@property (nonatomic,assign) CGFloat scrollInsetLeft;
/** 额外右 */
@property (nonatomic,assign) CGFloat scrollInsetRight;

#pragma mark - 偏移量
/** 偏离X */
@property (nonatomic,assign) CGFloat scrollOffsetX;
/** 偏离Y */
@property (nonatomic,assign) CGFloat scrollOffsetY;


#pragma mark - 内容大小
/** 内容宽 */
@property (nonatomic,assign) CGFloat scrollContentSizeWidth;
/** 内容高 */
@property (nonatomic,assign) CGFloat scrollContentSizeHeight;

@end
