//
//  LiveChatItem2OCObj.m
//  dating
//
//  Created by  Samson on 5/16/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import "LiveChatItem2OCObj.h"

@interface LiveChatItem2OCObj ()

#pragma mark - message object
+ (LiveChatTextItemObject* _Nullable)getLiveChatTextItemObject:(const LCTextItem*)textItem;
+ (LiveChatWarningItemObject* _Nullable)getLiveChatWarningItemObject:(const LCWarningItem*)warningItem;
+ (LiveChatSystemItemObject* _Nullable)getLiveChatSystemItemObject:(const LCSystemItem*)systemItem;
+ (LiveChatCustomItemObject* _Nullable)getLiveChatCustomItemObject:(const LCCustomItem*)customItem;

#pragma mark - message item
+ (LCTextItem* _Nullable)getLiveChatTextItem:(LiveChatTextItemObject* _Nonnull)text;
+ (LCWarningItem* _Nullable)getLiveChatWarningItem:(LiveChatWarningItemObject* _Nonnull)warning;
+ (LCSystemItem* _Nullable)getLiveChatSystemItem:(LiveChatSystemItemObject* _Nonnull)system;
+ (LCCustomItem* _Nullable)getLiveChatCustomItem:(LiveChatCustomItemObject* _Nonnull)custom;
@end

@implementation LiveChatItem2OCObj
#pragma mark - 公共处理
/**
 *  list<string>转NSArray
 *
 *  @param strList list<string>
 *
 *  @return NSString的NSArray
 */
+ (NSArray* _Nonnull)getStringArray:(const list<string>&)strList
{
    NSMutableArray* strArray = [NSMutableArray array];
    for (list<string>::const_iterator iter = strList.begin();
         iter != strList.end();
         iter++)
    {
        NSString* str = [NSString stringWithUTF8String:(*iter).c_str()];
        if (nil != str) {
            [strArray addObject:str];
        }
    }
    return strArray;
}

/**
 *  NSArray转list<string>
 *
 *  @param strArray NSString的NSArray
 *
 *  @return list<string>
 */
+ (list<string>)getStringList:(NSArray* _Nonnull)strArray
{
    list<string> strList;
    for (NSString* str in strArray)
    {
        const char* pStr = [str UTF8String];
        strList.push_back(pStr);
    }
    return strList;
}

#pragma mark - user object
/**
 *  获取用户object
 *
 *  @param userItem 用户item
 *
 *  @return 用户object
 */
+ (LiveChatUserItemObject* _Nullable)getLiveChatUserItemObject:(const LCUserItem* _Nullable)userItem
{
    LiveChatUserItemObject* obj = nil;
    if (NULL != userItem)
    {
        obj = [[LiveChatUserItemObject alloc] init];
        obj.userId = [NSString stringWithUTF8String:userItem->m_userId.c_str()];
        obj.userName = [NSString stringWithUTF8String:userItem->m_userName.c_str()];
        obj.sexType = userItem->m_sexType;
        obj.clientType = userItem->m_clientType;
        obj.statusType = userItem->m_statusType;
        obj.chatType = userItem->m_chatType;
        obj.inviteId = [NSString stringWithUTF8String:userItem->m_inviteId.c_str()];
        obj.tryingSend = userItem->m_tryingSend ? YES : NO;
        obj.order = userItem->m_order;
    }
    return obj;
}

/**
 *  获取用户object数组
 *
 *  @param userList 用户item list
 *
 *  @return 用户object数组
 */
+ (NSArray* _Nonnull)getLiveChatUserArray:(const LCUserList&)userList
{
    NSMutableArray* users = [NSMutableArray array];
    for (LCUserList::const_iterator iter = userList.begin();
         iter != userList.end();
         iter++)
    {
        const LCUserItem* userItem = (*iter);
        LiveChatUserItemObject* userObj = [self getLiveChatUserItemObject:userItem];
        if (nil != userObj) {
            [users addObject:userObj];
        }
    }
    return users;
}

/**
 *  获取用户ID数组
 *
 *  @param userList 用户item list
 *
 *  @return 用户ID数组
 */
+ (NSArray* _Nonnull)getLiveChatUserIdArray:(const LCUserList&)userList
{
    NSMutableArray* userIds = [NSMutableArray array];
    for (LCUserList::const_iterator iter = userList.begin();
         iter != userList.end();
         iter++)
    {
        const LCUserItem* userItem = (*iter);
        NSString* userId = [NSString stringWithUTF8String:userItem->m_userId.c_str()];
        [userIds addObject:userId];
    }
    return userIds;
}

#pragma mark - message object
/**
 *  获取消息object
 *
 *  @param msgItem 消息item
 *
 *  @return 消息object
 */
+ (LiveChatMsgItemObject* _Nullable)getLiveChatMsgItemObject:(const LCMessageItem* _Nullable)msgItem
{
    LiveChatMsgItemObject* obj = nil;
    if (NULL != msgItem)
    {
        obj = [[LiveChatMsgItemObject alloc] init];
        obj.msgId  = msgItem->m_msgId;
        obj.sendType = msgItem->m_sendType;
        obj.fromId = [NSString stringWithUTF8String:msgItem->m_fromId.c_str()];
        obj.toId = [NSString stringWithUTF8String:msgItem->m_toId.c_str()];
        obj.inviteId = [NSString stringWithUTF8String:msgItem->m_inviteId.c_str()];
        obj.createTime = msgItem->m_createTime;
        obj.statusType = msgItem->m_statusType;
        obj.msgType = msgItem->m_msgType;
        
        if (LCMessageItem::MT_Text == msgItem->m_msgType) {
            obj.textMsg = [self getLiveChatTextItemObject:msgItem->GetTextItem()];
        }
        else if (LCMessageItem::MT_Warning == msgItem->m_msgType) {
            obj.warningMsg = [self getLiveChatWarningItemObject:msgItem->GetWarningItem()];
        }
        else if (LCMessageItem::MT_System == msgItem->m_msgType) {
            obj.systemMsg = [self getLiveChatSystemItemObject:msgItem->GetSystemItem()];
        }
        else if (LCMessageItem::MT_Custom == msgItem->m_msgType) {
            obj.customMsg = [self getLiveChatCustomItemObject:msgItem->GetCustomItem()];
        }
    }
    return obj;
}

/**
 *  获取消息object数组
 *
 *  @param msgList 消息item list
 *
 *  @return 消息object数组
 */
+ (NSArray* _Nonnull)getLiveChatMsgArray:(const LCMessageList&)msgList
{
    NSMutableArray* msgs = [NSMutableArray array];
    for (LCMessageList::const_iterator iter = msgList.begin();
         iter != msgList.end();
         iter++)
    {
        const LCMessageItem* msgItem = (*iter);
        LiveChatMsgItemObject* msgObj = [self getLiveChatMsgItemObject:msgItem];
        if (nil != msgObj) {
            [msgs addObject:msgObj];
        }
    }
    return msgs;
}

/**
 *  获取文本消息object
 *
 *  @param textItem 文本消息item
 *
 *  @return 文本消息object
 */
+ (LiveChatTextItemObject* _Nullable)getLiveChatTextItemObject:(const LCTextItem*)textItem
{
    LiveChatTextItemObject* obj = nil;
    if (NULL != textItem)
    {
        obj = [[LiveChatTextItemObject alloc] init];
        obj.message = [NSString stringWithUTF8String:textItem->m_message.c_str()];
        obj.illegal = textItem->m_illegal ? YES : NO;
    }
    return obj;
}

/**
 *  获取警告消息object
 *
 *  @param warningItem 警告消息item
 *
 *  @return 警告消息object
 */
+ (LiveChatWarningItemObject* _Nullable)getLiveChatWarningItemObject:(const LCWarningItem*)warningItem
{
    LiveChatWarningItemObject* obj = nil;
    if (NULL != warningItem)
    {
        obj = [[LiveChatWarningItemObject alloc] init];
        obj.codeType = warningItem->m_codeType;
        obj.message = [NSString stringWithUTF8String:warningItem->m_message.c_str()];
        
        if (NULL != warningItem->m_linkItem)
        {
            LCWarningLinkItem* linkItem = warningItem->m_linkItem;
            LiveChatWarningLinkItemObject* linkObj = [[LiveChatWarningLinkItemObject alloc] init];
            linkObj.linkMsg = [NSString stringWithUTF8String:linkItem->m_linkMsg.c_str()];
            linkObj.linkOptType = linkItem->m_linkOptType;
            
            obj.link = linkObj;
        }
    }
    return obj;
}

/**
 *  获取系统消息object
 *
 *  @param systemItem 系统消息item
 *
 *  @return 系统消息object
 */
+ (LiveChatSystemItemObject* _Nullable)getLiveChatSystemItemObject:(const LCSystemItem*)systemItem
{
    LiveChatSystemItemObject* obj = nil;
    if (NULL != systemItem)
    {
        obj = [[LiveChatSystemItemObject alloc] init];
        obj.codeType = systemItem->m_codeType;
        obj.message = [NSString stringWithUTF8String:systemItem->m_message.c_str()];
    }
    return obj;
}

/**
 *  获取自定义消息object
 *
 *  @param customItem 自定义消息item
 *
 *  @return 自定义消息object
 */
+ (LiveChatCustomItemObject* _Nullable)getLiveChatCustomItemObject:(const LCCustomItem*)customItem
{
    LiveChatCustomItemObject* obj = nil;
    if (NULL != customItem)
    {
        obj = [[LiveChatCustomItemObject alloc] init];
        obj.param = customItem->m_param;
    }
    return obj;
}

#pragma mark - message item
/**
 *  获取消息item
 *
 *  @param msg 消息object
 *
 *  @return 消息item
 */
+ (LCMessageItem* _Nullable)getLiveChatMsgItem:(LiveChatMsgItemObject* _Nonnull)msg
{
    LCMessageItem* msgItem = new LCMessageItem;
    if (NULL != msgItem)
    {
        msgItem->m_fromId = [msg.fromId UTF8String];
        msgItem->m_inviteId = [msg.inviteId UTF8String];
        msgItem->m_sendType = msg.sendType;
        msgItem->m_statusType = msg.statusType;
        msgItem->m_toId = [msg.toId UTF8String];
        msgItem->m_createTime = msg.createTime;
        msgItem->m_statusType = msg.statusType;
        
        if (LCMessageItem::MT_Text == msg.msgType)
        {
            LCTextItem* textItem = [LiveChatItem2OCObj getLiveChatTextItem:msg.textMsg];
            msgItem->SetTextItem(textItem);
        }
        else if (LCMessageItem::MT_Warning == msg.msgType)
        {
            LCWarningItem* warningItem = [LiveChatItem2OCObj getLiveChatWarningItem:msg.warningMsg];
            msgItem->SetWarningItem(warningItem);
        }
        else if (LCMessageItem::MT_System == msg.msgType)
        {
            LCSystemItem* systemItem = [LiveChatItem2OCObj getLiveChatSystemItem:msg.systemMsg];
            msgItem->SetSystemItem(systemItem);
        }
        else if (LCMessageItem::MT_Custom == msg.msgType)
        {
            LCCustomItem* customItem = [LiveChatItem2OCObj getLiveChatCustomItem:msg.customMsg];
            msgItem->SetCustomItem(customItem);
        }
        else
        {
            delete msgItem;
            msgItem = NULL;
        }
    }
    return msgItem;
}

/**
 *  获取文本消息item
 *
 *  @param text 文本消息object
 *
 *  @return 文本消息item
 */
+ (LCTextItem* _Nullable)getLiveChatTextItem:(LiveChatTextItemObject* _Nonnull)text
{
    LCTextItem* textItem = new LCTextItem;
    if (NULL != textItem)
    {
        textItem->m_message = [text.message UTF8String];
        textItem->m_illegal = text.illegal ? true : false;
    }
    return textItem;
}

/**
 *  获取警告消息item
 *
 *  @param warning 警告消息object
 *
 *  @return 警告消息item
 */
+ (LCWarningItem* _Nullable)getLiveChatWarningItem:(LiveChatWarningItemObject* _Nonnull)warning
{
    LCWarningItem* warningItem = new LCWarningItem;
    if (NULL != warningItem)
    {
        warningItem->m_message = [warning.message UTF8String];
        if (nil != warning.link)
        {
            warningItem->m_linkItem = new LCWarningLinkItem;
            if (NULL != warningItem->m_linkItem)
            {
                warningItem->m_linkItem->m_linkMsg = [warning.link.linkMsg UTF8String];
                warningItem->m_linkItem->m_linkOptType = warning.link.linkOptType;
            }
        }
    }
    return warningItem;
}

/**
 *  获取系统消息item
 *
 *  @param system 系统消息object
 *
 *  @return 系统消息item
 */
+ (LCSystemItem* _Nullable)getLiveChatSystemItem:(LiveChatSystemItemObject* _Nonnull)system
{
    LCSystemItem* systemItem = new LCSystemItem;
    if (NULL != systemItem)
    {
        systemItem->m_message = [system.message UTF8String];
    }
    return systemItem;
}

/**
 *  获取自定义消息item
 *
 *  @param custom 自定义消息object
 *
 *  @return 自定义消息item
 */
+ (LCCustomItem* _Nullable)getLiveChatCustomItem:(LiveChatCustomItemObject* _Nonnull)custom
{
    LCCustomItem* customItem = new LCCustomItem;
    if (NULL != customItem)
    {
        customItem->m_param = custom.param;
    }
    return customItem;
}

#pragma mark - userinfo item
/**
 *  获取用户信息object
 *
 *  @param userInfo 用户信息item
 *
 *  @return 用户信息object
 */
+ (LiveChatUserInfoItemObject* _Nullable)getLiveChatUserInfoItemObjecgt:(const UserInfoItem&)userInfo
{
    LiveChatUserInfoItemObject* object = [[LiveChatUserInfoItemObject alloc] init];
    if (nil != object) {
        object.userId = [NSString stringWithUTF8String:userInfo.userId.c_str()];
        object.userName = [NSString stringWithUTF8String:userInfo.userName.c_str()];
        object.server = [NSString stringWithUTF8String:userInfo.server.c_str()];
        object.imgUrl = [NSString stringWithUTF8String:userInfo.imgUrl.c_str()];
        object.sexType = userInfo.sexType;
        object.age = userInfo.age;
        object.weight = [NSString stringWithUTF8String:userInfo.weight.c_str()];
        object.height = [NSString stringWithUTF8String:userInfo.height.c_str()];
        object.country = [NSString stringWithUTF8String:userInfo.country.c_str()];
        object.province = [NSString stringWithUTF8String:userInfo.province.c_str()];
        
        object.videoChat = userInfo.videoChat ? YES : NO;
        object.videoCount = userInfo.videoCount;
        object.marryType = userInfo.marryType;
        object.childrenType = userInfo.childrenType;
        object.status = userInfo.status;
        object.userType = userInfo.userType;
        object.orderValue = userInfo.orderValue;
        
        // 设备及客户端
        object.deviceType = userInfo.deviceType;
        object.clientType = userInfo.clientType;
        object.clientVersion = [NSString stringWithUTF8String:userInfo.clientVersion.c_str()];
        
        // 翻译
        object.needTrans = userInfo.needTrans ? YES : NO;
        object.transUserId = [NSString stringWithUTF8String:userInfo.transUserId.c_str()];
        object.transUserName = [NSString stringWithUTF8String:userInfo.transUserName.c_str()];
        object.transBind = userInfo.transBind ? YES : NO;
        object.transStatus = userInfo.transStatus;
    }
    return object;
}

/**
 *  获取用户信息object数组
 *
 *  @param userInfoList 用户信息item list
 *
 *  @return 用户信息object数组
 */
+ (NSArray* _Nonnull)getLiveChatUserInfoArray:(const UserInfoList&)userInfoList
{
    NSMutableArray* userInfoArray = [NSMutableArray array];
    for (UserInfoList::const_iterator iter = userInfoList.begin();
         iter != userInfoList.end();
         iter++)
    {
        LiveChatUserInfoItemObject* object = [self getLiveChatUserInfoItemObjecgt:(*iter)];
        if (nil != object) {
            [userInfoArray addObject:object];
        }
    }
    return userInfoArray;
}

@end
