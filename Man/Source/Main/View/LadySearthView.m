//
//  LadySearthView.m
//  dating
//
//  Created by Calvin on 16/12/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadySearthView.h"

#define AnimationTime 0.3
#define MinAgeRange 18
#define MaxAgeRange 100

@interface LadySearthView ()
{
    UIView * slideView;//性别滑动view
}
@end

@implementation LadySearthView

+ (instancetype)initLadySearthViewXib {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:@"LadySearthView" owner:nil options:nil];
    LadySearthView* view = [nibs objectAtIndex:0];
    [view setupAgeSlider];
    [view setSexView];
    [view showAnimation];
    
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSexView
{
    slideView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, self.sexBGView.frame.size.height)];
    slideView.backgroundColor = [UIColor whiteColor];
    [self.sexBGView addSubview:slideView];
    self.sexBGView.layer.cornerRadius = 19;
    self.sexBGView.layer.masksToBounds = YES;
    self.sexBGView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.sexBGView.layer.borderWidth = 2;

}
- (void)setupAgeSlider {
    // 设置年龄选择
    // 最大范围
    self.ageSlider.positionMaxValue = MaxAgeRange - MinAgeRange;
    //最小值
    self.ageSlider.minAgeRange = MinAgeRange;
    // 右边位置
    self.ageSlider.positionValue = MaxAgeRange - MinAgeRange - 45;
    
    // 背景填充
    self.ageSlider.trackBackgroundImage = [[UIImage alloc] createImageWithColor:[UIColor colorWithIntRGB:201 green:201 blue:201 alpha:255] imageRect:CGRectMake(0.0f, 0.0f, 1.0f, 3.0f)];
    self.ageSlider.trackFillImage = [[UIImage alloc]  createImageWithColor:[UIColor colorWithIntRGB:201 green:201 blue:201 alpha:255]  imageRect:CGRectMake(0.0f, 0.0f, 1.0f, 3.0f)];
    
    // 滑块图片
    UIImage *colorImage = [[UIImage alloc]  createImageWithColor:[UIColor colorWithIntRGB:201 green:201 blue:201 alpha:255] imageRect:CGRectMake(0.0f, 0.0f, 18.0f, 18.0f)];
    // 滑块高亮图片
    self.ageSlider.handleImage = [colorImage circleImage];
    
    [self.ageSlider addTarget:self action:@selector(updateSliderLabel) forControlEvents:UIControlEventValueChanged];
        
    self.minValue = MinAgeRange;
    self.maxValue = self.ageSlider.positionValue + MinAgeRange;
}

- (void)updateSliderLabel {
    // 设置年龄范围
    self.ageSlider.minValueLabel.text = [NSString stringWithFormat:@"%d",(int)self.ageSlider.leftValue + MinAgeRange];
    self.ageSlider.maxValueLabel.text = [NSString stringWithFormat:@"%d",(int)self.ageSlider.rightValue + MinAgeRange];
    
    self.minValue = self.ageSlider.leftValue + MinAgeRange;
    self.maxValue = self.ageSlider.rightValue + MinAgeRange;
}

//点击搜索按钮
- (IBAction)didSearthButton:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(searchFinish)]) {
        [self.delegate searchFinish];
    }
}

//在线开关
- (IBAction)onlineStatusChange:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setBackgroundImage:[UIImage imageNamed:@"LadyList-Searth-OnlineIocn"] forState:UIControlStateNormal];
        self.online = YES;
    }
    else
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"LadyList-Searth-OfflineIocn"] forState:UIControlStateNormal];
        self.online = NO;
    }
}

//性别切换器
- (IBAction)sexChoose:(id)sender {
    

    if (self.isMale) {
        self.isMale = NO;
        self.sexLabel.text = @"Female";
        self.sexLabel.textAlignment = NSTextAlignmentLeft;
        self.sexLabel.alpha = 0;
        self.femaleIcon.image = [UIImage imageNamed:@"LadyList-SearthFemaleIcon"];
        self.maleIcon.image = [UIImage imageNamed:@"LadyList-SearthMaleIcon-Black"];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = slideView.frame;
            rect.origin.x = 0;
            slideView.frame = rect;
            self.sexLabel.alpha = 1;
        }];
    }
    else
    {
        self.isMale = YES;
        self.sexLabel.text = @"Male";
        self.sexLabel.textAlignment = NSTextAlignmentRight;
        self.femaleIcon.image = [UIImage imageNamed:@"LadyList-SearthFemaleIcon-Black"];
        self.maleIcon.image = [UIImage imageNamed:@"LadyList-SearthMaleIcon"];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = slideView.frame;
            rect.origin.x = self.sexBGView.frame.size.width - rect.size.width;
            slideView.frame = rect;
        }];
    }
}

//点击搜索按钮
- (IBAction)didBGviewTap:(id)sender {
    [self hideAnimation];
}

//显示界面
- (void)showAnimation
{
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
   [UIView animateWithDuration:AnimationTime animations:^{
       self.searthView.alpha = 1;
       self.bgView.alpha = 0.8;
   }];
}

//隐藏界面
- (void)hideAnimation
{
    [UIView animateWithDuration:AnimationTime animations:^{
        self.bgView.alpha = 0;
        self.searthView.alpha = 0;
    }completion:^(BOOL finished) {
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.frame.size.width, self.frame.size.height);
    }];
}

@end
