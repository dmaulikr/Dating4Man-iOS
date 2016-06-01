//
//  CoverView.h
//
//
//  Created by lance37 on 16/3/8.
//  蒙版
//

#import "CoverView.h"

@interface CoverView()


@end

@implementation CoverView

//创建蒙版的图
+ (void)coverShow{
    CoverView *cover = [[CoverView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    cover.alpha = 0.6;
    
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
