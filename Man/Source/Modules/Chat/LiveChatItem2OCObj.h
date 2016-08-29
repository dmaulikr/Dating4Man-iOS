//
//  LiveChatItem2OCObj.h
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

@interface LiveChatItem2OCObj : NSObject

#pragma mark - 公共处理
/**
 *  list<string>转NSArray
 *
 *  @param strList list<string>
 *
 *  @return NSString的NSArray
 */
+ (NSArray<NSString*>* _Nonnull)getStringArray:(const list<string>&)strList;

/**
 *  NSArray转list<string>
 *
 *  @param strArray NSString的NSArray
 *
 *  @return list<string>
 */
+ (list<string>)getStringList:(NSArray<NSString*>* _Nonnull)strArray;

#pragma mark - user object
/**
 *  获取用户object
 *
 *  @param userItem 用户item
 *
 *  @return 用户object
 */
+ (LiveChatUserItemObject* _Nullable)getLiveChatUserItemObject:(const LCUserItem* _Nullable)userItem;

/**
 *  获取用户object数组
 *
 *  @param userList 用户item list
 *
 *  @return 用户object数组
 */
+ (NSArray<LiveChatUserItemObject*>* _Nonnull)getLiveChatUserArray:(const LCUserList&)userList;

/**
 *  获取用户ID数组
 *
 *  @param userList 用户item list
 *
 *  @return 用户ID数组
 */
+ (NSArray<NSString*>* _Nonnull)getLiveChatUserIdArray:(const LCUserList&)userList;

#pragma mark - message object
/**
 *  获取消息object
 *
 *  @param msgItem 消息item
 *
 *  @return 消息object
 */
+ (LiveChatMsgItemObject* _Nullable)getLiveChatMsgItemObject:(const LCMessageItem* _Nullable)msgItem;

/**
 *  获取消息object数组
 *
 *  @param msgList 消息item list
 *
 *  @return 消息object数组
 */
+ (NSArray<LiveChatMsgItemObject*>* _Nonnull)getLiveChatMsgArray:(const LCMessageList&)msgList;

#pragma mark - message item
/**
 *  获取消息item
 *
 *  @param msg 消息object
 *
 *  @return 消息item
 */
+ (LCMessageItem* _Nullable)getLiveChatMsgItem:(LiveChatMsgItemObject* _Nonnull)msg;

#pragma mark - userinfo item
/**
 *  获取用户信息object
 *
 *  @param userInfo 用户信息item
 *
 *  @return 用户信息object
 */
+ (LiveChatUserInfoItemObject* _Nullable)getLiveChatUserInfoItemObjecgt:(const UserInfoItem&)userInfo;

/**
 *  获取用户信息object数组
 *
 *  @param userInfoList 用户信息item list
 *
 *  @return 用户信息object数组
 */
+ (NSArray<LiveChatUserItemObject*>* _Nonnull)getLiveChatUserInfoArray:(const UserInfoList&)userInfoList;


@end
