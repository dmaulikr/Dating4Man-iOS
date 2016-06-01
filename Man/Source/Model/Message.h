//
//  Message.h
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (nonatomic, assign) NSInteger msgId;
@property (nonatomic, strong) NSAttributedString* attText;
@property (nonatomic, strong) NSString* text;

typedef enum {
    MessageSenderUnknow = 0,
    MessageSenderLady,
    MessageSenderSelf,
} Sender;
@property (nonatomic, assign) Sender sender;

typedef enum {
    MessageTypeUnknow = 0,
    MessageTypeSystemTips,
    MessageTypeWarningTips,
    MessageTypeText,
    MessageTypePhoto,
    MessageTypeCoupon,
} Type;
@property (nonatomic, assign) Type type;

typedef enum {
    MessageStatusUnknow = 0,
    MessageStatusProcessing,
    MessageStatusFinish,
    MessageStatusFail,
} Status;
@property (nonatomic, assign) Status status;

@end
