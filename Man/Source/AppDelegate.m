//
//  AppDelegate.m
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "AppDelegate.h"

#import <UserNotifications/UserNotifications.h>

#import "AFNetworkReachabilityManager.h"
#import "RequestManager.h"
#import "LoginManager.h"
#import "LiveChatManager.h"
#import "ContactManager.h"
#import "PaymentManager.h"
#import "CrashLogManager.h"
#import "AnalyticsManager.h"
#import "URLHandler.h"

#define errorLocal @"/Public/images/photo_unavailable.gif"

@implementation AppDelegate
@synthesize demo = _demo;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // 设置公共属性
    _debug = NO;
    
    // 设置站点
//    _siteType = OTHER_SITE_CL;
    _siteType = OTHER_SITE_CD;
    
    // 初始化Crash Log捕捉
    [CrashLogManager manager];
    
    // 状态栏白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // 注册推送
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    // 为Document目录增加iTunes不同步属性
    NSURL *url = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
    [url addSkipBackupAttribute];
    
    // 设置导航默认返回键
    KKNavigationController *nvc = (KKNavigationController *)self.window.rootViewController;
    [nvc.navigationBar setTintColor:[UIColor whiteColor]];
//    nvc.customDefaultBackTitle = NSLocalizedString(@"Back", nil);
//    nvc.customDefaultBackImage = [UIImage imageNamed:@"Navigation-Back"];
    
    // 设置接口管理类属性
    RequestManager* manager = [RequestManager manager];
    [manager setLogEnable:NO];
    [manager setLogDirectory:[[FileCacheManager manager] requestLogPath]];
    
    // 设置接口请求环境
    // 如果调试模式, 直接进入正式环境
    [self setRequestHost:_debug];
    
    // 初始化跟踪管理器(默认为真实环境)
    [[AnalyticsManager manager] initGoogleAnalytics:YES];

    // 初始化livechat
    [LiveChatManager manager];
    
    // 初始化联系人管理器
    [ContactManager manager];
    
    // 初始化支付管理器
    [PaymentManager manager];
    
    // 初始化URL跳转
    [URLHandler shareInstance];
    
    // 自动登陆
    [[LoginManager manager] autoLogin];
    
    // 清除webview的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    // 注册推送
    [self registerRemoteNotifications:application];
    
    // 延长启动画面时间
    usleep(1000 * 1000);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [[LiveChatManager manager] endTalkAll];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[LiveChatManager manager] relogin];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"application::didRegisterForRemoteNotificationsWithDeviceToken( deviceToken : %@ )", deviceToken);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"application::didReceiveRemoteNotification( userInfo : %@ )", userInfo);
    
    NSString* urlString = [userInfo objectForKey:@"url"];
    if( urlString.length > 0 ) {
        NSURL* url = [NSURL URLWithString:urlString];
        [[URLHandler shareInstance] handleOpenURL:url];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"application::handleOpenURL( url : %@ )", url);
    return [[URLHandler shareInstance] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"application::openURL( sourceApplication : %@ )", sourceApplication);
    return [[URLHandler shareInstance] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    NSLog(@"application::openURL( options : %@ )", options);
    return [[URLHandler shareInstance] handleOpenURL:url];
}

- (void)setRequestHost:(BOOL)formal {
    RequestManager* manager = [RequestManager manager];
    
    if( formal ) {
        // 真服务器环境
        NSString* webSite = @"";
        NSString* webSiteDemo = @"";
        NSString* appSite = @"";
        NSString* appSiteDemo = @"";
        NSString* wapSite = @"";
        NSString* wapSiteDemo = @"";
        
        switch (self.siteType) {
            case OTHER_SITE_CL:{
                webSite = @"http://www.chnlove.com";
                webSiteDemo = @"http://demo.chnlove.com";
                appSite = @"http://mobile.chnlove.com";
                appSiteDemo = @"http://demo-mobile.chnlove.com";
                wapSite = @"http://m.chnlove.com";
                wapSiteDemo = @"http://demo-m.chnlove.com";
                
            }break;
            case OTHER_SITE_CD:{
                webSite = @"http://www.charmdate.com";
                webSiteDemo = @"http://demo.charmdate.com";
                appSite = @"http://mobile.charmdate.com";
                appSiteDemo = @"http://demo-mobile.charmdate.com";
                wapSite = @"http://m.charmdate.com";
                wapSiteDemo = @"http://demo-m.charmdate.com";
                
            }break;
            default:
                break;
        }
        
        if( _demo ) {
            // Demo环境
            _wapSite = wapSiteDemo;
            [manager setAuthorization:@"test" password:@"5179"];
            [manager setWebSite:webSiteDemo appSite:appSiteDemo];
            
        } else {
            _wapSite = wapSite;
            [manager setAuthorization:@"" password:@""];
            [manager setWebSite:webSite appSite:appSite];
        }
        
    } else {
        // 配置假服务器路径
        if( _demo ) {
            [manager setAuthorization:@"test" password:@"5179"];
            [manager setWebSite:@"http://demo-ios.qpidnetwork.com" appSite:@"http://demo-ios.qpidnetwork.com"];
            [manager setFakeSite:@"http://demo-ios.qpidnetwork.com"];
        } else {
            [manager setWebSite:@"http://www.qdating.net" appSite:@"http://www.qdating.net"];
            [manager setFakeSite:@"http://www.qdating.net"];
        }

    }
    
    _errorUrlConnect = [[[manager getAppSite] stringByAppendingString:errorLocal] copy];
}

- (BOOL)demo {
    //如果版本号最后一位是字母,则是demo
    NSString *versionCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    char lastCode = [versionCode characterAtIndex:versionCode.length - 1];
    if ((lastCode >= 'a' && lastCode <= 'z') || (lastCode >= 'A' && lastCode <= 'Z')) {
        _demo = YES;
    } else {
        _demo = NO;
    }
    return _demo;
}

- (void)registerRemoteNotifications:(UIApplication *)application {
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // Register for Push Notitications, if running iOS 8
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
        
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    // 清除图标数字, 清空通知栏
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}

@end
