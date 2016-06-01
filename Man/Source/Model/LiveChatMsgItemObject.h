//
//  LiveChatMsgItemObject.h
//  dating
//
//  Created by test on 16/4/21.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  LiveChat消息item类

#import <Foundation/Foundation.h>
#include <livechatmanmanager/LCMessageItem.h>
#import "LiveChatTextItemObject.h"
#import "LiveChatWarningItemObject.h"
#import "LiveChatSystemItemObject.h"
#import "LiveChatCustomItemObject.h"

@interface LiveChatMsgItemObject : NSObject

/** 消息ID */
@property (nonatomic,assign) NSInteger msgId;
/** 消息发送方向 */
@property (nonatomic,assign) LCMessageItem::SendType sendType;
/** 消息发送方向 */
@property (nonatomic,strong) NSString *fromId;
/** 接收 */
@property (nonatomic,strong) NSString *toId;
/** 邀请ID */
@property (nonatomic,strong) NSString *inviteId;
/** 接收/发送时间 */
@property (nonatomic,assign) NSInteger createTime;
/** 处理状态 */
@property (nonatomic,assign) LCMessageItem::StatusType statusType;
/** 消息类型 */
@property (nonatomic,assign) LCMessageItem::MessageType msgType;
/** 文本消息 */
@property (nonatomic,strong) LiveChatTextItemObject* textMsg;
/** 警告消息 */
@property (nonatomic,strong) LiveChatWarningItemObject* warningMsg;
/** 系统消息 */
@property (nonatomic,strong) LiveChatSystemItemObject* systemMsg;
/** 自定义消息 **/
@property (nonatomic,strong) LiveChatCustomItemObject* customMsg;

/**
 *  初始化
 *
 *  @return this
 */
- (LiveChatMsgItemObject*)init;

@end
