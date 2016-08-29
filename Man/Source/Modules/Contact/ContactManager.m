//
//  ContactManager.m
//  dating
//
//  Created by lance on 16/4/21.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ContactManager.h"
#import "SessionRequest.h"
#import "GetRecentContactListRequest.h"
#import "RemoveContactListRequset.h"
#import "GetLadyDetailRequest.h"
#import "LiveChatManager.h"
#import "LoginManager.h"

static ContactManager* gManager = nil;
@interface ContactManager() <LiveChatManagerDelegate, LoginManagerDelegate>

/**
 *  请求管理器
 */
@property (nonatomic, strong) SessionRequestManager *sessionManager;

/**
 *  回调数组
 */
@property (nonatomic, strong) NSMutableArray* delegates;

/**
 *  recentItems数组
 */
@property (nonatomic, strong) NSMutableArray* recentItems;

/**
 *  Livechat管理器
 */
@property (nonatomic, strong) LiveChatManager *liveChatManager;

/**
 *  Login管理器
 */
@property (nonatomic, strong) LoginManager *loginManager;

/**
 *  在线状态刷新定时器
 */
@property (nonatomic, strong) NSTimer* statusTimer;

/**
 *  是否请求过接口
 */
@property (nonatomic, assign) BOOL bRequest;

/**
 *  根据用户ID获取联系人列表中的联系人
 *
 *  @param userId 用户ID
 *
 *  @return 联系人
 */
- (LadyRecentContactObject* _Nullable)getRecentWithId:(NSString* _Nonnull)userId;

/**
 *  更新联系人数据
 *
 *  @param des 被更新Object
 *  @param src 源Object
 */
- (void)updateRecentInfo:(LadyRecentContactObject* _Nonnull)des src:(LadyRecentContactObject* _Nonnull)src;

/**
 *  合并请求回来的联系人
 *
 *  @param recents 联系人数组
 */
- (void)combineRecentWithRequest:(NSArray<LadyRecentContactObject*>* _Nonnull)recents;

/**
 *  对联系人数组排序
 */
- (void)sortRecents;

/**
 *  联系人状态改变回调
 */
- (void)onChangeRecentContactStatusCallback;

/**
 *  获取联系人用户信息
 *
 *  @param recents 联系人数组
 */
- (void)getRecentContactUserInfo:(NSArray<LadyRecentContactObject*>* _Nonnull)recents;

/**
 *  定时获取联系人在线状态
 *
 *  @param timer timer
 */
- (void)getOnlineStatus:(id)timer;

/**
 *  分批获取联系人在线状态
 *
 *  @param recents 联系人数组
 */
- (void)getOnlineStatusWithBatch:(NSArray<LadyRecentContactObject*>* _Nonnull)recents;

@end
@implementation ContactManager

#pragma mark - 获取实例
+ (instancetype)manager {
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.bRequest = NO;
        
        self.delegates = [NSMutableArray array];
        self.recentItems = [NSMutableArray array];
        
        self.sessionManager = [SessionRequestManager manager];
        
        self.liveChatManager = [LiveChatManager manager];
        [self.liveChatManager addDelegate:self];
        
        self.loginManager = [LoginManager manager];
        [self.loginManager addDelegate:self];
        
        self.statusTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(getOnlineStatus:) userInfo:nil repeats:YES];
        [self.statusTimer fire];
    }
    return self;
}

- (void)addDelegate:(id<ContactManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)removeDelegate:(id<ContactManagerDelegate>)delegate{
    @synchronized(self.delegates) {
        for(NSValue* value in self.delegates) {
            id<ContactManagerDelegate> item = (id<ContactManagerDelegate>)value.nonretainedObjectValue;
            if( item == delegate ) {
                [self.delegates removeObject:value];
                break;
            }
        }
    
    }
}
#pragma mark - 在线状态刷新定时器回调
- (void)getOnlineStatus:(id)timer {
//    NSLog(@"ContactManager::getOnlineStatus( 定时获取服务器联系人在线状态 )");
    @synchronized (self.recentItems) {
        [self getOnlineStatusWithBatch:self.recentItems];
    }

}

/**
 *  分批获取联系人在线状态
 *
 *  @param recents 联系人数组
 */
- (void)getOnlineStatusWithBatch:(NSArray<LadyRecentContactObject*>* _Nonnull)recents
{
    // 定义每批获取的数量
    const NSInteger setp = 20;
    NSRange range = NSMakeRange(0, setp);
    
    // 分批获取联系人用户在线状态
    while (range.location < [recents count]) {
        if (range.location + setp < [recents count]) {
            range.length = setp;
        }
        else {
            range.length = [recents count] - range.location;
        }
        
        // 获取本批联系人的用户ID数组
        NSArray<LadyRecentContactObject*>* recentContacts = [recents subarrayWithRange:range];
        NSMutableArray<NSString*>* userIds = [NSMutableArray array];
        for (LadyRecentContactObject* object in recentContacts) {
            [userIds addObject:object.womanId];
        }
        
        // 获取本批联系人用户在线状态
        [self.liveChatManager getUserStatus:userIds];
        
        range.location += range.length;
    }
}

#pragma mark - 获取最近联系人
- (BOOL)getRecentContact {
    if( self.bRequest ) {
        // 获取本地
        [self onGetRecentContact:YES errnum:@"" errmsg:@""];
        
    } else {
        // 获取服务器
        GetRecentContactListRequest *request = [[GetRecentContactListRequest alloc] init];
        request.finishHandler = ^(BOOL success, NSArray * _Nonnull items, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
            NSLog(@"ContactManager::getRecentContact( 获取服务器联系人列表完成, count : %ld )", (long)items.count);
            
            __block BOOL blockSuccess = success;
            __block NSString *blockErrnum = errnum;
            __block NSString *blockErrmsg = errmsg;
            
            if (success) {
                // 合并到本地
                [self combineRecentWithRequest:items];
                
                // 更新Chating状态
                [self updateChatingStatus];
                
                // 更新在线状态和头像
                [self getRecentContactUserInfo:items];
                
                self.bRequest = YES;
            }
            
            [self onGetRecentContact:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
        };
        
        return [self.sessionManager sendRequest:request];
    }
    
    return YES;
}

/**
 *  获取联系人用户信息
 *
 *  @param recents 联系人数组
 */
- (void)getRecentContactUserInfo:(NSArray<LadyRecentContactObject*>* _Nonnull)recents
{
    // 定义每批获取的数量
    const NSInteger setp = 20;
    NSRange range = NSMakeRange(0, setp);
    
    // 分批获取联系人用户信息
    while (range.location < [recents count]) {
        if (range.location + setp < [recents count]) {
            range.length = setp;
        }
        else {
            range.length = [recents count] - range.location;
        }
        
        // 获取本批联系人的用户ID数组
        NSArray<LadyRecentContactObject*>* recentContacts = [recents subarrayWithRange:range];
        NSMutableArray<NSString*>* userIds = [NSMutableArray array];
        for (LadyRecentContactObject* object in recentContacts) {
            [userIds addObject:object.womanId];
        }
        
        // 获取本批联系人用户信息
        [self.liveChatManager getUsersInfo:userIds];
        
        range.location += range.length;
    }
}

#pragma mark - 获取或添加本地联系人
- (LadyRecentContactObject* _Nonnull)getOrNewRecentWithId:(NSString* _Nonnull)womanId
{
    LadyRecentContactObject* item = [self getRecentWithId:womanId];
    if (nil == item) {
        item = [[LadyRecentContactObject alloc] init];
        item.womanId = womanId;
        @synchronized (self.recentItems) {
            [self.recentItems addObject:item];
        }
    }
    return item;
}

#pragma mark - LivechatManager回调
- (void)onChangeOnlineStatus:(LiveChatUserItemObject* _Nonnull)user {
//    NSLog(@"ContactManager::onChangeOnlineStatus( 在线状态改变通知回调 user : %@)", user.userId);
    BOOL isChange = NO;
    LadyRecentContactObject* theRecent = [self getRecentWithId:user.userId];
    if (nil != theRecent) {
        BOOL newIsOnline = (USTATUS_ONLINE == user.statusType);
        if (theRecent.isOnline != newIsOnline) {
            theRecent.isOnline = newIsOnline;
            isChange = YES;
        }
    }
    
    if (isChange) {
        // 进行排序
        [self sortRecents];
        // callback
        [self onChangeRecentContactStatusCallback];
    }
}

- (void)onRecvTalkEvent:(LiveChatUserItemObject* _Nonnull)user {
//    NSLog(@"ContactManager::onChangeOnlineStatus( 聊天状态改变通知回调 )");
    BOOL isChange = NO;
    LadyRecentContactObject* theRecent = [self getRecentWithId:user.userId];
    if (nil != theRecent) {
        BOOL newIsInChat = (LCUserItem::LC_CHATTYPE_IN_CHAT_CHARGE == user.chatType
                            || LCUserItem::LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET == user.chatType);
        if (theRecent.isInChat != newIsInChat) {
            theRecent.isInChat = newIsInChat;
            isChange = YES;
        }
    }
    
    if (isChange) {
        // 进行排序
        [self sortRecents];
        // callback
        [self onChangeRecentContactStatusCallback];
    }
}

- (void)onGetTalkList:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg {
//    NSLog(@"ContactManager::onGetTalkList( 获取在聊列表回调 )");
    [self updateChatingStatus];
}

- (void)onGetUserStatus:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg users:(NSArray<LiveChatUserItemObject*>* _Nonnull)users {
//        NSLog(@"ContactManager::onGetUserStatus( 获取指定用户在线状态回调 )");
    if( LCC_ERR_SUCCESS == errType ) {
        BOOL isChange = NO;
        for(LiveChatUserItemObject* user in users) {
            LadyRecentContactObject* theRecent = [self getRecentWithId:user.userId];
            if( theRecent != nil ) {
                theRecent.isOnline = (user.statusType == USTATUS_ONLINE);
                isChange = YES;
            }
        }
        
        if (isChange) {
            // 进行排序
            [self sortRecents];
            // callback
            [self onChangeRecentContactStatusCallback];
        }
    }
}

- (void)onGetUserInfo:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId userInfo:(LiveChatUserInfoItemObject* _Nullable)userInfo {
//        NSLog(@"ContactManager::onGetUserInfo( 获取用户信息回调 userId : %@, errType : %d )", userId, errType);
    if( LCC_ERR_SUCCESS == errType ) {
        BOOL isChange = NO;
        LadyRecentContactObject* theRecent = [self getRecentWithId:userId];
        if( theRecent != nil ) {
            theRecent.isOnline = (userInfo.status == USTATUS_ONLINE);
            theRecent.photoURL = userInfo.imgUrl;
            isChange = YES;
        }
        
        if (isChange) {
            // 进行排序
            [self sortRecents];
            // callback
            [self onChangeRecentContactStatusCallback];
        }
    }
}

- (void)onGetUsersInfo:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg usersInfo:(NSArray<LiveChatUserItemObject*>* _Nonnull)usersInfo
{
    if ( LCC_ERR_SUCCESS == errType) {
        BOOL isChange = NO;
        for ( LiveChatUserInfoItemObject* userInfo in usersInfo ) {
            LadyRecentContactObject* theRecent = [self getRecentWithId:userInfo.userId];
            if( theRecent != nil ) {
                theRecent.isOnline = (userInfo.status == USTATUS_ONLINE);
                theRecent.photoURL = userInfo.imgUrl;
                isChange = YES;
            }
        }
        
        if (isChange) {
            // 进行排序
            [self sortRecents];
            // callback
            [self onChangeRecentContactStatusCallback];
        }
    }
}

#pragma mark - 公共处理函数
- (void)updateChatingStatus
{
    BOOL isChange = NO;
    NSArray<LiveChatUserItemObject*>* array = [self.liveChatManager getChatingUsers];
    for(LiveChatUserItemObject* user in array) {
        LadyRecentContactObject* theRecent = [self getRecentWithId:user.userId];
        if (nil != theRecent) {
            BOOL newIsInChat = (LCUserItem::LC_CHATTYPE_IN_CHAT_CHARGE == user.chatType
                                || LCUserItem::LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET == user.chatType);
            if (theRecent.isInChat != newIsInChat) {
                theRecent.isInChat = newIsInChat;
                isChange = YES;
            }
        }
    }
    
    if (isChange) {
        // 进行排序
        [self sortRecents];
        // callback
        [self onChangeRecentContactStatusCallback];
    }
}

/**
 *  根据用户ID获取联系人列表中的联系人
 *
 *  @param userId 用户ID
 *
 *  @return 联系人
 */
- (LadyRecentContactObject* _Nullable)getRecentWithId:(NSString* _Nonnull)userId
{
    LadyRecentContactObject* object = nil;
    
    @synchronized(self.recentItems) {
        for (LadyRecentContactObject* recent in self.recentItems)
        {
            if ([recent.womanId isEqualToString:userId]) {
                object = recent;
            }
        }
    }
    return object;
}

/**
 *  更新联系人数据
 *
 *  @param des 被更新Object
 *  @param src 源Object
 */
- (void)updateRecentInfo:(LadyRecentContactObject* _Nonnull)des src:(LadyRecentContactObject* _Nonnull)src
{
    des.firstname = src.firstname;
    des.age = src.age;
    des.photoURL = src.photoURL;
    des.photoBigURL = src.photoBigURL;
    des.isFavorite = src.isFavorite;
    des.videoCount = src.videoCount;
    des.lasttime = src.lasttime;
    des.isOnline = src.isOnline;
    des.isInChat = src.isInChat;
    des.lastInviteMessage = src.lastInviteMessage;
}

/**
 *  合并请求回来的联系人
 *
 *  @param recents 联系人数组
 */
- (void)combineRecentWithRequest:(NSArray<LadyRecentContactObject*>* _Nonnull)recents
{
    for (LadyRecentContactObject* recent : recents)
    {
        // 不使用PHP接口获取的头像
        recent.photoURL = nil;
        recent.photoBigURL = nil;
        
        LadyRecentContactObject* theRecent = [self getRecentWithId:recent.womanId];
        if (nil != theRecent) {
            // 已存在，则更新数据
            [self updateRecentInfo:theRecent src:recent];
        }
        else {
            // 不存在，则添加到列表
            [self.recentItems addObject:recent];
        }
    }
}

/**
 *  联系人排序比较函数
 *
 *  @param obj1    联系人object1
 *  @param obj2    联系人object2
 *  @param context 参数
 *
 *  @return 排序结果
 */
NSInteger sortRecent(id _Nonnull obj1, id _Nonnull obj2, void* _Nullable context)
{
    NSComparisonResult result = NSOrderedSame;
    LadyRecentContactObject* recent1 = (LadyRecentContactObject*)obj1;
    LadyRecentContactObject* recent2 = (LadyRecentContactObject*)obj2;
    
    // 比较在线状态
    if (NSOrderedSame == result) {
        if (recent1.isOnline != recent2.isOnline) {
            result = (recent1.isOnline ? NSOrderedAscending : NSOrderedDescending);
        }
    }
    
    // 比较在聊状态
    if (NSOrderedSame == result) {
        if (recent1.isInChat != recent2.isInChat) {
            result = (recent1.isInChat ? NSOrderedAscending : NSOrderedDescending);
        }
    }
    
    // 比较最后一条聊天消息时间
    if (NSOrderedSame == result) {
        if (recent1.lasttime != recent2.lasttime) {
            result = (recent1.lasttime > recent2.lasttime ? NSOrderedAscending : NSOrderedDescending);
        }
    }
    
    // 比较favorite
    if (NSOrderedSame == result) {
        if (recent1.isFavorite != recent2.isFavorite) {
            result = (recent1.isFavorite ? NSOrderedAscending : NSOrderedDescending);
        }
    }
    
    // 比较用户firstname
    if (NSOrderedSame == result) {
        if (![recent1.firstname isEqualToString:recent2.firstname]) {
            result = [recent1.firstname compare:recent2.firstname];
        }
    }
    
    return result;
}

/**
 *  对联系人数组排序
 */
- (void)sortRecents
{
    @synchronized (self.recentItems) {
        [self.recentItems sortUsingFunction:sortRecent context:nil];
    }
}

/**
 *  联系人状态改变回调
 */
- (void)onChangeRecentContactStatusCallback
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self.delegates) {
            for(NSValue* value in self.delegates) {
                id<ContactManagerDelegate> delegate = (id<ContactManagerDelegate>)value.nonretainedObjectValue;
                if( delegate && [delegate respondsToSelector:@selector(onChangeRecentContactStatus:)] ) {
                    [delegate onChangeRecentContactStatus:self];
                }
            }
        }
    });
}

- (void)onGetRecentContact:(BOOL)success errnum:(NSString *)errnum errmsg:(NSString *)errmsg {
    // 主线程回调
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self.delegates) {
            for(NSValue* value in self.delegates) {
                id<ContactManagerDelegate> delegate = (id<ContactManagerDelegate>)value.nonretainedObjectValue;
                if( [delegate respondsToSelector:@selector(manager:onGetRecentContact:items:errnum:errmsg:)] ) {
                    [delegate manager:self onGetRecentContact:success items:[self.recentItems mutableCopy] errnum:errnum errmsg:errmsg];
                }
            }
        }
    });
}

/**
 *  更新联系人列表
 */
- (void)updateRecents
{
    // 进行排序
    [self sortRecents];
    // callback
    [self onChangeRecentContactStatusCallback];
}

/**
 *  更新联系人最后联系时间
 *
 *  @param recent 联系人object
 */
+ (void)updateLasttime:(LadyRecentContactObject* _Nonnull)recent
{
    NSDate* nowDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timestamp = nowDate.timeIntervalSince1970;
    recent.lasttime = (NSInteger)timestamp;
}

- (BOOL)isInChatUser:(NSString* )userId {
    BOOL bFlag = NO;
    @synchronized (self.recentItems) {
        for (LadyRecentContactObject* recent in self.recentItems) {
            if ([recent.womanId isEqualToString:userId]) {
                bFlag = recent.isInChat;
                break;
            }
        }
    }
    return bFlag;
}

#pragma mark - 登陆管理器回调 (LoginManagerDelegate)
- (void)manager:(LoginManager * _Nonnull)manager onLogin:(BOOL)success loginItem:(LoginItemObject * _Nullable)loginItem errnum:(NSString * _Nonnull)errnum errmsg:(NSString * _Nonnull)errmsg {
    NSLog(@"ContactManager::onLogin( 登陆管理器回调登录 success : %d )", success);
    dispatch_async(dispatch_get_main_queue(), ^{
        if( success ) {
            // 登录成功获取最近联系人
            [self getRecentContact];
        }
    });
}

- (void)manager:(LoginManager * _Nonnull)manager onLogout:(BOOL)kick {
    NSLog(@"ContactManager::onLogout( 登陆管理器回调注销 kick : %d )", kick);
    
    if( kick ) {
        @synchronized(self.recentItems) {
            [self.recentItems removeAllObjects];
        }
        self.bRequest = NO;
        
        [self onGetRecentContact:YES errnum:@"" errmsg:@""];
    }
    
}

@end
