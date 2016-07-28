//
//  FileCacheManager.m
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "FileCacheManager.h"

@interface FileCacheManager ()

/**
 *  获取Document目录
 *
 *  @return Document目录路径
 */
- (NSString*)documentsDirectory;

/**
 *  获取Cache目录
 *
 *  @return Cache目录路径
 */
- (NSString*)cacheDirectory;

/**
 *  图片缓存目录
 *
 *  @return 图片缓存目录路径
 */
- (NSString*)imageCacheDirectory;

/**
 *  创建目录
 *
 *  @param path 目录路径
 *
 *  @return 成功/失败
 */
- (BOOL)createDirectory:(NSString*)path;

/**
 *  删除目录
 *
 *  @param path 目录路径
 *
 *  @return 成功/失败
 */
- (BOOL)removeDirectory:(NSString*)path;

@end

static FileCacheManager* gManager = nil;
@implementation FileCacheManager
+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

#pragma mark - 接口日志目录
- (NSString *)requestLogPath {
    NSString* path = [[self cacheDirectory] stringByAppendingPathComponent:@"log/"];
    if( [self createDirectory:path] ) {
        return path;
    } else {
        return nil;
    }
}

#pragma mark - 崩溃日志目录
- (NSString*)crashLogPath {
    NSString* path = [[self cacheDirectory] stringByAppendingPathComponent:@"crash/"];
    if( [self createDirectory:path] ) {
        return path;
    } else {
        return nil;
    }
}

#pragma mark - 临时目录
- (NSString *)tmpPath {
    NSString* path = [[self cacheDirectory] stringByAppendingPathComponent:@"tmp/"];
    if( [self createDirectory:path] ) {
        return path;
    } else {
        return nil;
    }
}

#pragma mark - 图片缓存目录
- (NSString* )imageCachePathWithUrl:(NSString* )url {
    NSString* filePath = nil;
    
    if( url && url.length > 0 ) {
        NSString* fileName = [url toMD5String];
        filePath = [[self imageCacheDirectory] stringByAppendingPathComponent:fileName];
    }
    
    return filePath;
}

#pragma mark - 图片上传目录
- (NSString *)imageUploadCachePath:(UIImage *)tempImage uploadImageName:(NSString *)uploadImageName{
    NSData *imageData = nil;
    if ([uploadImageName isEqualToString:@"png"]) {
        imageData = UIImagePNGRepresentation(tempImage);
    }else{
        imageData = UIImageJPEGRepresentation(tempImage, 0);
    }
    NSString* path = [[self cacheDirectory] stringByAppendingPathComponent:@"uploadImage/"];
    if( [self createDirectory:path] ) {
        NSString *uploadPath = [path stringByAppendingPathComponent:uploadImageName];
        [imageData writeToFile:uploadPath atomically:YES];
        return uploadPath;
    } else {
        return nil;
    }
    
}


#pragma mark - 私有方法
- (NSString *)documentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (NSString *)cacheDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (NSString*)imageCacheDirectory {
    NSString* path = [[self cacheDirectory] stringByAppendingPathComponent:@"image/"];
    if( [self createDirectory:path] ) {
        return path;
    } else {
        return nil;
    }

}

- (BOOL)createDirectory:(NSString*)path {
    BOOL success = YES;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if( ![fileManager fileExistsAtPath:path] ) {
        success = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return success;
}

- (BOOL)removeDirectory:(NSString*)path {
    BOOL success = YES;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ( [fileManager fileExistsAtPath:path] ) {
        success = [fileManager removeItemAtPath:path error:nil];
    }
    return success;
}
@end
