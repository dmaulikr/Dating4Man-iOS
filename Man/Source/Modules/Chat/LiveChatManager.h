//
//  LiveChatManManager.h
//  dating
//
//  Created by lance on 16/4/13.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <livechatmanmanager/ILiveChatManManager.h>
#import "LiveChatManagerListener.h"

@interface LiveChatManager : NSObject

@property (nonatomic, strong) NSString* _Nonnull versionCode;

#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

#pragma mark - 委托/获取登录状态
/**
 *  添加委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)addDelegate:(id<LiveChatManagerDelegate> _Nonnull)delegate;

/**
 *  移除委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)removeDelegate:(id<LiveChatManagerDelegate> _Nonnull)delegate;

#pragma mark - 在线状态
/**
 *  立即重登录
 */
- (void)relogin;
/**
 *  获取登录状态
 *
 *  @return 是否正在登录（YES：正在登录，否则为未登录状态）
 */
- (BOOL)isLogin;

/**
 *  获取指定用户在线状态
 *
 *  @param userIds 用户ID数组
 *
 *  @return 操作是否成功
 */

- (BOOL)getUserStatus:(NSArray<NSString*>* _Nonnull)userIds;

/**
 *  停止会话
 *
 *  @param userId 用户Id
 *
 *  @return 操作是否成功
 */
- (BOOL)endTalk:(NSString* _Nonnull)userId;

/**
 *  停止所有会话
 *
 *  @return 操作是否成功
 */
- (void)endTalkAll;

#pragma mark - 获取用户信息
/**
 *  获取用户信息
 *
 *  @param userId 用户ID
 *
 *  @return 操作是否成功
 */
- (BOOL)getUserInfo:(NSString* _Nonnull)userId;

/**
 *  获取多个用户信息
 *
 *  @param userIds 用户ID数组
 *
 *  @return 操作是否成功
 */
- (BOOL)getUsersInfo:(NSArray<NSString*>* _Nonnull)userIds;

#pragma mark - 试聊券
/**
 *  检测是否可使用试聊券
 *
 *  @param userId 用户ID
 *
 *  @return 操作是否成功
 */
- (BOOL)checkTryTicket:(NSString* _Nonnull)userId;

#pragma mark - 公共操作
/**
 *  获取指定用户聊天消息数组
 *
 *  @param userId 用户ID
 *
 *  @return 返回用户聊天消息数组
 */
- (NSArray<LiveChatMsgItemObject*>* _Nonnull)getMsgsWithUser:(NSString* _Nonnull)userId;

/**
 *  获取用户
 *
 *  @param userId 用户ID
 *
 *  @return 用户
 */
- (LiveChatUserItemObject* _Nullable)getUserWithId:(NSString* _Nonnull)userId;

/**
 *
 *
 *  @return 返回邀请用户列表
 */
- (NSArray<LiveChatUserItemObject*>* _Nonnull)getInviteUsers;

/**
 *  获取在聊用户数组
 *
 *  @return 用户数组
 */
- (NSArray<LiveChatUserItemObject*>* _Nonnull)getChatingUsers;

#pragma mark - 普通消息处理（文本/历史聊天消息等）
/**
 *  发送文本消息
 *
 *  @param userId 用户ID
 *  @param text   文本消息内容
 *
 *  @return 消息
 */
- (LiveChatMsgItemObject* _Nullable)sendTextMsg:(NSString* _Nonnull)userId text:(NSString* _Nonnull)text;

/**
 *  获取消息处理状态
 *
 *  @param userId 用户ID
 *  @param msgId  消息ID
 *
 *  @return 消息处理状态
 */
- (LCMessageItem::StatusType)getMsgStatus:(NSString* _Nonnull)userId msgId:(NSInteger)msgId;

/**
 *  插入历史消息记录
 *
 *  @param userId 用户ID
 *  @param msg    消息
 *
 *  @return 消息ID
 */
- (NSInteger)insertHistoryMessage:(NSString* _Nonnull)userId msg:(LiveChatMsgItemObject* _Nonnull)msg;

/**
 *  删除历史消息记录(一般用于重发消息)
 *
 *  @param userId 用户ID
 *  @param msgId  消息ID
 *
 *  @return 处理结果
 */
- (BOOL)removeHistoryMessage:(NSString* _Nonnull)userId msgId:(NSInteger)msgId;

/**
 *  获取用户最后一条聊天消息
 *
 *  @param userId 用户ID
 *
 *  @return 最后一条聊天消息
 */
- (LiveChatMsgItemObject* _Nullable)getLastMsg:(NSString* _Nonnull)userId;


/**
 *  获取对方最后一条聊天消息
 *
 *  @param userId 用户id
 *
 *  @return 对方最后一条聊天消息
 */
- (LiveChatMsgItemObject* _Nullable)GetTheOtherLastMessage:(NSString* _Nonnull)userId;

/**
 *  发送图片
 *
 *  @param userId    用户Id
 *  @param photoPath 私密照的路径
 *
 *  @return 私密照消息
 */
- (LiveChatMsgItemObject * _Nullable)SendPhoto:(NSString * _Nonnull)userId PhotoPath:(NSString * _Nonnull)photoPath;
/**
 *  购买图片
 *
 *  @param userId 用户Id
 *  @param msgId  私密照Id
 *
 *  @return 处理结果
 */
- (BOOL)PhotoFee:(NSString * _Nonnull)userId mphotoId:(NSString * _Nonnull)photoId;
/**
 *  根据消息ID获取图片(模糊或清晰)
 *
 *  @param userId   用户Id
 *  @param msgId    私密照Id
 *  @param sizeType 私密照大小类型
 *
 *  @return 处理结果
 */
- (BOOL)getPhoto:(NSString * _Nonnull)userId photoId:(NSString * _Nonnull)photoId sizeType:(GETPHOTO_PHOTOSIZE_TYPE)sizeType sendType:(LCMessageItem::SendType)sendType;


#pragma mark - 高级表情消息处理（大高表）
/**
 * 发送高级表情
 *
 * @param userId   用户Id
 * @param emtionId   大高级表情Id
 *
 * @return 高级表情消息
 */
-(LiveChatMsgItemObject* _Nullable)SendEmotion:(NSString * _Nonnull)userId emotionId:(NSString * _Nonnull)emotionId;
/**
 * 获取高级表情配置item
 *
 * @return 高级表情配置item
 */
-(LiveChatEmotionConfigItemObject* _Nullable)GetEmotionConfigItem;
/**
 * 获取高级表情item
 *
 * @param emotionId 高级表情ID
 * 
 * @return 高级表情item
 */
-(LiveChatEmotionItemObject* _Nullable)GetEmotionInfo:(NSString * _Nonnull)emotionId;
/**
 * 手动下载/更新高级表情图片文件(一张图)
 *
 * @param emotionId 高级表情ID
 *
 * @return 处理结果
 */
-(BOOL)GetEmotionImage:(NSString * _Nonnull)emotionId;
/**
 * 手动下载/更新高级表情图片文件（一大张图，并且要载剪成多张图）
 *
 * @param emotionId 高级表情ID
 *
 * @return 处理结果
 */
-(BOOL)GetEmotionPlayImage:(NSString * _Nonnull)emotionId;


#pragma mark - 小高级表情消息处理
/**
 * 发送小高级表情
 *
 * @param userId   用户Id
 * @param iconId   小高表Id
 *
 * @return 小高表情配置消息
 */
-(LiveChatMsgItemObject* _Nullable)SendMagicIcon:(NSString * _Nonnull)userId iconId:(NSString * _Nonnull)iconId;
/**
 * 获取小高级表情配置item
 *
 * @return 小高表情消息
 */
-(LiveChatMagicIconConfigItemObject* _Nullable) GetMagicIconConfigItem;
/**
 * 获取小高级表情item
 *
 * @param magicIconId   小高级表情Id
 *
 * @return 小高表情消息
 */
-(LiveChatMagicIconItemObject* _Nullable) GetMagicIconInfo:(NSString * _Nonnull)magicIconId;
/**
 * 手动下载／更新小高级表情原图source
 *
 * @param magicIconId   小高级表情Id
 *
 * @return
 */
-(BOOL) GetMagicIconSrcImage:(NSString * _Nonnull)magicIconId;
/**
 * 手动下载／更新小高级表情拇子图thumb
 *
 * @param magicIconId   小高级表情Id
 *
 * @return
 */
-(BOOL) GetMagicIconThumbImage:(NSString * _Nonnull)magicIconId;


@end
