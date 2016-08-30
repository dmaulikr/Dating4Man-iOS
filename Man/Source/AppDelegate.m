//
//  AppDelegate.m
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkReachabilityManager.h"
#import "RequestManager.h"
#import "LoginManager.h"
#import "LiveChatManager.h"
#import "ContactManager.h"
#import "PaymentManager.h"
#import "CrashLogManager.h"
#import "AnalyticsManager.h"
#define errorLocal @"/Public/images/photo_unavailable.gif"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // 设置公共属性
    _demo = YES;
    _debug = NO;
//    self.siteType = OTHER_SITE_CL;
    self.siteType = OTHER_SITE_CD;
    
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
    [manager setLogEnable:YES];
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
    
    // 自动登陆
    [[LoginManager manager] autoLogin];
    
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

- (void)setRequestHost:(BOOL)formal {
    RequestManager* manager = [RequestManager manager];
    
    if( formal ) {
        // 真服务器环境
        NSString* webSite = @"";
        NSString* webSiteDemo = @"";
        NSString* appSite = @"";
        NSString* appSiteDemo = @"";
        
        switch (self.siteType) {
            case OTHER_SITE_CL:{
                webSite = @"http://www.chnlove.com";
                webSiteDemo = @"http://demo.chnlove.com";
                appSite = @"http://mobile.chnlove.com";
                appSiteDemo = @"http://demo-mobile.chnlove.com";
                
            }break;
            case OTHER_SITE_CD:{
                webSite = @"http://www.charmdate.com";
                webSiteDemo = @"http://demo.charmdate.com";
                appSite = @"http://mobile.charmdate.com";
                appSiteDemo = @"http://demo-mobile.charmdate.com";
                
            }break;
            default:
                break;
        }
        
        if( _demo ) {
            // Demo环境
            [manager setAuthorization:@"test" password:@"5179"];
            [manager setWebSite:webSiteDemo appSite:appSiteDemo];

        } else {
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
    
    self.errorUrlConnect = [[manager getAppSite] stringByAppendingString:errorLocal];

}
@end
