//
//  CoverView.h
//  dating
//
//  Created by test on 16/9/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoverView : UIView

/** 透明度 */
@property (nonatomic,assign) CGFloat alpha;



//显示
+ (void)coverShow;
//隐藏
+ (void)coverHide;
+ (void)coverShowAlpha:(CGFloat)alpha color:(UIColor *)color;

@end
