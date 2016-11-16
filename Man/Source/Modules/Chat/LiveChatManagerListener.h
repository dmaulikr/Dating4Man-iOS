//
//  LiveChatManagerListener.h
//  dating
//
//  Created by  Samson on 5/16/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <livechatmanmanager/ILiveChatManManager.h>
#import "LiveChatUserItemObject.h"
#import "LiveChatMsgItemObject.h"
#import "LiveChatUserInfoItemObject.h"
#import "LiveChatMsgPhotoItem.h"
#import "LiveChatEmotionItemObject.h"
#import "LiveChatEmotionConfigItemObject.h"
#import "LiveChatMagicIconItemObject.h"
#import "LiveChatMagicIconConfigItemObject.h"

@protocol LiveChatManagerDelegate <NSObject>
@optional

#pragma mark - 登录/注销回调
/**
 *  登录回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param isAutoLogin 是否将自动登录
 */
- (void)OnLogin:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg isAutoLogin:(BOOL)isAutoLogin;

/**
 *  注销回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param isAutoLogin 是否将自动登录
 */
- (void)OnLogout:(LCC_ERR_TYPE)errType errmsg:(NSString* _Nonnull)errmsg isAutoLogin:(BOOL)isAutoLogin;

#pragma mark - 在线状态回调
/**
 *  接收被踢下线通知回调
 *
 *  @param kickType 被踢下线类型
 */
- (void)onRecvKickOffline:(KICK_OFFLINE_TYPE)kickType;

/**
 *  在线状态改变通知回调
 *
 *  @param user 用户
 */
- (void)onChangeOnlineStatus:(LiveChatUserItemObject* _Nonnull)user;

/**
 *  获取指定用户在线状态回调
 *
 *  @param errType  结果类型
 *  @param errMsg   结果描述
 *  @param userList 用户list
 */
- (void)onGetUserStatus:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg users:(NSArray<LiveChatUserItemObject*>* _Nonnull)users;

#pragma mark - 获取用户信息
/**
 *  获取用户信息回调
 *
 *  @param errType  结果类型
 *  @param errMsg   结果描述
 *  @param userId   用户ID
 *  @param userInfo 用户信息
 */
- (void)onGetUserInfo:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId userInfo:(LiveChatUserInfoItemObject* _Nullable)userInfo;

/**
 *  获取多个用户信息回调
 *
 *  @param errType  结果类型
 *  @param errMsg   结果描述
 *  @param userList 用户信息数组
 */
- (void)onGetUsersInfo:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg usersInfo:(NSArray<LiveChatUserItemObject*>* _Nonnull)usersInfo;

#pragma mark - 聊天状态回调
/**
 *  获取在聊列表回调
 *
 *  @param errType 结果类型
 *  @param errMsg  结果描述
 */
- (void)onGetTalkList:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg;

/**
 *  接收聊天状态改变通知回调
 *
 *  @param user 用户
 */
- (void)onRecvTalkEvent:(LiveChatUserItemObject* _Nonnull)user;

#pragma mark - notice
/**
 *  接收Admirer/EMF通知回调
 *
 *  @param userId     用户ID
 *  @param noticeType 通知类型
 */
- (void)onRecvEMFNotice:(NSString* _Nonnull)userId noticeType:(TALK_EMF_NOTICE_TYPE)noticeType;

#pragma mark - 试聊券回调
/**
 *  检测是否可使用试聊券回调
 *
 *  @param success 检测操作成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param userId  用户ID
 *  @param status  检测结果
 */
- (void)onCheckTryTicket:(BOOL)success errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId status:(CouponStatus)status;

/**
 *  使用试聊券回调
 *
 *  @param errType   结果类型
 *  @param errMsg    结果描述
 *  @param userId    用户ID
 *  @param tickEvent 试聊事件
 */
- (void)onUseTryTicket:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId tickEvent:(TRY_TICKET_EVENT)tickEvent;

/**
 *  开始试聊回调
 *
 *  @param user 用户
 *  @param time 试聊时长（秒）
 */
- (void)onRecvTryTalkBegin:(LiveChatUserItemObject* _Nullable)user time:(NSInteger)time;

/**
 *  结束试聊回调
 *
 *  @param user 用户
 */
- (void)onRecvTryTalkEnd:(LiveChatUserItemObject* _Nullable)user;

#pragma mark - 普通消息处理回调（包括文本/系统/警告消息）
/**
 *  发送文本消息回调
 *
 *  @param errType 结果类型
 *  @param errMsg  结果描述
 *  @param msg 消息
 */
- (void)onSendTextMsg:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg msgItem:(LiveChatMsgItemObject* _Nullable)msg;

/**
 *  发送消息失败回调（多条）
 *
 *  @param errType 结果类型
 *  @param msgs    消息数组
 */
- (void)onSendTextMsgsFail:(LCC_ERR_TYPE)errType msgs:(NSArray<LiveChatMsgItemObject*>* _Nonnull)msgs;

/**
 *  接收文本消息回调
 *
 *  @param msg 消息
 */
- (void)onRecvTextMsg:(LiveChatMsgItemObject* _Nonnull)msg;

/**
 *  接收系统消息回调
 *
 *  @param msg 消息
 */
- (void)onRecvSystemMsg:(LiveChatMsgItemObject* _Nonnull)msg;

/**
 *  接收警告消息回调
 *
 *  @param msg 消息
 */
- (void)onRecvWarningMsg:(LiveChatMsgItemObject* _Nonnull)msg;

/**
 *  对方编辑消息回调
 *
 *  @param userId 用户ID
 */
- (void)onRecvEditMsg:(NSString* _Nonnull)userId;

/**
 *  获取单个用户历史聊天记录回调（包括文本、高级表情、语音、图片）
 *
 *  @param success 操作是否成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param userId  用户ID
 */
- (void)onGetHistoryMessage:(BOOL)success errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId;

/**
 *  获取多个用户历史聊天记录回调（包括文本、高级表情、语音、图片）
 *
 *  @param success  操作是否成功
 *  @param errNo    结果类型
 *  @param errMsg   结果描述
 *  @param userList 用户数组
 */
- (void)onGetUsersHistoryMessage:(BOOL)success errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg userIds:(NSArray<NSString*>* _Nonnull)userIds;


/**
 *  获取私密照图片回调
 *
 *  @param errType 结果类型
 *  @param errNo   结果编码
 *  @param errMsg  结果描述
 *  @param msgList 与该私密照相关的消息列表
 *  @param sizeType 私密照尺寸
 */

- (void)onGetPhoto:(LCC_ERR_TYPE)errType errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg msgList:(NSArray<LiveChatMsgItemObject*>* _Nonnull)msgList sizeType:(GETPHOTO_PHOTOSIZE_TYPE)sizeType;

/**
 *  获取图片
 *
 *  @param msgItem 消息
 */
- (void)onRecvPhoto:(LiveChatMsgItemObject* _Nonnull)msgItem;

/**
 *  获取收费的图片
 *
 *  @param success 操作是否成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param msgItem 消息
 */
- (void)onPhotoFee:(bool)success errNo:(NSString* _Nonnull) errNo errMsg:(NSString* _Nonnull) errMsg msgItem: (LiveChatMsgItemObject* _Nonnull) msgItem;

/**
 *  发送私密照信息回调
 *
 *  @param errType 结果类型
 *  @param errNo   结果编码
 *  @param errMsg  结果描述
 *  @param msgItem 消息
 */
- (void)onSendPhoto:(LCC_ERR_TYPE) errType errNo:(NSString* _Nonnull) errNo errMsg:(NSString* _Nonnull) errMsg msgItem:(LiveChatMsgItemObject* _Nonnull) msgItem;


/**
 *  获取高级表情设置item
 *
 *  @param success 操作是否成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param config  高级表情设置消息
 */
- (void)onGetEmotionConfig:(bool)success errNo:(NSString* _Nonnull)errNo  errMsg:(NSString* _Nonnull) errMsg otherEmtConItem:(LiveChatEmotionConfigItemObject* _Nullable) config;

/**
 *  手动下载/更新高级表情图片文件
 *
 *  @param success 操作是否成功
 *  @param item    高级表情Object
 */
- (void)onGetEmotionImage:(bool)success emtItem:(LiveChatEmotionItemObject* _Nullable)item;

/**
 *  手动下载/更新高级表情图片文件
 *
 *  @param succes  操作是否成功
 *  @param item    高级表情Object
 */
- (void)onGetEmotionPlayImage:(bool)success emtItem:(LiveChatEmotionItemObject* _Nullable)item;

/**
 *  发送高级表情回调
 *
 *  @param errNo    结果类型
 *  @param errMsg   结果描述
 *  @param msgItem  消息Object
 */
- (void)onSendEmotion:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg msgItem:(LiveChatMsgItemObject* _Nullable)msgItem;

/**
 *  接受高级表情
 *
 *  @param 消息Object
 *
 */
- (void)onRecvEmotion:(LiveChatMsgItemObject* _Nonnull)msgItem;

/**
 *  获取小高级表情设置item
 *
 *  @param success 操作是否成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param config  小高级表情设置消息
 */
- (void)onGetMagicIconConfig:(bool)success errNo:(NSString* _Nonnull)errNo  errMsg:(NSString* _Nonnull) errMsg magicIconConItem:(LiveChatMagicIconConfigItemObject* _Nonnull) config;

/**
 *  手动下载/更新小高级表情图片文件
 *
 *  @param success 操作是否成功
 *  @param item    小高级表情Object
 */
- (void)onGetMagicIconSrcImage:(bool)success magicIconItem:(LiveChatMagicIconItemObject* _Nonnull)item;


/**
 *  手动下载/更新小高级表情图片文件
 *
 *  @param succes  操作是否成功
 *  @param item    小高级表情Object
 */
- (void)onGetMagicIconThumbImage:(bool)success magicIconItem:(LiveChatMagicIconItemObject* _Nonnull)item;


/**
 *  发送小高级表情回调
 *
 *  @param errNo    结果类型
 *  @param errMsg   结果描述
 *  @param msgItem  消息Object
 */
- (void)onSendMagicIcon:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg msgItem:(LiveChatMsgItemObject* _Nullable)msgItem;

/**
 *  接受小高级表情
 *
 *  @param 消息item
 *
 */
- (void)onRecvMagicIcon:(LiveChatMsgItemObject*  _Nonnull)msgItem;

@end
