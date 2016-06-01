//
//  UIView+Ellipsis.m
//  Refresh
//
//  Created by lance  on 16-4-10.
//  Copyright (c) 2016年 qpidnetwork. All rights reserved.
//

#import "UIView+Ellipsis.h"

@implementation UIView (Ellipsis)

- (void)setOriginX:(CGFloat)originX{
    CGRect frame = self.frame;
    frame.origin.x = originX;
    self.frame = frame;
}


- (CGFloat)originX{
    return self.frame.origin.x;
}


- (void)setOriginY:(CGFloat)originY{
    CGRect frame = self.frame;
    frame.origin.y = originY;
    self.frame = frame;
}


- (CGFloat)originY{
    return self.frame.origin.y;
}



- (void)setSizeWidth:(CGFloat)sizeWidth{
    CGRect frame = self.frame;
    frame.size.width = sizeWidth;
    self.frame = frame;
}

- (CGFloat)sizeWidth{
    return self.frame.size.width;
}


- (void)setSizeHeight:(CGFloat)sizeHeight{
    CGRect frame = self.frame;
    frame.size.height = sizeHeight;
    self.frame = frame;
}

- (CGFloat)sizeHeight{
    return self.frame.size.height;
}


- (void)setCenterX:(CGFloat)centerX{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY{
    return self.center.y;
}
@end
