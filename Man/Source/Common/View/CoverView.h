//
//  coverView.h
//
//
//  Created by lance37 on 16/3/8.
//  蒙版
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
