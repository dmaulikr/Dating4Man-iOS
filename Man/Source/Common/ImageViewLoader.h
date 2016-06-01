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

@interface ImageViewLoader : NSObject

@property (nonatomic, retain) AFHTTPSessionManager *manager;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* path;
@property (nonatomic, retain) UIImage* imageDefaul;
@property (nonatomic, retain) UIView *view;
@property (nonatomic, assign) BOOL animated;

/**
 *  重置
 */
- (void)reset;

/**
 *  加载图片
 *
 *  @return 成功/失败
 */
- (BOOL)loadImage;

@end
