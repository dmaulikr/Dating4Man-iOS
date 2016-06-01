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

static ContactManager* gManager = nil;
@interface ContactManager() <LiveChatManagerDelegate>

@property (nonatomic,strong)SessionRequestManager *sessionManager;

/**
 *  回调数组
 */
@property (nonatomic,strong) NSMutableArray* delegates;

/**
 *  recentItems数组
 */
@property (nonatomic,strong) NSMutableArray* recentItems;

/**
 *  Livechat管理器
 */
@property (nonatomic,strong) LiveChatManager *liveChatManager;

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
- (void)combineRecentWithRequest:(NSArray* _Nonnull)recents;

/**
 *  对联系人数组排序
 */
- (void)sortRecents;

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
        self.delegates = [NSMutableArray array];
        self.recentItems = [NSMutableArray array];
        
        self.sessionManager = [SessionRequestManager manager];
        self.liveChatManager = [LiveChatManager manager];
        
        [self.liveChatManager addDelegate:self];
    }
    return self;
}

- (void)addDelegate:(id<ContactManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        [self.delegates addObject:delegate];
    }
}


- (void)removeDelegate:(id<ContactManagerDelegate>)delegate{
    @synchronized(self.delegates) {
        [self.delegates removeObject:delegate];
    }
}

#pragma mark - 获取最近联系人
- (BOOL)getRecentContact {
    BOOL isRecentItemsEmpty = YES;
    @synchronized(self.recentItems) {
        isRecentItemsEmpty = (self.recentItems.count > 0);
    }
    
    if(isRecentItemsEmpty) {
        // 获取本地
        @synchronized(self.delegates) {
            for(id<ContactManagerDelegate> delegate in self.delegates) {
                if( delegate && [delegate respondsToSelector:@selector(manager:onGetRecentContact:items:errnum:errmsg:)] ) {
                    [delegate manager:self onGetRecentContact:YES items:self.recentItems errnum:@"" errmsg:@""];
                }
            }
        }
        
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
                for(LadyRecentContactObject* user in items) {
                    [self.liveChatManager getUserInfo:user.womanId];
                }
            }
            
            // 主线程回调
            dispatch_async(dispatch_get_main_queue(), ^{
                @synchronized(self.delegates) {
                    for(id<ContactManagerDelegate> delegate in self.delegates) {
                        if( [delegate respondsToSelector:@selector(manager:onGetRecentContact:items:errnum:errmsg:)] ) {
                            [delegate manager:self onGetRecentContact:blockSuccess items:self.recentItems errnum:blockErrnum errmsg:blockErrmsg];
                        }
                    }
                }
            });
        };
        
        return [self.sessionManager sendRequest:request];
    }
    
    return YES;
}

#pragma mark - 增加本地联系人
- (void)addRecentContact:(LadyRecentContactObject * _Nonnull)item
{
    LadyRecentContactObject* theRecent = [self getRecentWithId:item.womanId];
    if (nil == theRecent) {
        @synchronized(self.recentItems) {
            [self.recentItems addObject:item];
        }
    }
}

#pragma mark - LivechatManager回调
- (void)onChangeOnlineStatus:(LiveChatUserItemObject* _Nonnull)user {
    NSLog(@"ContactManager::onChangeOnlineStatus( 在线状态改变通知回调 )");
    
    LadyRecentContactObject* theRecent = [self getRecentWithId:user.userId];
    if (nil != theRecent) {
        BOOL newIsOnline = (USTATUS_ONLINE == user.statusType);
        if (theRecent.isOnline != newIsOnline) {
            theRecent.isOnline = newIsOnline;
            
            // 进行排序
            [self sortRecents];
        }
    }
}

- (void)onRecvTalkEvent:(LiveChatUserItemObject* _Nonnull)user {
    NSLog(@"ContactManager::onChangeOnlineStatus( 聊天状态改变通知回调 )");
    
    LadyRecentContactObject* theRecent = [self getRecentWithId:user.userId];
    if (nil != theRecent) {
        BOOL newIsInChat = (LCUserItem::LC_CHATTYPE_IN_CHAT_CHARGE == user.chatType
                            || LCUserItem::LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET == user.chatType);
        if (theRecent.isInChat != newIsInChat) {
            theRecent.isInChat = newIsInChat;
            
            // 进行排序
            [self sortRecents];
        }
    }
    
    @synchronized(self.delegates) {
        for(id<ContactManagerDelegate> delegate in self.delegates) {
            if( delegate && [delegate respondsToSelector:@selector(onChangeRecentContactStatus:)] ) {
                [delegate onChangeRecentContactStatus:self];
            }
        }
    }
}

- (void)onGetTalkList:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg {
    NSLog(@"ContactManager::onGetTalkList( 获取在聊列表回调 )");
    [self updateChatingStatus];
    
    @synchronized(self.delegates) {
        for(id<ContactManagerDelegate> delegate in self.delegates) {
            if( delegate && [delegate respondsToSelector:@selector(onChangeRecentContactStatus:)] ) {
                [delegate onChangeRecentContactStatus:self];
            }
        }
    }
}

- (void)updateChatingStatus
{
    NSArray* array = [self.liveChatManager getChatingUsers];
    for(LiveChatUserItemObject* user in array) {
        LadyRecentContactObject* theRecent = [self getRecentWithId:user.userId];
        if (nil != theRecent) {
            BOOL newIsInChat = (LCUserItem::LC_CHATTYPE_IN_CHAT_CHARGE == user.chatType
                                || LCUserItem::LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET == user.chatType);
            if (theRecent.isInChat != newIsInChat) {
                theRecent.isInChat = newIsInChat;
            }
        }
    }
    
    // 进行排序
    [self sortRecents];
}

//#pragma mark - 删除最近联系人列表
//- (BOOL)removeContactList:(NSMutableArray * _Nonnull)womanIdList{
//    self.sessionManager = [SessionRequestManager manager];
//    RemoveContactListRequset *request = [[RemoveContactListRequset alloc] init];
//    request.womanIdArray = womanIdList;
//    request.finishHandler = ^(BOOL success, NSString * _Nullable errnum, NSString * _Nullable errmsg){
//        NSLog(@"ContactListViewController::removeContactList( finish )");
//
//        __block BOOL blockSuccess = success;
//        __block NSString *blockErrnum = errnum;
//        __block NSString *blockErrmsg = errmsg;
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            @synchronized(self.delegates) {
//                for (id<ContactManagerDelegate> delegate in self.delegates) {
//                    if ([delegate respondsToSelector:@selector(manager:isSuccess:errnum:errmsg:)]) {
//                        [delegate manager:self isSuccess:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
//                    }
//                }
//            }
//        });
//        
//    };
//    
//    
//    return [self.sessionManager sendRequest:request];
//}

//#pragma mark - 获取最近联系人列表的在线状态
//- (BOOL)getContactListOnlineStatus:(NSString *)womanId {
//    self.sessionManager = [SessionRequestManager manager];
//    GetLadyDetailRequest *request = [[GetLadyDetailRequest alloc] init];
//    request.womanId = womanId;
//    request.finishHandler = ^(BOOL success, LadyDetailItemObject *item, NSString * _Nullable errnum, NSString * _Nullable errmsg){
//        for (LadyRecentContactObject *recentItem in _recentItems) {
//            recentItem.isOnline = item.isonline;
//        }
//        
//    };
//        return [self.sessionManager sendRequest:request];
//}

//#pragma mark - 保存列表信息
///**
// *  保存最近联系人列表信息(文件)
// *
// */
//- (void)saveRecentParam:(NSMutableArray *)recentArray{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:recentArray];
//    [userDefaults setObject:data forKey:userDefaultKeyRecent];
//    _recentItems = recentArray;
//    [userDefaults synchronize];
//}

///**
// *  读取最近联系人列表信息(文件)
// *
// */
//- (void)loadRecentParam {
//    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:userDefaultKeyRecent];
//    NSArray * array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    _recentItems = [[NSMutableArray alloc] initWithArray:array];
//    
//}

#pragma mark - 公共处理函数

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
- (void)combineRecentWithRequest:(NSArray* _Nonnull)recents
{
    for (LadyRecentContactObject* recent : recents)
    {
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
 *  对联系人数组排序
 */
- (void)sortRecents
{
    @synchronized (self.recentItems) {
        [self.recentItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
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
        }];
    }
}

- (void)onGetUserInfo:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId userInfo:(LiveChatUserInfoItemObject* _Nullable)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ContactManager::onGetUserInfo( 获取用户信息回调 userId : %@ )", userId);
        LadyRecentContactObject* theRecent = [self getRecentWithId:userId];
        if( theRecent != nil ) {
            theRecent.isOnline = (userInfo.status == USTATUS_ONLINE);
            theRecent.photoURL = userInfo.imgUrl;
        }
        
        @synchronized(self.delegates) {
            for(id<ContactManagerDelegate> delegate in self.delegates) {
                if( delegate && [delegate respondsToSelector:@selector(onChangeRecentContactStatus:)] ) {
                    [delegate onChangeRecentContactStatus:self];
                }
            }
        }
    });
}

@end
