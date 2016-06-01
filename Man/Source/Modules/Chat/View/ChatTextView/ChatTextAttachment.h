//
//  ChatTextAttachment.h
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatEmotion.h"

@interface ChatTextAttachment : NSTextAttachment
@property (nonatomic, retain) NSString* text;
@property (nonatomic, retain) NSURL *url;
@end
