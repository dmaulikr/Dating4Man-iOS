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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 设置公共属性
    _demo = YES;
    
    // 初始化Crash Log捕捉
    _handler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(UncaughtExceptionHandler);
    
    // 状态栏白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // 注册推送
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    // 为Document目录增加iTunes不同步属性
    NSURL *url = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
    [url addSkipBackupAttribute];
    
    // 设置导航默认返回键
    KKNavigationController *nvc = (KKNavigationController *)self.window.rootViewController;
    nvc.customDefaultBackTitle = @"Back";
    nvc.customDefaultBackImage = [UIImage imageNamed:@"Navigation-Back"];
    
    // 设置接口管理类属性
    RequestManager* manager = [RequestManager manager];
    [manager setLogDirectory:[[FileCacheManager manager] requestLogPath]];
    [manager setWebSite:@"http://demo.chnlove.com" appSite:@"http://demo-mobile.chnlove.com"];
    if( _demo ) {
        [manager setAuthorization:@"test" password:@"5179"];
    }
    
    // 初始化livechat
    [LiveChatManager manager];
    
    // 初始化联系人
    [ContactManager manager];
    
    // 自动登陆
    [[LoginManager manager] autoLogin];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Crash处理
- (BOOL)logCrashToFile:(NSString *)errorString {
    BOOL bFlag = NO;
    
    // Crash Log写入到文件
    NSDate *curDate = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"%@.crash", [curDate toStringYMDHM], nil];
    NSString *filePath = [[[FileCacheManager manager] crashLogPath] stringByAppendingPathComponent:fileName];
    
    bFlag = [errorString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if(bFlag) {
        NSLog(@"AppDelegate::logCrashToFile( crash log has been save : %@ )", filePath);
    }
    return bFlag;
}

void UncaughtExceptionHandler(NSException *exception) {
    // Objective-C 异常处理,BAD_ACCESS等错误不能捕捉
    NSArray *stack = [exception callStackReturnAddresses];
    NSArray *symbols = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSMutableString *reportString = [NSMutableString string];
    
    // 设备
    [reportString appendFormat:@"Name : %@\n", [[UIDevice currentDevice] name]];
    [reportString appendFormat:@"Model : %@\n", [[UIDevice currentDevice] model]];
    [reportString appendFormat:@"System : %@\n", [[UIDevice currentDevice] systemName]];
    [reportString appendFormat:@"System-Version : %@\n", [[UIDevice currentDevice] systemVersion]];
    [reportString appendFormat:@"UUID : %@\n", [[UIDevice currentDevice] identifierForVendor]];
    
    // 程序
    [reportString appendFormat:@"CFBundleDisplayName : %@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
    [reportString appendFormat:@"CFBundleVersion : %@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    // 原因
    [reportString appendFormat:@"ExecptionName : %@\nReason : %@\n\nSymbols : %@\n\nStack : %@\n", name, reason, symbols, stack];
    
    // Crash Log写入到文件
    [AppDelegate() logCrashToFile:reportString];
}

@end
