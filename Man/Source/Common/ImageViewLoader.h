//
//  ImageViewLoader.h
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@class ImageViewLoader;
@protocol ImageViewLoaderDelegate <NSObject>
@optional
- (void)loadImageFinish:(ImageViewLoader *)imageViewLoader success:(BOOL)success;
@end

@interface ImageViewLoader : NSObject

@property (nonatomic, retain) AFHTTPSessionManager *manager;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* path;
@property (nonatomic, weak) UIView *view;
@property (nonatomic, assign) BOOL animated;
@property (weak) id<ImageViewLoaderDelegate> delegate;

/**
 *  创建实例
 *
 *  @return 实例
 */
+ (instancetype)loader;

/**
 *  停止请求
 */
- (void)stop;

/**
 *  加载图片
 *
 *  @return 成功/失败
 */
- (BOOL)loadImage;

@end
