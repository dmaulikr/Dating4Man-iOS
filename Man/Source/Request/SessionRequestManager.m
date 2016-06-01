//
//  SessionRequestManager.m
//  dating
//
//  Created by Max on 16/3/11.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//
//  需要处理Session过期的接口调用处理器

#import "SessionRequestManager.h"

#import "LoginManager.h"
#import "SessionRequest.h"

static SessionRequestManager* gManager = nil;
@interface SessionRequestManager () <LoginManagerDelegate>
@property (nonatomic, strong) LoginManager* loginManager;
@property (nonatomic, strong) NSMutableArray* array;
@end

@implementation SessionRequestManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if( self = [super init] ) {
        self.array = [NSMutableArray array];
        
        self.loginManager = [LoginManager manager];
        [self.loginManager addDelegate:self];
    }
    return self;
}

#pragma mark - 接口回调处理
- (BOOL)sendRequest:(SessionRequest* _Nonnull)request {
    request.delegate = self;
    return [request sendRequest];
}

- (BOOL)request:(SessionRequest* _Nonnull)request handleRespond:(BOOL)success errnum:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg {
    
    BOOL bFlag = NO;
    if( !success ) {
        // 判断错误码
        if( [errnum isEqualToString:SESSION_TIMEOUT] ) {
            // session超时
            // 插入待处理队列
            @synchronized(self.array) {
                [self.array addObject:request];
            }
            
            // 主线程登陆
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loginManager logout:NO];
                [self.loginManager autoLogin];
            });
            
            bFlag = YES;
        }
    }
    
    return bFlag;
}

#pragma mark - 登陆回调处理
- (void)manager:(LoginManager * _Nonnull)manager onLogin:(BOOL)success loginItem:(LoginItemObject * _Nullable)loginItem errnum:(NSString * _Nonnull)errnum errmsg:(NSString * _Nonnull)errmsg {
    
    @synchronized(self.array) {
        if( success ) {
            // 重新发送请求
            for(SessionRequest* request in self.array) {
                if( request ) {
                    [request sendRequest];
                }
            }
            
        } else {
            // 回调失败
            for(SessionRequest* request in self.array) {
                if( request ) {
                    [request callRespond:success errnum:errnum errmsg:errmsg];
                }
            }
            
        }
        
        // 清空所有请求
        [self.array removeAllObjects];

    }
    
}

- (void)manager:(LoginManager * _Nonnull)manager onLogout:(BOOL)timeout {
    
}

@end
