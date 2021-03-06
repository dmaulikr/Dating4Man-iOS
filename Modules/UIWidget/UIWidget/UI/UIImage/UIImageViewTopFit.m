//
//  UIImageViewTopFit.m
//  UIWidget
//
//  Created by Max on 16/6/23.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "UIImageViewTopFit.h"

@implementation UIImageViewTopFit

- (void)setImage:(UIImage *)image {
    UIImage *scaleImage = image;
    
    // 改变填充方式, 等比全显示
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    if( image != nil ) {
        // 计算高宽比
        float viewScaleSize = self.frame.size.height / self.frame.size.width;
        float imageScaleSize = image.size.height / image.size.width;
        
        if( image.size.height > image.size.width ) {
            // 高大于宽(纵向图片)
            if( viewScaleSize < imageScaleSize ) {
                // view的[高宽比]小于image[高宽比]
                CGRect clippedRect;
                // 裁剪图片
                if( image.imageOrientation == UIImageOrientationLeft || image.imageOrientation == UIImageOrientationRight ) {
                    clippedRect = CGRectMake(0, 0, image.size.width * viewScaleSize, image.size.width);
                } else {
                    clippedRect = CGRectMake(0, 0, image.size.width, image.size.width * viewScaleSize);
                }
                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
                scaleImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:image.imageOrientation];
                CGImageRelease(imageRef);
                
//                NSData* data = UIImagePNGRepresentation(image);
//                NSString* dir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//                NSString *path = [dir stringByAppendingPathComponent:@"image.jpg"];
//                [data writeToFile:path atomically:YES];
//                
//                NSData* data1 = UIImagePNGRepresentation(scaleImage);
//                NSString* dir1 = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//                NSString *path1 = [dir1 stringByAppendingPathComponent:@"scaleImage.jpg"];
//                [data1 writeToFile:path1 atomically:YES];
            } else {
                // view的[高宽比]大于image[高宽比]
                // 改变填充方式, 填满
                self.contentMode = UIViewContentModeScaleAspectFill;
            }
            
            // 缩放图片
//                UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.width * viewScaleSize));
//                CGContextRef currentContext = UIGraphicsGetCurrentContext();
//                CGRect clippedRect = CGRectMake(0, 0, image.size.width, image.size.height);
//                CGContextClipToRect(currentContext, clippedRect);
//                
//                [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.width * viewScaleSize)];
//                scaleImage = UIGraphicsGetImageFromCurrentImageContext();
//                UIGraphicsEndImageContext();
            
        } else {
            // 高小于宽(横向图片)
//            if( viewScaleSize <= imageScaleSize ) {
//                // view的[高宽比]小于image[高宽比]
//                // 改变填充方式, 等比全显示
//                
//            } else {
//                // view的[高宽比]大于image[高宽比]
//                // 裁剪图片
////                CGRect clippedRect = CGRectMake(0, 0, image.size.width, image.size.width * viewScaleSize);
////                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
////                scaleImage = [UIImage imageWithCGImage:imageRef];
////                CGImageRelease(imageRef);
//            }
        }
    }
    
    [super setImage:scaleImage];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
