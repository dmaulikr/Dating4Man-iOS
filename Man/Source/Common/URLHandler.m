//
//  URLHandler.m
//  dating
//
//  Created by Max on 16/10/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "URLHandler.h"
#import "AnalyticsManager.h"
#import "LoginManager.h"

static URLHandler* gInstance = nil;

@interface URLHandler () <LoginManagerDelegate>

/**
 *  是否已经被URL打开
 */
@property (assign, atomic) BOOL openByUrl;

/**
 *  是否有待处理URL
 */
@property (assign, atomic) BOOL hasHandle;

@end

@implementation URLHandler
+ (instancetype)shareInstance {
    if( gInstance == nil ) {
        gInstance = [[[self class] alloc] init];
    }
    return gInstance;
}

- (id)init {
    if( self = [super init] ) {
        _openByUrl = NO;
        _type = URLTypeNone;
        self.hasHandle = NO;
        
        // 自动登陆
        [[LoginManager manager] addDelegate:self];
    }
    return self;
}

- (BOOL)handleOpenURL:(NSURL *)url {
    NSLog(@"URLHandler::handleOpenURL( url : %@ )", url);
    NSLog(@"URLHandler::handleOpenURL( url.host : %@ )", url.host);
    NSLog(@"URLHandler::handleOpenURL( url.path : %@ )", url.path);
    NSLog(@"URLHandler::handleOpenURL( url.query : %@ )", url.query);
    
    // 第一次进入通知GA
    if( !_openByUrl ) {
        _openByUrl = YES;
        [[AnalyticsManager manager] openURL:url];
    }
    
    // 跳转模块
    NSString* moduleString = [url parameterForKey:@"module"];
    if( [moduleString isEqualToString:@"emf"] ) {
        // 跳转emf
        _type = URLTypeEmf;
    }else if ([moduleString isEqualToString:@"setting"]) {
        _type = URLTypeSetting;
    }else if ([moduleString isEqualToString:@"ladydetail"]) {
        _type = URLTypeLadyDetail;
    }else if ([moduleString isEqualToString:@"chatlady"]) {
        _type = URLTypeChatLady;
    }
    
    [self dealWithURL];
    
    return YES;
}

- (BOOL)dealWithURL {
    // 标记需要处理
    self.hasHandle = YES;
    
    LoginManager* manager = [LoginManager manager];
    switch (manager.status) {
        case NONE: {
            // 没登陆
        }
        case LOGINING:{
            // 登陆中
        }break;
        case LOGINED:{
            // 已经登陆
            [self callDelegate];
        }break;
        default:
            break;
    }
    
    return NO;
}

- (void)callDelegate {
    if( self.hasHandle ) {
        self.hasHandle = NO;
        if( [self.delegate respondsToSelector:@selector(handler:openWithModule:)] ) {
            [self.delegate handler:self openWithModule:self.type];
            _type = URLTypeNone;
        }
    }
}

#pragma mark - LoginManager回调
- (void)manager:(LoginManager * _Nonnull)manager onLogin:(BOOL)success loginItem:(LoginItemObject * _Nullable)loginItem errnum:(NSString * _Nonnull)errnum errmsg:(NSString * _Nonnull)errmsg {
    NSLog(@"URLHandler::onLogin( 接收登录回调 success : %d )", success);
    // 有未处理的URL请求
    if( success ) {
        [self callDelegate];
    }
}

@end
