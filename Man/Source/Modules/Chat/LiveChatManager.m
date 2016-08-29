 //
//  LiveChatManManager.m
//  dating
//
//  Created by lance on 16/4/13.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LiveChatManager.h"
#include <manrequesthandler/HttpRequestManager.h>
#import "LiveChatItem2OCObj.h"
#import "LiveChatUserItemObject.h"
#import "LiveChatMsgItemObject.h"
#import "ConfigManager.h"
#import "LoginManager.h"
#import "RequestManager.h"
#import "Message.h"
#import "ServerManager.h"

static LiveChatManager* gManager = nil;
@interface LiveChatManager ()<LoginManagerDelegate>{
    ILiveChatManManager *mILiveChatManManager;
    ILiveChatManManagerListener *mILiveChatManManagerListener;
}

@property (nonatomic, strong) NSMutableArray* delegates;
@property (nonatomic, strong) LoginManager* loginManager;
@property (nonatomic,strong) RequestManager *requestManager;

// ---- 登录/注销 ----
- (void)onLoginUser:(LCC_ERR_TYPE)errType errMsg:(const char* _Nonnull)errMsg isAutoLogin:(bool)isAutoLogin;
- (void)onLogoutUser:(LCC_ERR_TYPE)errType errMsg:(const char* _Nonnull)errMsg isAutoLogin:(bool)isAutoLogin;

// ---- 在线状态 ----
- (void)onGetUserStatus:(LCC_ERR_TYPE)errType errMsg:(const char* _Nonnull)errMsg userList:(const LCUserList&)userList;
- (void)onRecvKickOffline:(KICK_OFFLINE_TYPE)kickType;
- (void)onChangeOnlineStatus:(const LCUserItem* _Nonnull)userItem;

// ---- 获取用户资料 ----
- (void)onGetUserInfo:(LCC_ERR_TYPE)errType errMsg:(const char* _Nonnull)errMsg userId:(const char* _Nonnull)userId userInfo:(const UserInfoItem&)userInfo;
- (void)onGetUsersInfo:(LCC_ERR_TYPE)errType errMsg:(const char* _Nonnull)errMsg userInfoList:(const UserInfoList&)userInfoList;

// ---- 聊天状态 ----
- (void)onGetTalkList:(LCC_ERR_TYPE)errType errMsg:(const char* _Nonnull)errMsg;
- (void)onRecvTalkEvent:(const LCUserItem* _Nonnull)userItem;
- (void)onRecvEMFNotice:(const char* _Nonnull)userId noticeType:(TALK_EMF_NOTICE_TYPE)noticeType;

// ---- 文本消息 ----
- (void)onSendTextMsg:(LCC_ERR_TYPE)errType errMsg:(const char* _Nonnull)errMsg msgItem:(LCMessageItem* _Nullable)msgItem;
- (void)onSendTextMsgsFail:(LCC_ERR_TYPE)errType msgList:(const LCMessageList&)msgList;
- (void)onRecvTextMsg:(LCMessageItem* _Nonnull)msgItem;
- (void)onRecvSystemMsg:(LCMessageItem* _Nonnull)msgItem;
- (void)onRecvWarningMsg:(LCMessageItem* _Nonnull)msgItem;
- (void)onRecvEditMsg:(const char* _Nonnull)userId;
- (void)onGetHistoryMessage:(bool)success errNo:(const string&)errNo errMsg:(const string&) errMsg userItem:(LCUserItem* _Nonnull)userItem;
- (void)onGetUsersHistoryMessage:(bool)success errNo:(const string&)errNo errMsg:(const string&) errMsg userList:(const LCUserList&)userList;

// ---- 试聊券 ----
- (void)onCheckTryTicket:(bool)success errNo:(const char* _Nonnull)errNo errMsg:(const char* _Nonnull)errMsg userId:(const char* _Nonnull)userId status:(CouponStatus)status;
- (void)onUseTryTicket:(LCC_ERR_TYPE)errType errMsg:(const char* _Nonnull)errMsg userId:(const char* _Nonnull)userId tickEvent:(TRY_TICKET_EVENT)tickEvent;
- (void)onRecvTryTalkBegin:(LCUserItem* _Nonnull)userItem time:(int)time;
- (void)onRecvTryTalkEnd:(LCUserItem* _Nonnull)userItem;

// ---- 私密照 ----
- (void)onGetPhoto:(LCC_ERR_TYPE)errType errNo:(const string&)errNo errMsg:(const string&)errMsg msgList:(const LCMessageList&)msgList sizeType:(GETPHOTO_PHOTOSIZE_TYPE)sizeType;
- (void)onPhotoFee:(bool) success errNo:(const string&) errNo errMsg:(const string&) errMsg msgItem: (LCMessageItem*) msgItem;
- (void)onRecvPhoto:(LCMessageItem*) msgItem;
- (void)onSendPhoto:(LCC_ERR_TYPE) errType errNo:(const string&) errNo errMsg:(const string&) errMsg msgItem:(LCMessageItem*) msgItem;
@end

#pragma mark - LiveChatManManagerListener
class LiveChatManManagerListener : public ILiveChatManManagerListener
{
public:
    LiveChatManManagerListener() {};
    virtual ~LiveChatManManagerListener() {};
    
public:
#pragma mark - login/logout listener
    virtual void OnLogin(LCC_ERR_TYPE errType, const string& errMsg, bool isAutoLogin)
    {
        if (nil != gManager) {
            [gManager onLoginUser:errType errMsg:errMsg.c_str() isAutoLogin:isAutoLogin];
        }
    };
    virtual void OnLogout(LCC_ERR_TYPE errType, const string& errMsg, bool isAutoLogin)
    {
        if (nil != gManager) {
            [gManager onLogoutUser:errType errMsg:errMsg.c_str() isAutoLogin:isAutoLogin];
        }
    };
    
#pragma mark - online status listener
    virtual void OnRecvKickOffline(KICK_OFFLINE_TYPE kickType)
    {
        if (nil != gManager) {
            [gManager onRecvKickOffline:kickType];
        }
    };
    virtual void OnSetStatus(LCC_ERR_TYPE errType, const string& errMsg) {};
    virtual void OnChangeOnlineStatus(LCUserItem* userItem)
    {
        if (nil != gManager) {
            [gManager onChangeOnlineStatus:userItem];
        }
    };
    virtual void OnGetUserStatus(LCC_ERR_TYPE errType, const string& errMsg, const LCUserList& userList)
    {
        if (nil != gManager) {
            [gManager onGetUserStatus:errType errMsg:errMsg.c_str() userList:userList];
        }
    };
    virtual void OnUpdateStatus(LCUserItem* userItem) {};
    
#pragma mark - user info listener
    virtual void OnGetUserInfo(const string& userId, LCC_ERR_TYPE errType, const string& errMsg, const UserInfoItem& userInfo)
    {
        if (nil != gManager) {
            [gManager onGetUserInfo:errType errMsg:errMsg.c_str() userId:userId.c_str() userInfo:userInfo];
        }
    }
    virtual void OnGetUsersInfo(LCC_ERR_TYPE errType, const string& errMsg, const UserInfoList& userList)
    {
        if (nil != gManager) {
            [gManager onGetUsersInfo:errType errMsg:errMsg.c_str() userInfoList:userList];
        }
    }
    
#pragma mark - chat status listener
    virtual void OnGetTalkList(LCC_ERR_TYPE errType, const string& errMsg)
    {
        if (nil != gManager) {
            [gManager onGetTalkList:errType errMsg:errMsg.c_str()];
        }
    };
    virtual void OnEndTalk(LCC_ERR_TYPE errType, const string& errMsg, LCUserItem* userItem) {};
    virtual void OnRecvTalkEvent(LCUserItem* userItem)
    {
        if (nil != gManager) {
            [gManager onRecvTalkEvent:userItem];
        }
    };
    
#pragma mark - notice listener
    virtual void OnRecvEMFNotice(const string& fromId, TALK_EMF_NOTICE_TYPE noticeType)
    {
        if (nil != gManager) {
            [gManager onRecvEMFNotice:fromId.c_str() noticeType:noticeType];
        }
    };
    
#pragma mark - try ticket listener
    virtual void OnCheckCoupon(bool success, const string& errNo, const string& errMsg, const string& userId, CouponStatus status)
    {
        if (nil != gManager) {
            [gManager onCheckTryTicket:success errNo:errNo.c_str() errMsg:errMsg.c_str() userId:userId.c_str() status:status];
        }
    };
    virtual void OnRecvTryTalkBegin(LCUserItem* userItem, int time)
    {
        if (nil != gManager) {
            [gManager onRecvTryTalkBegin:userItem time:time];
        }
    };
    virtual void OnRecvTryTalkEnd(LCUserItem* userItem)
    {
        if (nil != gManager) {
            [gManager onRecvTryTalkEnd:userItem];
        }
    };
    virtual void OnUseTryTicket(LCC_ERR_TYPE err, const string& errmsg, const string& userId, TRY_TICKET_EVENT tickEvent)
    {
        if (nil != gManager) {
            [gManager onUseTryTicket:err errMsg:errmsg.c_str() userId:userId.c_str() tickEvent:tickEvent];
        }
    };
    
#pragma mark - message listener
    virtual void OnRecvEditMsg(const string& fromId)
    {
        if (nil != gManager) {
            [gManager onRecvEditMsg:fromId.c_str()];
        }
    };
    virtual void OnRecvMessage(LCMessageItem* msgItem)
    {
        if (nil != gManager) {
            [gManager onRecvTextMsg:msgItem];
        }
    };
    virtual void OnRecvSystemMsg(LCMessageItem* msgItem)
    {
        if (nil != gManager) {
            [gManager onRecvSystemMsg:msgItem];
        }
    };
    virtual void OnRecvWarningMsg(LCMessageItem* msgItem)
    {
        if (nil != gManager) {
            [gManager onRecvWarningMsg:msgItem];
        }
    };
    virtual void OnSendTextMessage(LCC_ERR_TYPE errType, const string& errMsg, LCMessageItem* msgItem)
    {
        if (nil != gManager) {
            [gManager onSendTextMsg:errType errMsg:errMsg.c_str() msgItem:msgItem];
        }
    };
    virtual void OnSendMessageListFail(LCC_ERR_TYPE errType, const LCMessageList& msgList)
    {
        if (nil != gManager) {
            [gManager onSendTextMsgsFail:errType msgList:msgList];
        }
    };
    virtual void OnGetHistoryMessage(bool success, const string& errNo, const string& errMsg, LCUserItem* userItem)
    {
        if (nil != gManager) {
            [gManager onGetHistoryMessage:success errNo:errNo errMsg:errMsg userItem:userItem];
        }
    };
    virtual void OnGetUsersHistoryMessage(bool success, const string& errNo, const string& errMsg, const LCUserList& userList)
    {
        if (nil != gManager) {
            [gManager onGetUsersHistoryMessage:success errNo:errNo errMsg:errMsg userList:userList];
        }
    };
    
#pragma mark - emotion listener
    virtual void OnGetEmotionConfig(bool success, const string& errNo, const string& errMsg, const OtherEmotionConfigItem& config){};
    virtual void OnGetEmotionImage(bool success, const LCEmotionItem* item){};
    virtual void OnGetEmotionPlayImage(bool success, const LCEmotionItem* item){};
    virtual void OnRecvEmotion(LCMessageItem* msgItem){};
    virtual void OnSendEmotion(LCC_ERR_TYPE errType, const string& errMsg, LCMessageItem* msgItem){};
    
#pragma mark - voice listener
    virtual void OnGetVoice(LCC_ERR_TYPE errType, const string& errNo, const string& errMsg, LCMessageItem* msgItem){};
    virtual void OnRecvVoice(LCMessageItem* msgItem){};
    virtual void OnSendVoice(LCC_ERR_TYPE errType, const string& errNo, const string& errMsg, LCMessageItem* msgItem){};
    
#pragma mark - photo listener
    virtual void OnGetPhoto(GETPHOTO_PHOTOSIZE_TYPE sizeType, LCC_ERR_TYPE errType, const string& errNo, const string& errMsg, const LCMessageList& msgList)
    {
        if (nil != gManager) {
            [gManager onGetPhoto:errType errNo:errNo errMsg:errMsg msgList:msgList sizeType:sizeType];
        }
    };
    
    virtual void OnPhotoFee(bool success, const string& errNo, const string& errMsg, LCMessageItem* msgItem)
    {
        if (nil != gManager) {
            [gManager onPhotoFee:success errNo:errNo errMsg:errMsg msgItem:msgItem];
        }
    };
    
    virtual void OnRecvPhoto(LCMessageItem* msgItem)
    {
        if (nil != gManager) {
            [gManager onRecvPhoto:msgItem];
        }
    };
    
    virtual void OnSendPhoto(LCC_ERR_TYPE errType, const string& errNo, const string& errMsg, LCMessageItem* msgItem)
    {
        if (nil != gManager) {
            [gManager onSendPhoto:errType errNo:errNo errMsg:errMsg msgItem:msgItem];
        }
    };
    
#pragma mark - video listener
    virtual void OnGetVideo(LCC_ERR_TYPE errType,
                            const string& userId,
                            const string& videoId,
                            const string& inviteId,
                            const string& videoPath,
                            const LCMessageList& msgList){};
    
    virtual void OnGetVideoPhoto( LCC_ERR_TYPE errType,
                                 const string& errNo,
                                 const string& errMsg,
                                 const string& userId,
                                 const string& inviteId,
                                 const string& videoId,
                                 VIDEO_PHOTO_TYPE,
                                 const string& filePath,
                                 const LCMessageList& msgList){};
    virtual void OnRecvVideo(LCMessageItem* msgItem){};
    virtual void OnVideoFee(bool success, const string& errNo, const string& errMsg, LCMessageItem* msgItem){};
};
static LiveChatManManagerListener *gLiveChatManManagerListener;

@implementation LiveChatManager
#pragma mark - 获取实例
+ (instancetype)manager
{
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (instancetype)init
{
    if(self = [super init] ) {
        self.delegates = [NSMutableArray array];
        
        self.loginManager = [LoginManager manager];
        [self.loginManager addDelegate:self];
        
        self.versionCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Version"];
        
        mILiveChatManManager = NULL;
        gLiveChatManManagerListener = new LiveChatManManagerListener();
    }
    
    return self;
}

/**
 *  添加委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)addDelegate:(id<LiveChatManagerDelegate>)delegate
{
    BOOL result = NO;
    
    @synchronized(self.delegates)
    {
        // 查找是否已存在
        for(NSValue* value in self.delegates) {
            id<LiveChatManagerDelegate> item = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( item == delegate ) {
                NSLog(@"LiveChatManager::addDelegate() add again, delegate:<%@>", delegate);
                result = YES;
                break;
            }
        }
        
        // 未存在则添加
        if (!result) {
            [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
            result = YES;
        }
    }
    
    return result;
}

/**
 *  移除委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)removeDelegate:(id<LiveChatManagerDelegate>)delegate
{
    BOOL result = NO;
    
    @synchronized(self.delegates)
    {
        for(NSValue* value in self.delegates) {
            id<LiveChatManagerDelegate> item = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( item == delegate ) {
                [self.delegates removeObject:value];
                result = YES;
                break;
            }
        }

    }
    
    // log
    if (!result) {
        NSLog(@"LiveChatManager::removeDelegate() fail, delegate:<%@>", delegate);
    }
    
    return result;
}

#pragma mark - 初始化/登录/注销
/**
 *  LoginManager登录回调处理
 *
 *  @param manager   LoginManager
 *  @param success   是否成功
 *  @param loginItem 登录item
 *  @param errnum    登录结果code
 *  @param errmsg    登录结果描述
 */
- (void)manager:(LoginManager *)manager onLogin:(BOOL)success loginItem:(LoginItemObject *)loginItem errnum:(NSString *)errnum errmsg:(NSString *)errmsg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveChatManager::onLogin( success : %d )", success);
        if (success) {
            // 获取缓存目录
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
            NSString *cachesDirectory = [paths objectAtIndex:0];
            
            // 登录livechat
            [[ServerManager manager] checkServer:loginItem.manid finishHandler:^(BOOL success, CheckServerItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
                if( success && !item.fake ) {
                    // 真的服务器
                    OTHER_SITE_TYPE siteType = AppDelegate().siteType;
                    [self loginUser:loginItem.manid sid:loginItem.sessionid siteType:siteType path:cachesDirectory receVideoMsg:loginItem.videoreceived];
                } else {
                    // 假的服务器, 默认cl
                    [self loginUser:loginItem.manid sid:loginItem.sessionid siteType:OTHER_SITE_CL path:cachesDirectory receVideoMsg:loginItem.videoreceived];
                }
            }];

        }
    });
}

- (void)manager:(LoginManager * _Nonnull)manager onLogout:(BOOL)kick {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveChatManager::onLogout( kick : %d )", kick);
        bool isResetParam = kick ? true : false;
        [self logoutUser:isResetParam];
    });
}

/**
 *  初始化配置
 *
 *  @param siteType     站点
 *  @param httpUser     用户
 *  @param httpPassword sid
 *  @param path         目录缓存路径必须是可读写的路径
 *  @param listener
 *
 *  @return 初始化是否成功
 */
- (BOOL)initCommonSiteType:(OTHER_SITE_TYPE)siteType
                  httpUser:(NSString *)httpUser
              httpPassword:(NSString *)httpPassword
                      path:(NSString *)path
                  listener:(ILiveChatManManagerListener *)listener
{
    
    self.requestManager = [RequestManager manager];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString  *versionCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Version"];
    
    __block BOOL bFlag = YES;
    __block BOOL result = YES;
    if (httpUser && httpUser.length > 0 && httpPassword && httpPassword.length > 0) {
        bFlag = [[ConfigManager manager] synConfig:^(BOOL success, SynConfigItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg){
            if (success) {
                switch (siteType) {
                    case OTHER_SITE_CL:{
                        list<string> ipItemList;
                        ipItemList.push_back([item.cl.host UTF8String]);
                        result = mILiveChatManManager->Init(ipItemList, (int)item.cl.port, OTHER_SITE_CL, [self.requestManager.getWebSite UTF8String], [self.requestManager.getAppSite UTF8String], [item.pub.chatVoiceHostUrl UTF8String], [httpUser UTF8String], [httpPassword UTF8String], [versionCode UTF8String], [cachesDirectory UTF8String], item.cl.minChat, listener);
                    }break;
                    case OTHER_SITE_IDA:{
                        list<string> ipItemList;
                        ipItemList.push_back([item.ida.host UTF8String]);
                        result = mILiveChatManManager->Init(ipItemList, (int)item.ida.port, OTHER_SITE_IDA,[self.requestManager.getWebSite UTF8String], [self.requestManager.getAppSite UTF8String], [item.pub.chatVoiceHostUrl UTF8String], [httpUser UTF8String], [httpPassword UTF8String], [versionCode UTF8String], [path UTF8String], item.ida.minChat, listener);
                        
                    }break;
                    case OTHER_SITE_CD:{
                        list<string> ipItemList;
                        ipItemList.push_back([item.ch.host UTF8String]);
                        result = mILiveChatManManager->Init(ipItemList, (int)item.ch.port, OTHER_SITE_CD, [self.requestManager.getWebSite UTF8String], [self.requestManager.getAppSite UTF8String], [item.pub.chatVoiceHostUrl UTF8String], [httpUser UTF8String], [httpPassword UTF8String], [versionCode UTF8String], [path UTF8String], item.ch.minChat, listener);
                        
                    }break;
                    case OTHER_SITE_LA:{
                        list<string> ipItemList;
                        ipItemList.push_back([item.la.host UTF8String]);
                        result = mILiveChatManManager->Init(ipItemList, (int)item.la.port, OTHER_SITE_LA, [self.requestManager.getWebSite UTF8String], [self.requestManager.getAppSite UTF8String], [item.pub.chatVoiceHostUrl UTF8String], [httpUser UTF8String], [httpPassword UTF8String], [versionCode UTF8String], [path UTF8String], item.la.minChat, listener);
                        
                    }break;
                    default:
                        break;
                        
                }
            }
            
        }];
        
    }
    
    return result;
}

/**
 *  登录（并创建LiveChatManManager）
 *
 *  @param user           用户
 *  @param userSid        用户sid
 *  @param type           站点类型
 *  @param path           目录缓存路径
 *  @param isRecvVideoMsg 是否收video
 *
 *  @return 是否登录成功
 */
- (BOOL)loginUser:(NSString *)user
              sid:(NSString *)userSid
         siteType:(OTHER_SITE_TYPE)type
             path:(NSString *)path
     receVideoMsg:(bool)isRecvVideoMsg
{
    BOOL result = NO;
    
    // 创建LiveChatManManager
    if (NULL == mILiveChatManManager) {
        mILiveChatManManager = ILiveChatManManager::Create();
        if (NULL != mILiveChatManManager) {
            result = [self initCommonSiteType:type httpUser:@"test" httpPassword:@"5179" path:path listener:gLiveChatManManagerListener];
        }
    }
    else {
        if (mILiveChatManManager->IsLogin()) {
            mILiveChatManManager->Logout(false);
        }
        result = YES;
    }
    
    // 初始化并登录
    result = result && mILiveChatManManager->Login([user UTF8String], [userSid UTF8String], CLIENT_IPHONE, HttpClient::GetCookiesInfo(), [[UIDevice currentDevice].identifierForVendor.UUIDString UTF8String], isRecvVideoMsg);

    return result;
}

/**
 *  登录回调
 *
 *  @param errType     结果类型
 *  @param errMsg      结果描述
 *  @param isAutoLogin 是否将会自动登录
 */
- (void)onLoginUser:(LCC_ERR_TYPE)errType
             errMsg:(const char* _Nonnull)errMsg
        isAutoLogin:(bool)isAutoLogin
{
    NSString* nssErrMsg = [NSString stringWithUTF8String:errMsg];
    BOOL bIsAutoLogin = isAutoLogin ? YES : NO;
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(OnLogin:errMsg:isAutoLogin:)] ) {
                [delegate OnLogin:errType errMsg:nssErrMsg isAutoLogin:bIsAutoLogin];
            }
        }
    }
}

/**
 *  注销（并释放LiveChatManManager）
 */
- (void)logoutUser:(BOOL)isResetParam
{
    if (NULL != mILiveChatManManager) {
        mILiveChatManManager->Logout(isResetParam ? true : false);
        if (isResetParam) {
            ILiveChatManManager::Release(mILiveChatManManager);
            mILiveChatManManager = NULL;
        }
    }
}

/**
 *  注销回调
 *
 *  @param errType     结果类型
 *  @param errMsg      结果描述
 *  @param isAutoLogin 是否将会自动登录
 */
- (void)onLogoutUser:(LCC_ERR_TYPE)errType
              errMsg:(const char* _Nonnull)errMsg
         isAutoLogin:(bool)isAutoLogin
{
    NSString* nssErrMsg = [NSString stringWithUTF8String:errMsg];
    BOOL bIsAutoLogin = isAutoLogin ? YES : NO;
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(OnLogout:errmsg:isAutoLogin:)] ) {
                [delegate OnLogout:errType errmsg:nssErrMsg isAutoLogin:bIsAutoLogin];
            }
        }
    }
}

#pragma mark - 在线状态
/**
 *  获取登录状态
 *
 *  @return 是否正在登录（YES：正在登录，否则为未登录状态）
 */
- (BOOL)isLogin
{
    BOOL result = NO;
    if (NULL != mILiveChatManManager) {
        result = mILiveChatManManager->IsLogin() ? YES : NO;
    }
    return result;
}

/**
 *  获取指定用户在线状态
 *
 *  @param userIds 用户ID数组
 *
 *  @return 操作是否成功
 */
- (BOOL)getUserStatus:(NSArray<NSString*>* _Nonnull)userIds
{
    BOOL result = NO;
    if (NULL != mILiveChatManManager)
    {
        list<string> userIdsList = [LiveChatItem2OCObj getStringList:userIds];
        result = mILiveChatManManager->GetUserStatus(userIdsList) ? YES : NO;
    }
    return result;
}

/**
 *  获取指定用户在线状态回调
 *
 *  @param errType  结果类型
 *  @param errMsg   结果描述
 *  @param userList 用户list
 */
- (void)onGetUserStatus:(LCC_ERR_TYPE)errType errMsg:(const char* _Nonnull)errMsg userList:(const LCUserList&)userList
{
    NSString* nssErrMsg = [NSString stringWithUTF8String:errMsg];
    NSArray<LiveChatUserItemObject*>* users = [LiveChatItem2OCObj getLiveChatUserArray:userList];
    @synchronized (self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onGetUserStatus:errMsg:users:)] ) {
                [delegate onGetUserStatus:errType errMsg:nssErrMsg users:users];
            }
        }
    }
}

/**
 
 *  接收被踢下线通知回调
 *
 *  @param kickType 被踢下线类型
 */
- (void)onRecvKickOffline:(KICK_OFFLINE_TYPE)kickType
{
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvKickOffline:)] ) {
                [delegate onRecvKickOffline:kickType];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self logoutUser:true];
    });
}

/**
 *  在线状态改变通知回调
 *
 *  @param user 用户
 */
- (void)onChangeOnlineStatus:(const LCUserItem* _Nonnull)userItem
{
    LiveChatUserItemObject* userObj = [LiveChatItem2OCObj getLiveChatUserItemObject:userItem];
    if (nil != userObj)
    {
        @synchronized(self.delegates)
        {
            for (NSValue* value in self.delegates)
            {
                id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
                if( [delegate respondsToSelector:@selector(onChangeOnlineStatus:)] ) {
                    [delegate onChangeOnlineStatus:userObj];
                }
            }
        }
    }
}

#pragma mark - 获取用户信息
/**
 *  获取用户信息
 *
 *  @param userId 用户ID
 *
 *  @return 操作是否成功
 */
- (BOOL)getUserInfo:(NSString* _Nonnull)userId
{
    BOOL result = NO;
    if (NULL != mILiveChatManManager) {
        const char* pUserId = [userId UTF8String];
        result = mILiveChatManManager->GetUserInfo(pUserId) ? YES : NO;
    }
    return result;
}

/**
 *  获取用户信息回调
 *
 *  @param errType  结果类型
 *  @param errMsg   结果描述
 *  @param userId   用户ID
 *  @param userInfo 用户信息
 */
- (void)onGetUserInfo:(LCC_ERR_TYPE)errType errMsg:(const char* _Nonnull)errMsg userId:(const char* _Nonnull)userId userInfo:(const UserInfoItem&)userInfo
{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errMsg];
    NSString* nsUserId = [NSString stringWithUTF8String:userId];
    LiveChatUserInfoItemObject* userInfoObject = [LiveChatItem2OCObj getLiveChatUserInfoItemObjecgt:userInfo];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onGetUserInfo:errMsg:userId:userInfo:)] ) {
                [delegate onGetUserInfo:errType errMsg:nsErrMsg userId:nsUserId userInfo:userInfoObject];
            }
        }
    }
}

/**
 *  获取多个用户信息
 *
 *  @param userIds 用户ID数组
 *
 *  @return 操作是否成功
 */
- (BOOL)getUsersInfo:(NSArray<NSString*>* _Nonnull)userIds
{
    BOOL result = NO;
    if (NULL != mILiveChatManManager) {
        list<string> userIdList = [LiveChatItem2OCObj getStringList:userIds];
        result = mILiveChatManManager->GetUsersInfo(userIdList) ? YES : NO;
    }
    return result;
}

/**
 *  获取多个用户信息回调
 *
 *  @param errType      结果类型
 *  @param errMsg       结果描述
 *  @param userInfoList 用户信息列表
 */
- (void)onGetUsersInfo:(LCC_ERR_TYPE)errType errMsg:(const char* _Nonnull)errMsg userInfoList:(const UserInfoList&)userInfoList
{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errMsg];
    NSArray<LiveChatUserItemObject*>* usersInfo = [LiveChatItem2OCObj getLiveChatUserInfoArray:userInfoList];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onGetUsersInfo:errMsg:usersInfo:)] ) {
                [delegate onGetUsersInfo:errType errMsg:nsErrMsg usersInfo:usersInfo];
            }
        }
    }
}

#pragma mark - 聊天状态回调
/**
 *  获取在聊列表回调
 *
 *  @param errType 结果类型
 *  @param errMsg  结果描述
 */
- (void)onGetTalkList:(LCC_ERR_TYPE)errType errMsg:(const char* _Nonnull)errMsg
{
    NSString* nssErrMsg = [NSString stringWithUTF8String:errMsg];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onGetTalkList:errMsg:)] ) {
                [delegate onGetTalkList:errType errMsg:nssErrMsg];
            }
        }
    }
}

/**
 *  接收聊天状态改变通知回调
 *
 *  @param user 用户
 */
- (void)onRecvTalkEvent:(const LCUserItem* _Nonnull)userItem
{
    LiveChatUserItemObject* user = [LiveChatItem2OCObj getLiveChatUserItemObject:userItem];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvTalkEvent:)] ) {
                [delegate onRecvTalkEvent:user];
            }
        }
    }
}

#pragma mark - notice
/**
 *  接收Admirer/EMF通知回调
 *
 *  @param userId     用户ID
 *  @param noticeType 通知类型
 */
- (void)onRecvEMFNotice:(const char* _Nonnull)userId noticeType:(TALK_EMF_NOTICE_TYPE)noticeType
{
    NSString* nssUserId = [NSString stringWithUTF8String:userId];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvEMFNotice:noticeType:)] ) {
                [delegate onRecvEMFNotice:nssUserId noticeType:noticeType];
            }
        }
    }
}

#pragma mark - 试聊券
/**
 *  检测是否可使用试聊券
 *
 *  @param userId 用户ID
 *
 *  @return 操作是否成功
 */
- (BOOL)checkTryTicket:(NSString* _Nonnull)userId
{
    BOOL result = NO;
    if (NULL != mILiveChatManManager)
    {
        const char* pUserId = [userId UTF8String];
        result = mILiveChatManManager->CheckCoupon(pUserId) ? YES : NO;
    }
    return result;
}

/**
 *  检测是否可使用试聊券回调
 *
 *  @param success 检测操作成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param userId  用户ID
 *  @param status  检测结果
 */
- (void)onCheckTryTicket:(bool)success
                   errNo:(const char* _Nonnull)errNo
                  errMsg:(const char* _Nonnull)errMsg
                  userId:(const char* _Nonnull)userId
                  status:(CouponStatus)status
{
    BOOL bSuccess = success ? YES : NO;
    NSString* nssErrNo = [NSString stringWithUTF8String:errNo];
    NSString* nssErrMsg = [NSString stringWithUTF8String:errMsg];
    NSString* nssUserId = [NSString stringWithUTF8String:userId];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onCheckTryTicket:errNo:errMsg:userId:status:)] ) {
                [delegate onCheckTryTicket:bSuccess errNo:nssErrNo errMsg:nssErrMsg userId:nssUserId status:status];
            }
        }
    }
}

/**
 *  使用试聊券回调
 *
 *  @param errType   结果类型
 *  @param errMsg    结果描述
 *  @param userId    用户ID
 *  @param tickEvent 试聊事件
 */
- (void)onUseTryTicket:(LCC_ERR_TYPE)errType
                errMsg:(const char* _Nonnull)errMsg
                userId:(const char* _Nonnull)userId
             tickEvent:(TRY_TICKET_EVENT)tickEvent
{
    NSString* nssErrMsg = [NSString stringWithUTF8String:errMsg];
    NSString* nssUserId = [NSString stringWithUTF8String:userId];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onUseTryTicket:errMsg:userId:tickEvent:)] ) {
                [delegate onUseTryTicket:errType errMsg:nssErrMsg userId:nssUserId tickEvent:tickEvent];
            }
        }
    }
}

/**
 *  开始试聊回调
 *
 *  @param user 用户
 *  @param time 试聊时长（秒）
 */
- (void)onRecvTryTalkBegin:(LCUserItem* _Nonnull)userItem
                      time:(int)time
{
    LiveChatUserItemObject* userObj = [LiveChatItem2OCObj getLiveChatUserItemObject:userItem];
    NSInteger nsiTime = time;
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvTryTalkBegin:time:)] ) {
                [delegate onRecvTryTalkBegin:userObj time:nsiTime];
            }
        }
    }
}

/**
 *  结束试聊回调
 *
 *  @param user 用户
 */
- (void)onRecvTryTalkEnd:(LCUserItem* _Nonnull)userItem
{
    LiveChatUserItemObject* userObj = [LiveChatItem2OCObj getLiveChatUserItemObject:userItem];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvTryTalkEnd:)] ) {
                [delegate onRecvTryTalkEnd:userObj];
            }
        }
    }
}

#pragma mark - 公共操作
/**
 *  获取指定用户聊天消息数组
 *
 *  @param userId 用户ID
 *
 *  @return 返回
 */
- (NSArray<LiveChatMsgItemObject*>* _Nonnull)getMsgsWithUser:(NSString* _Nonnull)userId
{
    NSMutableArray<LiveChatMsgItemObject*>* msgs = [NSMutableArray array];
    if (NULL != mILiveChatManManager)
    {
        const char* pUserId = [userId UTF8String];
        LCUserItem* userItem = mILiveChatManManager->GetUserWithId(pUserId);
        if (NULL != userItem)
        {
            for (list<LCMessageItem*>::iterator iter = userItem->m_msgList.begin();
                 iter != userItem->m_msgList.end();
                 iter++)
            {
                LCMessageItem* msgItem = (*iter);
                LiveChatMsgItemObject* obj = [LiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
                if (nil != obj) {
                    [msgs addObject:obj];
                }
            }
        }
    }
    return msgs;
}

/**
 *  获取用户
 *
 *  @param userId 用户ID
 *
 *  @return 用户
 */
- (LiveChatUserItemObject* _Nullable)getUserWithId:(NSString* _Nonnull)userId
{
    LiveChatUserItemObject* userObj = nil;
    if (NULL != mILiveChatManManager)
    {
        const char* pUserId = [userId UTF8String];
        LCUserItem* userItem = mILiveChatManManager->GetUserWithId(pUserId);
        userObj = [LiveChatItem2OCObj getLiveChatUserItemObject:userItem];
    }
    return userObj;
}

/**
 *  获取邀请用户数组
 *
 *  @return 用户数组
 */
- (NSArray<LiveChatUserItemObject*>* _Nonnull)getInviteUsers
{
    NSArray<LiveChatUserItemObject*>* users = [NSArray array];
    if (NULL != mILiveChatManManager)
    {
        LCUserList userList = mILiveChatManManager->GetInviteUsers();
        users = [LiveChatItem2OCObj getLiveChatUserArray:userList];
    }
    
    return users;
}

/**
 *  获取在聊用户数组
 *
 *  @return 用户数组
 */
- (NSArray<LiveChatUserItemObject*>* _Nonnull)getChatingUsers
{
    NSArray<LiveChatUserItemObject*>* users = [NSArray array];
    if (NULL != mILiveChatManManager)
    {
        LCUserList userList = mILiveChatManManager->GetChatingUsers();
        users = [LiveChatItem2OCObj getLiveChatUserArray:userList];
    }
    return users;
}

#pragma mark - 普通消息处理（文本/历史聊天消息等）
/**
 *  发送文本消息
 *
 *  @param userId 用户ID
 *  @param text   文本消息内容
 *
 *  @return 消息
 */
- (LiveChatMsgItemObject* _Nullable)sendTextMsg:(NSString* _Nonnull)userId text:(NSString* _Nonnull)text
{
    LiveChatMsgItemObject* msgObj = nil;
    if (NULL != mILiveChatManManager)
    {
        const char* pUserId = [userId UTF8String];
        const char* pText = [text UTF8String];
        LCMessageItem* msgItem = mILiveChatManManager->SendTextMessage(pUserId, pText);
        if (NULL != msgItem) {
            msgObj = [LiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
        }
    }
    return msgObj;
}

/**
 *  发送文本消息回调
 *
 *  @param errType 结果类型
 *  @param errMsg  结果描述
 *  @param msgItem 消息item
 */
- (void)onSendTextMsg:(LCC_ERR_TYPE)errType errMsg:(const char* _Nonnull)errMsg msgItem:(LCMessageItem* _Nullable)msgItem
{
    NSString* nssErrMsg = [NSString stringWithUTF8String:errMsg];
    LiveChatMsgItemObject* msgObj = [LiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onSendTextMsg:errMsg:msgItem:)] ) {
                [delegate onSendTextMsg:errType errMsg:nssErrMsg msgItem:msgObj];
            }
        }
    }
}

/**
 *  发送消息失败回调（多条）
 *
 *  @param errType 结果类型
 *  @param msgList 消息列表
 */
- (void)onSendTextMsgsFail:(LCC_ERR_TYPE)errType msgList:(const LCMessageList&)msgList
{
    NSArray<LiveChatMsgItemObject*>* msgs = [LiveChatItem2OCObj getLiveChatMsgArray:msgList];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onSendTextMsgsFail:msgs:)] ) {
                [delegate onSendTextMsgsFail:errType msgs:msgs];
            }
        }
    }
}

/**
 *  接收文本消息回调
 *
 *  @param msg 消息
 */
- (void)onRecvTextMsg:(LCMessageItem* _Nonnull)msgItem
{
    LiveChatMsgItemObject* msgObj = [LiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvTextMsg:)] ) {
                [delegate onRecvTextMsg:msgObj];
            }
        }
    }
}

/**
 *  接收系统消息回调
 *
 *  @param msg 消息
 */
- (void)onRecvSystemMsg:(LCMessageItem* _Nonnull)msgItem
{
    LiveChatMsgItemObject* msgObj = [LiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvSystemMsg:)] ) {
                [delegate onRecvSystemMsg:msgObj];
            }
        }
    }
}

/**
 *  接收警告消息回调
 *
 *  @param msg 消息
 */
- (void)onRecvWarningMsg:(LCMessageItem* _Nonnull)msgItem
{
    LiveChatMsgItemObject* msgObj = [LiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvWarningMsg:)] ) {
                [delegate onRecvWarningMsg:msgObj];
            }
        }
    }
}

/**
 *  接收对方编辑消息回调
 *
 *  @param userId 用户ID
 */
- (void)onRecvEditMsg:(const char* _Nonnull)userId
{
    NSString* nssUserId = [NSString stringWithUTF8String:userId];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvEditMsg:)] ) {
                [delegate onRecvEditMsg:nssUserId];
            }
        }
    }
}

/**
 *  获取单个用户历史聊天记录回调（包括文本、高级表情、语音、图片）
 *
 *  @param success  操作是否成功
 *  @param errNo    结果类型
 *  @param errMsg   结果描述
 *  @param userItem 用户
 */
- (void)onGetHistoryMessage:(bool)success errNo:(const string&)errNo errMsg:(const string&) errMsg userItem:(LCUserItem* _Nonnull)userItem
{
    NSString* nsUserId = [NSString stringWithUTF8String:userItem->m_userId.c_str()];
    NSString* nsErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString* nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onGetHistoryMessage:errNo:errMsg:userId:)] ) {
                [delegate onGetHistoryMessage:success errNo:nsErrNo errMsg:nsErrMsg userId:nsUserId];
            }
        }
    }
}

/**
 *  获取多个用户历史聊天记录回调（包括文本、高级表情、语音、图片）
 *
 *  @param success  操作是否成功
 *  @param errNo    结果类型
 *  @param errMsg   结果描述
 *  @param userList 用户数组
 */
- (void)onGetUsersHistoryMessage:(bool)success errNo:(const string&)errNo errMsg:(const string&) errMsg userList:(const LCUserList&)userList
{
    NSArray<NSString*>* nsUserIds = [LiveChatItem2OCObj getLiveChatUserIdArray:userList];
    NSString* nsErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString* nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onGetUsersHistoryMessage:errNo:errMsg:userIds:)] ) {
                [delegate onGetUsersHistoryMessage:success errNo:nsErrNo errMsg:nsErrMsg userIds:nsUserIds];
            }
        }
    }
}

/**
 *  获取消息处理状态
 *
 *  @param userId 用户ID
 *  @param msgId  消息ID
 *
 *  @return 消息处理状态
 */
- (LCMessageItem::StatusType)getMsgStatus:(NSString* _Nonnull)userId msgId:(NSInteger)msgId
{
    LCMessageItem::StatusType statusType = LCMessageItem::StatusType_Fail;
    if (NULL != mILiveChatManManager)
    {
        const char* pUserId = [userId UTF8String];
        int iMsgId = (int)msgId;
        statusType = mILiveChatManManager->GetMessageItemStatus(pUserId, iMsgId);
    }
    return statusType;
}

/**
 *  插入历史消息记录
 *
 *  @param userId 用户ID
 *  @param msg    消息
 *
 *  @return 消息ID
 */
- (NSInteger)insertHistoryMessage:(NSString* _Nonnull)userId msg:(LiveChatMsgItemObject* _Nonnull)msg
{
    NSInteger msgId = -1;
    if (NULL != mILiveChatManManager)
    {
        const char* pUserId = [userId UTF8String];
        LCMessageItem* msgItem = [LiveChatItem2OCObj getLiveChatMsgItem:msg];
        if (mILiveChatManManager->InsertHistoryMessage(pUserId, msgItem))
        {
            msgId = msgItem->m_msgId;
        }
    }
    return msgId;
}

/**
 *  删除历史消息记录(一般用于重发消息)
 *
 *  @param userId 用户ID
 *  @param msgId  消息ID
 *
 *  @return 处理结果
 */
- (BOOL)removeHistoryMessage:(NSString* _Nonnull)userId msgId:(NSInteger)msgId
{
    BOOL result = NO;
    if (NULL != mILiveChatManManager)
    {
        const char* pUserId = [userId UTF8String];
        int iMsgId = (int)msgId;
        result = mILiveChatManManager->RemoveHistoryMessage(pUserId, iMsgId);
    }
    return result;
}

/**
 *  获取用户最后一条聊天消息
 *
 *  @param userId 用户ID
 *
 *  @return 最后一条聊天消息
 */
- (LiveChatMsgItemObject* _Nullable)getLastMsg:(NSString* _Nonnull)userId
{
    LiveChatMsgItemObject* object = nil;
    if (NULL != mILiveChatManManager)
    {
        const char* pUserId = [userId UTF8String];
        LCMessageItem* msgItem = mILiveChatManManager->GetLastMessage(pUserId);
        object = [LiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    }
    return object;
}

#pragma mark - 私密照消息处理


/**
 *  发送图片
 *
 *  @param userId    用户Id
 *  @param photoPath 私密照的路径
 *
 *  @return 私密照消息
 */
- (LiveChatMsgItemObject *)SendPhoto:(NSString *)userId PhotoPath:(NSString *)photoPath {
    LiveChatMsgItemObject* msgObj = nil;
    if (NULL != mILiveChatManManager)
    {
        const char* pUserId = [userId UTF8String];
        const char* pText = [photoPath UTF8String];
        LCMessageItem* msgItem = mILiveChatManManager->SendPhoto(pUserId, pText);
        if (NULL != msgItem) {
            msgObj = [LiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
        }
    }
    return msgObj;
}

/**
 *  购买图片
 *
 *  @param userId 用户Id
 *  @param msgId  私密照Id
 *
 *  @return 处理结果
 */
- (BOOL)PhotoFee:(NSString *)userId msgId:(int)msgId {
    
       BOOL result = NO;
    if (NULL != mILiveChatManManager)
    {
        const char* pUserId = [userId UTF8String];
        result = mILiveChatManManager->PhotoFee(pUserId, msgId);
    }
    
    return result;
}

/**
 *  根据消息ID获取图片(模糊或清晰)
 *
 *  @param userId   女士Id
 *  @param msgId    私密照Id
 *  @param sizeType 私密照大小类型
 *
 *  @return 处理结果
 */
- (BOOL)getPhoto:(NSString *)userId msgId:(int)msgId sizeType:(GETPHOTO_PHOTOSIZE_TYPE)sizeType{
    BOOL result = NO; 
    if (NULL != mILiveChatManManager)
    {
        const char* pUserId = [userId UTF8String];
        result = mILiveChatManManager->GetPhoto(pUserId, msgId, sizeType);
    }
    
    return result;
}





/**
 *  获取用户图片信息
 *
 *  @param errType 结果类型
 *  @param errNo   结果编号
 *  @param errMsg  结果描述
 *  @param msgItem 消息
 */
- (void)onGetPhoto:(LCC_ERR_TYPE)errType errNo:(const string&)errNo errMsg:(const string&)errMsg msgList:(const LCMessageList&)msgList sizeType:(GETPHOTO_PHOTOSIZE_TYPE)sizeType
{
    NSArray<LiveChatMsgItemObject*>* msgListObj = [LiveChatItem2OCObj getLiveChatMsgArray:msgList];
    NSString* nsErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString* nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onGetPhoto:errNo:errMsg:msgList:sizeType:)] ) {
                [delegate onGetPhoto:errType errNo:nsErrNo errMsg:nsErrMsg msgList:msgListObj sizeType:sizeType];
            }
        }
    }
}

/**
 *  获取收费的图片
 *
 *  @param success 操作是否成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param msgItem 消息
 */
- (void)onPhotoFee:(bool)success errNo:(const string&) errNo errMsg:(const string&) errMsg msgItem: (LCMessageItem*) msgItem {
    LiveChatMsgItemObject* msgObj = [LiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    NSString* nsErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString* nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onPhotoFee:errNo:errMsg:msgItem:)] ) {
                [delegate onPhotoFee:success errNo:nsErrNo errMsg:nsErrMsg msgItem:msgObj];
            }
        }
    }
}

/**
 *  获取图片
 *
 *  @param msgItem 消息
 */
- (void)onRecvPhoto:(LCMessageItem*) msgItem {
    LiveChatMsgItemObject* msgObj = [LiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    @synchronized (self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvPhoto:)]) {
                [delegate onRecvPhoto:msgObj];
            }
        }
    }
}

/**
 *  发送图片
 *
 *  @param errType 结果类型
 *  @param errNo   结果编码
 *  @param errMsg  结果描述
 *  @param msgItem 消息
 */
- (void)onSendPhoto:(LCC_ERR_TYPE) errType errNo:(const string&) errNo errMsg:(const string&) errMsg msgItem:(LCMessageItem*) msgItem {
    LiveChatMsgItemObject* msgObj = [LiveChatItem2OCObj getLiveChatMsgItemObject:msgItem];
    NSString* nsErrNo = [NSString stringWithUTF8String:errNo.c_str()];
    NSString* nsErrMsg = [NSString stringWithUTF8String:errMsg.c_str()];
    @synchronized(self.delegates)
    {
        for (NSValue* value in self.delegates)
        {
            id<LiveChatManagerDelegate> delegate = (id<LiveChatManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onSendPhoto:errNo:errMsg:msgItem:)] ) {
                [delegate onSendPhoto:errType errNo:nsErrNo errMsg:nsErrMsg msgItem:msgObj];
            }
        }
    }
}
@end

