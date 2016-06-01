//
//  UIScrollView+Ellipsis.m
//  Refresh
//
//  Created by lance  on 16-4-10.
//  Copyright (c) 2016年 qpidnetwork. All rights reserved.
//

#import "UIScrollView+Ellipsis.h"

@implementation UIScrollView (Ellipsis)

#pragma mark - contentInset

- (void)setScrollInsetTop:(CGFloat)scrollInsetTop{
    UIEdgeInsets contentInset = self.contentInset;
    contentInset.top = scrollInsetTop;
    self.contentInset = contentInset;
}


- (CGFloat)scrollInsetTop{
    return self.contentInset.top;
}

- (void)setScrollInsetBottom:(CGFloat)scrollInsetBottom{
    UIEdgeInsets contentInset = self.contentInset;
    contentInset.bottom = scrollInsetBottom;
    self.contentInset = contentInset;
}

- (CGFloat)scrollInsetBottom{
    return self.contentInset.bottom;
}

- (void)setScrollInsetLeft:(CGFloat)scrollInsetLeft{
    UIEdgeInsets contentInset = self.contentInset;
    contentInset.left = scrollInsetLeft;
    self.contentInset = contentInset;
}

- (CGFloat)scrollInsetLeft{
    return self.contentInset.left;
}

- (void)setScrollInsetRight:(CGFloat)scrollInsetRight{
    UIEdgeInsets contentInset = self.contentInset;
    contentInset.right = scrollInsetRight;
    self.contentInset = contentInset;
}

- (CGFloat)scrollInsetRight{
    return self.contentInset.right;
}


#pragma mark - offset
- (void)setScrollOffsetX:(CGFloat)scrollOffsetX{
    CGPoint offset = self.contentOffset;
    offset.x = scrollOffsetX;
    self.contentOffset = offset;
}

- (CGFloat)scrollOffsetX{
    return self.contentOffset.x;
}


- (void)setScrollOffsetY:(CGFloat)scrollOffsetY{
    CGPoint offset = self.contentOffset;
    offset.y = scrollOffsetY;
    self.contentOffset = offset;
}


- (CGFloat)scrollOffsetY{
    return self.contentOffset.y;
}

#pragma mark - contentSize
- (void)setScrollContentSizeWidth:(CGFloat)scrollContentSizeWidth{
    CGSize contentSize = self.contentSize;
    contentSize.width = scrollContentSizeWidth;
    self.contentSize = contentSize;
}

- (CGFloat)scrollContentSizeWidth{
    return self.contentSize.width;
}


- (void)setScrollContentSizeHeight:(CGFloat)scrollContentSizeHeight{
    CGSize contentSize = self.contentSize;
    contentSize.height = scrollContentSizeHeight;
    self.contentSize = contentSize;
}

- (CGFloat)scrollContentSizeHeight{
    return self.contentSize.height;
}
@end
