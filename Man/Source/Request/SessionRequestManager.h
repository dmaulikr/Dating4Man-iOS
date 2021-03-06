//
//  SessionRequestManager.h
//  dating
//
//  Created by Max on 16/3/11.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SessionRequest;

#pragma mark - 需要重登陆的接口返回处理
@protocol SessionRequestDelegate <NSObject>
/**
 *  请求返回
 *
 *  @param errnum 错误码
 *  @param errmsg 错误提示
 *
 *  @return YES:已经处理/NO:没有处理
 */
- (BOOL)request:(SessionRequest* _Nonnull)request handleRespond:(BOOL)success errnum:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg;

@end

@interface SessionRequestManager : NSObject <SessionRequestDelegate>
#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

/**
 *  发送请求
 *
 *  @param request 请求实例
 *
 *  @return YES:成功发起请求/NO:发起请求失败
 */
- (BOOL)sendRequest:(SessionRequest* _Nonnull)request;

@end
