//
//  ContactManager.h
//  dating
//
//  Created by lance on 16/4/21.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LadyDetailItemObject.h"
#import "SessionRequest.h"

@class ContactManager;
@protocol ContactManagerDelegate <NSObject>
@optional

/**
 *  获取联系人列表回调
 *
 *  @param manager    联系人管理器
 *  @param success    获取是否成功
 *  @param recentList 最近联系人的列表
 *  @param errnum     错误编码
 *  @param errmsg     错误信息提示
 */
- (void)manager:(ContactManager * _Nonnull)manager onGetRecentContact:(BOOL)success items:(NSArray * _Nonnull)items errnum:(NSString * _Nonnull)errnum errmsg:(NSString * _Nonnull)errmsg;

/**
 *  联系人状态改变
 *
 *  @param manager          联系人管理器
 *  @param success          是否成功
 *  @param ladyOnlineStatus 在线状态
 *  @param errnum           错误编码
 *  @param errmsg           错误信息提示
 */
- (void)onChangeRecentContactStatus:(ContactManager * _Nonnull)manager;

@end

@interface ContactManager : NSObject
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
- (void)addDelegate:(id<ContactManagerDelegate> _Nonnull)delegate;

/**
 *  删除监听器
 *
 *  @param delegate <#delegate description#>
 */
- (void)removeDelegate:(id<ContactManagerDelegate> _Nonnull)delegate;

/**
 *  获取最近联系人列表
 */
- (BOOL)getRecentContact;

/**
 *  获取或添加本地联系人(若不存在则新建联系人object)
 *
 *  @param womanId 女士ID
 *
 *  @return 联系人object
 */
- (LadyRecentContactObject* _Nonnull)getOrNewRecentWithId:(NSString* _Nonnull)womanId;

/**
 *  更新联系人最后联系时间
 *
 *  @param recent 联系人object
 */
+ (void)updateLasttime:(LadyRecentContactObject* _Nonnull)recent;

/**
 *  更新联系人列表
 */
- (void)updateRecents;

///**
// *
// *
// *  @return 移除最近联系人列表
// */
//- (BOOL)removeContactList:(NSMutableArray * _Nonnull)womanIdList;

@end
