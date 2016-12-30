//
//  ChatSmallGradeEmotion.h
//  dating
//
//  Created by test on 16/11/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveChatMagicIconItemObject.h"
#import "MagicIconItemObject.h"

@interface ChatSmallGradeEmotion : NSObject


/**
 图片
 */
@property (nonatomic, readonly) UIImage* image;


/** 基本内容 */
@property (nonatomic,strong) LiveChatMagicIconItemObject *liveChatMagicIconItemObject;
/** 基本属性 */
@property (nonatomic,strong) MagicIconItemObject *magicIconItemObject;

@end
