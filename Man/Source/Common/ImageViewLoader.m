//
//  ImageViewLoader.m
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ImageViewLoader.h"

@interface ImageViewLoader ()

@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain) UIActivityIndicatorView* loadingView;
@property (nonatomic, retain) NSURLSessionDownloadTask* downloadTask;
/**
 *  显示图片
 *
 *  @return 成功/失败
 */
- (BOOL)displayImage;

@end

@implementation ImageViewLoader
- (id)init {
    if( self = [super init] ) {
        self.manager = [[AFHTTPSessionManager manager] initWithBaseURL:nil];
        self.downloadTask = nil;
    }
    return self;
}

- (void)reset {
    self.image = nil;
    self.url = nil;
    self.path = nil;
    self.imageDefaul = nil;
    self.view = nil;
}

- (BOOL)loadImage {
    if( self.image ) {
        // 直接显示图片
        return [self displayImage];
        
    } else if( self.path && self.path.length > 0 ) {
        // 尝试加在缓存图片
        self.image = [UIImage imageWithContentsOfFile:self.path];
        if( self.image ) {
            // 直接显示图片
            return [self displayImage];
            
        } else if( self.url && self.url.length > 0 ) {
            // 下载图片
            if( self.downloadTask ) {
                [self.downloadTask cancel];
            }
            
            NSURL* url = [NSURL URLWithString:self.url];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
            
            if( AppDelegate().demo ) {
                NSString *authString = [[[NSString stringWithFormat:@"%@:%@", @"test", @"5179"] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                authString = [NSString stringWithFormat: @"Basic %@", authString];
                [request setValue:authString forHTTPHeaderField:@"Authorization"];
            }

            self.downloadTask = [self.manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
           
//                NSLog(@"downloadProgress------%@",downloadProgress);
                
                
            } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                NSURL* documentsDirectoryURL = [NSURL fileURLWithPath:self.path];
                return documentsDirectoryURL;
                
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                NSLog(@"ImageViewLoader::loadImage( completionHandler[ response : %@ ] )", response);
                NSLog(@"ImageViewLoader::loadImage( completionHandler[ filePath : %@ ] )", filePath);
                NSLog(@"ImageViewLoader::loadImage( completionHandler[ error : %@ ] )", error);
                
                if( [response isKindOfClass:[NSHTTPURLResponse class]] ) {
                    if( error == nil && ((NSHTTPURLResponse* )response).statusCode == 200 ) {
                        // 显示图片
                        self.image = [UIImage imageWithContentsOfFile:self.path];
                        [self displayImage];
                    }
                }
                
            }];
            
            // 开始下载
            [self.downloadTask resume];
            
        } else {
            // 无url失败
            return NO;
            
        }
        
    } else {
        // 又无图片又无缓存路径失败
        return NO;
    }
    
    return YES;
}

- (BOOL)displayImage {
    if( self.view && [self.view respondsToSelector:@selector(setImage:)] ) {
        // 图片非空才回调
        if( self.image != nil ) {
            [self.view performSelectorOnMainThread:@selector(setImage:) withObject:self.image waitUntilDone:NO];
        }
        
    } else {
        return NO;
        
    }
    
    return YES;
}

@end
