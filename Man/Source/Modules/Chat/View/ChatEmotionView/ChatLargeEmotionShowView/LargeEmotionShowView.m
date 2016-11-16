//
//  LargeEmotionShowView.m
//  dating
//
//  Created by test on 16/9/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LargeEmotionShowView.h"

@interface LargeEmotionShowView()

@end

@implementation LargeEmotionShowView
+ (instancetype)largeEmotionShowView {
    LargeEmotionShowView *largeEmotionshowView = [[NSBundle mainBundle] loadNibNamed:@"LargeEmotionShowView" owner:self options:nil].firstObject;
    largeEmotionshowView.animationArray = nil;
    return largeEmotionshowView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)reset {
    self.defaultImage = [UIImage imageNamed:@"Chat-LargeEmotionDefault"];
    [self stop];
}

- (void)play {
    [self.imageView setImage:self.defaultImage];
    
    if (self.animationArray.count > 0 ) {
        self.loadingImageView.hidden = YES;
        
        UIImage* image = [self.animationArray objectAtIndex:0];
        [self.imageView setImage:image];
        self.imageView.animationImages = self.animationArray;
        self.imageView.animationDuration = 1.0f * self.animationArray.count / 6;
        self.imageView.animationRepeatCount = 0;
        
        if( ![self.imageView isAnimating] ) {
            [self.imageView startAnimating];
        }
        
    } else {
        self.imageView.animationImages = nil;
        [self stop];
        
        self.loadingImageView.hidden = NO;
        [self.activityView startAnimating];
    }
}

- (void)stop {
    [self.imageView stopAnimating];
    [self.imageView setImage:self.defaultImage];
}

@end
