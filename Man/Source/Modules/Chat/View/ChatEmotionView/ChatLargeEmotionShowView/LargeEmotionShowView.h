//
//  LargeEmotionShowView.h
//  dating
//
//  Created by test on 16/9/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LargeEmotionShowView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIView *loadingImageView;
/**
 停止时候图片
 */
@property (strong, atomic) UIImage* defaultImage;

/**
 播放图片数组
 */
@property (strong, atomic) NSArray<UIImage *>* animationArray;

/**
 *  创建
 *
 *  @return 创建图
 */
+ (instancetype)largeEmotionShowView;


/**
 重置
 */
- (void)reset;

/**
 重新开始播放
 */
- (void)play;

/**
 停止播放
 */
- (void)stop;
@end
