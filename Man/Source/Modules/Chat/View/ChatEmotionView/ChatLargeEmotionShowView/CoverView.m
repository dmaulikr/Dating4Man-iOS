//
//  CoverView.m
//  dating
//
//  Created by test on 16/9/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CoverView.h"

@implementation CoverView


//创建蒙版的图
+ (void)coverShow{
    CoverView *cover = [[CoverView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    cover.alpha = 0.0f;
    
    cover.backgroundColor = [UIColor grayColor];
    
    
    [[UIApplication sharedApplication].keyWindow addSubview:cover];
    
}

+ (void)coverShowAlpha:(CGFloat)alpha color:(UIColor *)color{
    CoverView *cover = [[CoverView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    cover.alpha = alpha;
    cover.backgroundColor = color;
    
    [[UIApplication sharedApplication].keyWindow addSubview:cover];
}



//蒙版隐藏
+ (void)coverHide{
    //遍历主窗口的视图，如果当前有蒙版执行移除
    for (UIView * cover in [UIApplication sharedApplication].keyWindow.subviews) {
        if ([cover isKindOfClass:self]) {
            [cover removeFromSuperview];
        }
    }
}

@end
