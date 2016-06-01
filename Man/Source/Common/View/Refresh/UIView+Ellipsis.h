//
//  UIView+Ellipsis.h
//  Refresh
//
//  Created by lance  on 16-4-10.
//  Copyright (c) 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Ellipsis)

/** 省略x */
@property (nonatomic,assign) CGFloat originX;
/** 省略y */
@property (nonatomic,assign) CGFloat originY;
/** 省略w */
@property (nonatomic,assign) CGFloat sizeWidth;
/** 省略h */
@property (nonatomic,assign) CGFloat sizeHeight;
/** 中心点x */
@property (nonatomic,assign) CGFloat centerX;
/** 中心点Y */
@property (nonatomic,assign) CGFloat centerY;


@end
