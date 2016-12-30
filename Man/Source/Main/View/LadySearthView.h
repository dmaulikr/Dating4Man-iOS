//
//  LadySearthView.h
//  dating
//
//  Created by Calvin on 16/12/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgeRangeSlider.h"

@class LadySearthView;
@protocol LadySearthViewDelegate <NSObject>

- (void)searchFinish;
@end

@interface LadySearthView : UIView

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *searthView;
@property (weak, nonatomic) IBOutlet UIImageView *sexBGView;
@property (weak, nonatomic) id <LadySearthViewDelegate> delegate;
/**
 *  性别选择器
 */
@property (weak, nonatomic) IBOutlet UIImageView *femaleIcon;
@property (weak, nonatomic) IBOutlet UIImageView *maleIcon;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;

/**
 *  年龄选择器
 */
@property (weak, nonatomic) IBOutlet AgeRangeSlider *ageSlider;
@property (nonatomic, assign) int  minValue;
@property (nonatomic, assign) int  maxValue;
/**
 *  在线状态选择器
 */
@property (weak, nonatomic) IBOutlet UIButton *onlineButton;

/**
 *  是否在线
 */
@property (nonatomic, assign) BOOL online;
/**
 *  是否男性
 */
@property (nonatomic, assign) BOOL isMale;
+ (instancetype)initLadySearthViewXib;
- (void)showAnimation;
- (void)hideAnimation;
@end
