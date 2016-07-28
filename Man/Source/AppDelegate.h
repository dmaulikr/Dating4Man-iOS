//
//  AppDelegate.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/Analytics.h>

#include <manrequesthandler/RequestOtherDefine.h>

#define AppDelegate() ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSUncaughtExceptionHandler *_handler;
}

@property (strong, nonatomic) UIWindow *window;
/**
 *  是否Demo环境
 */
@property (nonatomic, assign) BOOL demo;

/**
 *  调试模式, 直接访问真实服务器(Demo环境／正式环境)
 */
@property (nonatomic, assign) BOOL debug;

/** 没图的url */
@property (nonatomic,strong) NSString *errorUrlConnect;

/**
 *  站点类型
 *
 */
@property (nonatomic, assign) OTHER_SITE_TYPE siteType;

/**
 *  设置接口请求环境
 *
 *  @param formal 是否正式环境
 */
- (void)setRequestHost:(BOOL)formal;

@end

