//
//  ServerViewControllerManager.h
//  dating
//
//  Created by Max on 16/8/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerViewControllerManager : NSObject

#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

/**
 *  获取聊天界面实例
 *
 *  @param firstname 对方用户名
 *  @param womanid   对方用户Id
 *  @param photoURL  对方头像路径
 *
 *  @return 聊天界面实例
 */
- (UIViewController* _Nonnull)chatViewController:(NSString* _Nullable)firstname womanid:(NSString* _Nullable)womanid photoURL:(NSString* _Nullable)photoURL;

@end
