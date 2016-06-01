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
        [self.delegates addObject:delegate];
    }
}

- (void)removeDelegate:(id<LoginManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        [self.delegates removeObject:delegate];
    }
}

- (BOOL)login:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode {
    // 因为同步配置可能异步, 所以声明为block
    __block BOOL bFlag = YES;
    
    RequestManager* manager = [RequestManager manager];
    
    switch (self.status) {
        case NONE:{
            // 未登陆
            
            // 停止所有请求
            [manager stopAllRequest];
            
            // 重新登陆
            if( user && user.length > 0 && password && password.length > 0 ) {
                @synchronized(self) {
                    // 进入登陆状态
                    _status = LOGINING;
                }
                
                // 先同步配置
                bFlag = [[ConfigManager manager] synConfig:^(BOOL success, SynConfigItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
                    // 同步配置成功
                    if( success ) {
                        if( HTTPREQUEST_INVALIDREQUESTID != [manager login:user password:password checkcode:checkcode?checkcode:@"" finishHandler:^(BOOL success, LoginItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
                            // 登陆接口回调
                            
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
                                    // TODO:登陆失败
                                    _status = NONE;
                                    
                                }
                            }

                            __block BOOL blockSuccess = success;
                            __block NSString* blockErrnum = errnum;
                            __block NSString* blockErrmsg = errmsg;
                            
                            // 主线程回调
                            dispatch_async(dispatch_get_main_queue(), ^{
                                @synchronized(self.delegates) {
                                    for(id<LoginManagerDelegate> delegate in self.delegates) {
                                        if( [delegate respondsToSelector:@selector(manager:onLogin:loginItem:errnum:errmsg:)] ) {
                                            [delegate manager:self onLogin:blockSuccess loginItem:self.loginItem errnum:blockErrnum errmsg:blockErrmsg];
                                        }
                                    }
                                }
                            });
                            
                        }] ) {
                            // 开启登陆请求成功
                            bFlag = YES;
                            
                            @synchronized(self) {
                                // 进入登陆状态
                                _status = LOGINING;
                            }
                            
                        } else {
                            // 开启登陆请求失败
                            bFlag = NO;
                        }
                        
                    } else {
                        // 同步配置失败, 导致登陆失败
                        __block BOOL blockSuccess = success;
                        __block NSString* blockErrnum = errnum;
                        __block NSString* blockErrmsg = errmsg;
                        
                        // 主线程回调
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized(self.delegates) {
                                for(id<LoginManagerDelegate> delegate in self.delegates) {
                                    if( [delegate respondsToSelector:@selector(manager:onLogin:loginItem:errnum:errmsg:)] ) {
                                        [delegate manager:self onLogin:blockSuccess loginItem:self.loginItem errnum:blockErrnum errmsg:blockErrmsg];
                                    }
                                }
                            }
                        });
                    }
                }];
                
                // 开启同步配置请求成功
                if( bFlag ) {
                    @synchronized(self) {
                        // 进入登陆状态
                        _status = LOGINING;
                    }
                }
                
            } else {
                // 参数不够
                bFlag = NO;
            }
            
        }break;
        case LOGINING:{
            // 登陆中
            bFlag = YES;
            
        }break;
        case LOGINED:{
            // 已经登陆
            bFlag = NO;
            
        }break;
        default:
            break;
    }
    
    return bFlag;
}

- (void)logout:(BOOL)kick {
    if( kick ) {
        // 主动注销(被踢)
        
        // 标记不能自动重
        self.isAutoLogin = NO;
        
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

@end
