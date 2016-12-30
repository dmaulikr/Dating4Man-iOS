//
//  GIFImageView.h
//  dating
//
//  Created by Calvin on 16/12/9.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>

@class GIFImageViewDelegate;
@protocol GIFImageViewDelegate <NSObject>
- (void)gifWillPlay;
@end


@interface GIFImageView : UIImageView

@property (nonatomic, strong) NSString          *gifPath;
@property (nonatomic, strong) NSData            *gifData;
@property (nonatomic, weak) id<GIFImageViewDelegate> delegate;
- (void)startGIF;
- (void)stopGIF;
- (BOOL)isGIFPlaying;
//生成GIF
+ (NSString *)createGIFPath:(NSString *)path imageArray:(NSArray *)imgs;
@end
