//
//  ServerManager.h
//  dating
//
//  Created by Max on 16/6/6.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RequestManager.h"

/**
 *  真假服务器管理器
 */
@interface ServerManager : NSObject
/**
 *  真假服务器
 */
@property (nonatomic, strong) CheckServerItemObject* _Nullable item;

#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

/**
 *  获取服务器接口
 *
 *  @param user          用户
 *  @param finishHandler 接口回调
 *
 *  @return 成功:/失败
 */
- (BOOL)checkServer:(NSString * _Nonnull)user finishHandler:(CheckServerFinishHandler _Nullable)finishHandler;

/**
 *  清除
 */
- (void)clean;
@end
