//
//  FileCacheManager.h
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCacheManager : NSObject

+ (instancetype)manager;

/**
 *  接口日志目录
 *
 *  @return 接口日志目录
 */
- (NSString *)requestLogPath;

/**
 *  崩溃日志目录
 *
 *  @return 崩溃日志目录
 */
- (NSString *)crashLogPath;

/**
 *  图片缓存目录
 *
 *  @param url 图片URL
 *
 *  @return 图片缓存目录
 */
- (NSString *)imageCachePathWithUrl:(NSString* )url;



/*
 *  图片上传目录
 *
 *  @param tempImage 图片
 *  @param uploadImageName 图片文件保存文字
 */
- (NSString *)imageUploadCachePath:(UIImage *)tempImage uploadImageName:(NSString *)uploadImageName;

@end
