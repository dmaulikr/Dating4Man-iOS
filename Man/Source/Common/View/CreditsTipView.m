//
//  CreditsTipView.m
//  dating
//
//  Created by lance on 16/3/9.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CreditsTipView.h"

@implementation CreditsTipView

//隐藏在指定位置，完成之执行某项操作
- (void)hideInPoint:(CGPoint)point completion:(void (^)())completionBlock{
    [UIView animateWithDuration:0.5 animations:^{
        self.center = point;
        //改变tranforms的大小形变
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        //移除
        [self removeFromSuperview];
        if (completionBlock) {
            completionBlock();
        }
    }];
    
}

//点击隐藏操作
- (IBAction)ClickToHide:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(popCreditsClickToHide:)]) {
        [self.delegate popCreditsClickToHide:self];
    }
    
}

//弹出提示图
+ (instancetype)popCredits{
    return [[NSBundle mainBundle] loadNibNamed:@"CreditsTipView" owner:self options:nil].firstObject;
    
}
//弹出显示的位置
+ (instancetype)showInPoint:(CGPoint)point{
    CreditsTipView *credits = [CreditsTipView popCredits];
    credits.center = point;
    [[UIApplication sharedApplication].keyWindow addSubview:credits];
    return credits;
    
}
@end
