//
//  ChatSmallGradeEmotion.m
//  dating
//
//  Created by test on 16/11/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatSmallGradeEmotion.h"

@implementation ChatSmallGradeEmotion

- (UIImage *)image {
    UIImage* image = nil;
    
    NSData *data = [NSData dataWithContentsOfFile:self.liveChatMagicIconItemObject.thumbPath];
    image = [UIImage imageWithData:data];
    
    return image;
}
@end
