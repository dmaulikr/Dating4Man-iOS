//
//  ChatTextView.h
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatEmotion.h"
#import "ChatTextAttachment.h"

@interface ChatTextView : UITextView

/**
 *   生成富文本,用以显示表情
 *
 *  @param emotion 表情模型
 */
- (void)insertEmotion:(ChatEmotion *)emotion;

@end
