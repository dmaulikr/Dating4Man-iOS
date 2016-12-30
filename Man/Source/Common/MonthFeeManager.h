//
//  MonthFeeManager.h
//  dating
//
//  Created by lance on 16/8/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
  不需要缴费的用户
  已经缴费的月费用户
  第一缴费的月费用户
  不是第一次缴费的月费用户
 */
typedef enum {
    MonthFeeTypeNoramlMember = 1,
    MonthFeeTypeFeeMember,
    MonthFeeTypeFirstFeeMember,
    MonthFeeTypeNoFirstFeeMember
}MonthFeeType;

@class MonthFeeManager;
@protocol MonthFeeManagerDelegate <NSObject>
@optional

/**
 *  月费管理器状态
 *
 *  @param manager    月费管理器
 *  @param success    成功
 *  @param errnum     错误编码
 *  @param errmsg     错误信息
 *  @param memberType 月费类型
 */
- (void)manager:(MonthFeeManager * _Nonnull)manager onGetMemberType:(BOOL)success  errnum:(NSString * _Nonnull)errnum errmsg:(NSString * _Nonnull)errmsg memberType:(MonthFeeType)memberType;

/**
 *  月费管理器费用信息
 *
 *  @param manager    月费管理器
 *  @param success    成功
 *  @param errnum     错误编码
 *  @param errmsg     错误信息
 *  @param tipsArray  提示内容数组
 */
- (void)manager:(MonthFeeManager * _Nonnull)manager onGetMonthFee:(BOOL)success  errnum:(NSString * _Nonnull)errnum errmsg:(NSString * _Nonnull)errmsg tips:(NSArray * _Nonnull)tipsArray;
@end

@interface MonthFeeManager : NSObject

/**
 *  是否请求过接口
 */
@property (nonatomic, assign) BOOL bRequest;
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
- (void)addDelegate:(id<MonthFeeManagerDelegate> _Nonnull)delegate;

/**
 *  删除监听器
 *
 *  @param delegate 监听器
 */
- (void)removeDelegate:(id<MonthFeeManagerDelegate> _Nonnull)delegate;

/**
 *  获取月费状态
 *
 *  @return 标识
 */
- (BOOL)getQueryMemberType;
/**
 *  获取月费信息
 *
 *  @return <#return value description#>
 */
- (BOOL)getMonthFee;
@end
