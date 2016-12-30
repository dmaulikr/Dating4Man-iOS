//
//  LadyDetailMsgManager.m
//  dating
//
//  Created by test on 16/12/1.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyDetailMsgManager.h"
#import "GetLadyDetailRequest.h"


@interface LadyDetailMsgManager()<LiveChatManagerDelegate>
/* 个人详情 */
@property (strong, nonatomic) LadyDetailItemObject *item;

/** 个人详情信息缓存 */
@property (nonatomic,strong) NSMutableDictionary *ladydetailCacheDict;
/** 个人用户信息缓存 */
@property (nonatomic,strong) NSMutableDictionary *ladyUserInfoCacheDict;

/** 任务管理 */
@property (nonatomic,strong) SessionRequestManager *sessionManager;
/**
 *  Livechat管理器
 */
@property (nonatomic, strong) LiveChatManager *liveChatManager;

/**
 *  回调数组
 */
@property (nonatomic, strong) NSMutableArray* delegates;

@end


static LadyDetailMsgManager* gManager = nil;

@implementation LadyDetailMsgManager


#pragma mark - 获取实例
+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if( self = [super init] ) {
        // 初始化女士详情缓存
        self.ladydetailCacheDict = [NSMutableDictionary dictionary];
        self.ladyUserInfoCacheDict = [NSMutableDictionary dictionary];
        
        self.liveChatManager = [LiveChatManager manager];
        [self.liveChatManager addDelegate:self];
    }
    return self;
}

- (void)addDelegate:(id<LadyDetailMsgManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)removeDelegate:(id<LadyDetailMsgManagerDelegate>)delegate{
    @synchronized(self.delegates) {
        for(NSValue* value in self.delegates) {
            id<LadyDetailMsgManagerDelegate> item = (id<LadyDetailMsgManagerDelegate>)value.nonretainedObjectValue;
            if( item == delegate ) {
                [self.delegates removeObject:value];
                break;
            }
        }
        
    }
}



- (LadyDetailItemObject *)getLadyDetail:(NSString *)womanId {
    LadyDetailItemObject* detail = [self.ladydetailCacheDict valueForKey:womanId];
    if (detail == nil) {
        GetLadyDetailRequest *request = [[GetLadyDetailRequest alloc] init];
        request.womanId = womanId;
        self.item = [[LadyDetailItemObject alloc] init];
        request.finishHandler = ^(BOOL success, LadyDetailItemObject *item, NSString * _Nullable errnum, NSString * _Nullable errmsg){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.ladydetailCacheDict setValue:item forKey:womanId];
                [self onGetLadyDetail:success errnum:nil errmsg:nil Msg:item];

            });
        };
        
        [self.sessionManager sendRequest:request];
        return self.item;
    }
    
    return detail;
}



- (void)onGetLadyDetail:(BOOL)success errnum:(NSString *)errnum errmsg:(NSString *)errmsg Msg:(LadyDetailItemObject *)item {
    @synchronized(self.delegates) {
        for(NSValue* value in self.delegates) {
            id<LadyDetailMsgManagerDelegate> delegate = (id<LadyDetailMsgManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(manager:didShowLadyDetailMsg:)] ) {
                [delegate manager:self didShowLadyDetailMsg:item];
            }
        }
    }
}


/**
 获取女士用户信息

 @param womanId 女士id
 */
- (LiveChatUserInfoItemObject *)getLadyUserInfo:(NSString *)womanId {
    LiveChatUserInfoItemObject *userInfo = [self.ladyUserInfoCacheDict valueForKey:womanId];
    if (userInfo == nil) {
        [self.liveChatManager getUserInfo:womanId];
    }
    return userInfo;
}



- (void)onGetUserInfo:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId userInfo:(LiveChatUserInfoItemObject* _Nullable)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
            if( LCC_ERR_SUCCESS == errType ) {
                [self.ladyUserInfoCacheDict setValue:userInfo forKey:userId];
                
                @synchronized(self.delegates) {
                    for(NSValue* value in self.delegates) {
                        id<LadyDetailMsgManagerDelegate> delegate = (id<LadyDetailMsgManagerDelegate>)value.nonretainedObjectValue;
                        if( [delegate respondsToSelector:@selector(manager:getLadyUserInfo:)] ) {
                            [delegate manager:self getLadyUserInfo:userInfo];
                        }
                    }
                }
                
            }
        
        
    });
}



@end
