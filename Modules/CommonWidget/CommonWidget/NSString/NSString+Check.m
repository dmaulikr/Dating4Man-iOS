//
//  NSStringCheck.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//
#import "NSString+Check.h"

@implementation NSString (Check)
- (BOOL)isEmotion {
    if ( self.length == 0 ) {
        return NO;
    }
    
    const unichar hs = [self characterAtIndex:0];
    if (0xd800 <= hs && hs <= 0xdbff) {
        if (self.length > 1) {
            const unichar ls = [self characterAtIndex:1];
            const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
            if (0x1d000 <= uc && uc <= 0x1f77f) {
                return YES;
            }
        }
    } else if (self.length > 1) {
        const unichar ls = [self characterAtIndex:1];
        if (ls == 0x20e3) {
            return YES;
        }
    } else {
        if (0x2100 <= hs && hs <= 0x27ff) {
            return YES;
        } else if (0x2B05 <= hs && hs <= 0x2b07) {
            return YES;
        } else if (0x2934 <= hs && hs <= 0x2935) {
            return YES;
        } else if (0x3297 <= hs && hs <= 0x3299) {
            return YES;
        } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
            return YES;
        }
    }
    
    return NO;
}
@end
