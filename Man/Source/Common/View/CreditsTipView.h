//
//  CreditsTipView.h
//  dating
//
//  Created by lance on 16/3/9.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//   弹出提示图
//

#import <UIKit/UIKit.h>
@class CreditsTipView;
@protocol creditsViewPopCreditsDelegate <NSObject>

- (void)popCreditsClickToHide:(CreditsTipView *)creditsTipView;

@end




@interface CreditsTipView : UIView

/** 代理 */
@property (nonatomic,weak) id<creditsViewPopCreditsDelegate> delegate;

//弹出提示图
+ (instancetype)popCredits;

//弹出显示的位置
+ (instancetype)showInPoint:(CGPoint)point;

//隐藏在指定位置，完成之执行某项操作
- (void)hideInPoint:(CGPoint)point completion:(void(^)())completionBlock;
                                               
@property (weak, nonatomic) IBOutlet UILabel *contentTips;
@property (weak, nonatomic) IBOutlet UILabel *tipsTitle;


@end
