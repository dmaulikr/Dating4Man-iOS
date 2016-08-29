//
//  LoginManager.m
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LoginManager.h"
#import "RequestManager.h"
#import "ConfigManager.h"
#import "ServerManager.h"


static LoginManager* gManager = nil;

@interface LoginManager ()

@property (nonatomic, strong) NSMutableArray* delegates;
@property (nonatomic, assign) BOOL isAutoLogin;

@end

@implementation LoginManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if( self = [super init] ) {
        _status = NONE;

        self.delegates = [NSMutableArray array];
        self.isAutoLogin = NO;
        
        @synchronized(self) {
            // 加载用户信息
            [self loadLoginParam];
            
            if( self.email && self.email.length > 0 && self.password && self.password.length > 0 ) {
                self.isAutoLogin = YES;
            }
        }
        
    }
    return self;
}

- (void)addDelegate:(id<LoginManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)removeDelegate:(id<LoginManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        for(NSValue* value in self.delegates) {
            id<LoginManagerDelegate> item = (id<LoginManagerDelegate>)value.nonretainedObjectValue;
            if( item == delegate ) {
                [self.delegates removeObject:value];
                break;
            }
        }
    }
}

- (LoginStatus)login:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode {
    RequestManager* manager = [RequestManager manager];
    _lastInputEmail = user;
    _lastInputPassword = password;
    
    switch (self.status) {
        case NONE:{
            // 未登陆
            
            // 停止所有请求
            [manager stopAllRequest];
            
            // 用户名和密码
            if( user && user.length > 0 && password && password.length > 0 ) {
                // 进入登陆状态
                @synchronized(self) {
                    _status = LOGINING;
                }
                
                // 登陆回调
                LoginFinishHandler loginFinishHandler = ^(BOOL success, LoginItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
                    @synchronized(self) {
                        if( success ) {
                            // 登陆成功
                            _status = LOGINED;
                            
                            _email = user;
                            _password = password;
                            _loginItem = item;
                            
                            // 标记可以自动重登陆
                            self.isAutoLogin = YES;
                            
                            // 保存用户信息
                            [self saveLoginParam];
                            
                        } else {
                            // 登陆失败
                            _status = NONE;
                            
                        }
                        
                    }
                    
                    __block BOOL blockSuccess = success;
                    __block NSString* blockErrnum = errnum;
                    __block NSString* blockErrmsg = errmsg;
                    
                    // 回调
                    [self callbackLoginStatus:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
                    
                };
                // 同步配置回调
                SynConfigFinishHandler synConfigFinishHandler = ^(BOOL success, SynConfigItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
                    if( success ) {
                        if( HTTPREQUEST_INVALIDREQUESTID != [manager login:user password:password checkcode:checkcode?checkcode:@"" finishHandler:loginFinishHandler] ) {
                            // TODO:3.开始登陆
                        } else {
                            // 开始登陆失败
                            // 主线程回调
                            [self callbackLoginStatus:NO errnum:@"Unknow error" errmsg:@"Unknow error"];
                        }
                    } else {
                        // 同步配置失败, 导致登陆失败
                        __block BOOL blockSuccess = success;
                        __block NSString* blockErrnum = errnum;
                        __block NSString* blockErrmsg = errmsg;
                        
                        @synchronized(self) {
                            // 进入未登陆状态
                            _status = NONE;
                        }
                        
                        // 主线程回调
                        [self callbackLoginStatus:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];

                    }

                };
                // 获取服务器回调
                CheckServerFinishHandler checkServerFinishHandler = ^(BOOL success, CheckServerItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
                    if( success ) {
                        // TODO:2.开始同步配置
                        [[ConfigManager manager] synConfig:synConfigFinishHandler];
                        
                    } else {
                        // 同步配置失败, 导致登陆失败
                        __block BOOL blockSuccess = success;
                        __block NSString* blockErrnum = errnum;
                        __block NSString* blockErrmsg = errmsg;
                        
                        @synchronized(self) {
                            // 进入未登陆状态
                            _status = NONE;
                        }
                        
                        // 主线程回调
                        [self callbackLoginStatus:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
                    }

                };
                
                // TODO:1.开始获取真假服务器
                // 清空同步配置和服务器
                [[ConfigManager manager] clean];
                [[ServerManager manager] clean];
                
                // 开始获取真假服务器
                [[ServerManager manager] checkServer:user finishHandler:checkServerFinishHandler];

            } else {
                // 参数不够
            }
        }break;
        case LOGINING:{
            // 登陆中
            
        }break;
        case LOGINED:{
            // 已经登陆
            
        }break;
        default:
            break;
    }
    
    return self.status;
}

- (void)logout:(BOOL)kick {
    if( kick ) {
        // 主动注销(被踢)
        
        // 标记不能自动重
        self.isAutoLogin = NO;
        [[RequestManager manager] cleanCookies];
        [[ConfigManager manager] clean];
        [[ServerManager manager] clean];
        
        // 清除用户帐号密码
        @synchronized(self) {
//            _email = nil;
            _password = nil;
            _loginItem = nil;
            
            // 保存用户信息
            [self saveLoginParam];
        }
    }

    // 标记为已经注销
    @synchronized(self) {
        _status = NONE;
    }
    
    @synchronized(self.delegates) {
        for(NSValue* value in self.delegates) {
            id<LoginManagerDelegate> delegate = value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(manager:onLogout:)] ) {
                [delegate manager:self onLogout:kick];
            }

        }
    }

}

- (BOOL)autoLogin {
    if( self.isAutoLogin ) {
        return [self login:self.email password:self.password checkcode:nil];
        
    } else {
        return NO;
        
    }

}

/**
 *  保存用户信息(文件)
 *
 */
- (void)saveLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:self.email forKey:@"email"];
    [userDefaults setObject:self.password forKey:@"password"];
    
//    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.loginItem];
//    [userDefaults setObject:data forKey:@"loginItem"];
    
    [userDefaults synchronize];
}

/**
 *  加载用户信息(文件)
 *
 */
- (void)loadLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    _email = [userDefaults stringForKey:@"email"];
    _password = [userDefaults stringForKey:@"password"];
    
//     NSData* data = [userDefaults objectForKey:@"loginItem"];
//    _loginItem = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
}

- (void)callbackLoginStatus:(BOOL)success errnum:(NSString *)errnum errmsg:(NSString *)errmsg {
    // 主线程回调
    @synchronized(self.delegates) {
        for(NSValue* value in self.delegates) {
            id<LoginManagerDelegate> delegate = value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(manager:onLogin:loginItem:errnum:errmsg:)] ) {
                [delegate manager:self onLogin:success loginItem:self.loginItem errnum:errnum errmsg:errmsg];
            }
        }
    }

}
@end
