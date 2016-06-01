//
//  UIImage+Circle.m
//  UIWidget
//  利用画板讲图片弄成圆形
//  Created by lance on 16/4/12.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "UIImage+Circle.h"

@implementation UIImage (Circle)

/**
 *  获取圆形的图片
 *
 *  
 */
- (instancetype)circleImage{
    //开始图形上下文
    UIGraphicsBeginImageContext(self.size);
    //获取原始内容
    CGContextRef ref = UIGraphicsGetCurrentContext();
    //获取大小
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    //根据范围进行
    CGContextAddEllipseInRect(ref, rect);
    //去除多余的部分
    CGContextClip(ref);
    //重新绘制
    [self drawInRect:rect];
    //获取重绘制之后的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //结束上下文
    UIGraphicsEndImageContext();
    
    return image;
    
    
}

+ (instancetype)circleImage:(NSString *)name{
    return [[self imageNamed:name] circleImage];
    
}


@end
