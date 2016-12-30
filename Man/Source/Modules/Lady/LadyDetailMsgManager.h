//
//  LadyDetailMsgManager.h
//  dating
//
//  Created by test on 16/12/1.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LadyDetailItemObject.h"
#import "LiveChatManager.h"

@class LadyDetailMsgManager;
@protocol LadyDetailMsgManagerDelegate <NSObject>

- (void)manager:(LadyDetailMsgManager * _Nonnull)manager didShowLadyDetailMsg:(LadyDetailItemObject * _Nonnull)item;
- (void)manager:(LadyDetailMsgManager * _Nonnull)manager getLadyUserInfo:(LiveChatUserInfoItemObject * _Nonnull)userInfo;

@end



@interface LadyDetailMsgManager : NSObject
#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

/**
 *  增加监听器
 *
 *  @param delegate 监听器
 */
- (void)addDelegate:(id<LadyDetailMsgManagerDelegate> _Nonnull)delegate;

/**
 *  删除监听器
 *
 *  @param delegate 监听器
 */
- (void)removeDelegate:(id<LadyDetailMsgManagerDelegate> _Nonnull)delegate;

- (LiveChatUserInfoItemObject * _Nonnull)getLadyUserInfo:(NSString * _Nullable)womanId;
- (LadyDetailItemObject * _Nonnull)getLadyDetail:(NSString * _Nullable)womanId;
@end
