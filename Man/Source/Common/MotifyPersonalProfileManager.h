//
//  MotifyPersonalProfileManager.h
//  dating
//
//  Created by lance on 16/8/3.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^MotifityFinishHandler)(BOOL success);

@class MotifyPersonalProfileManager;
@protocol MotifyPersonalProfileManagerDelegate <NSObject>

@optional

- (void)motifyPersonalProfileResult:(MotifyPersonalProfileManager * _Nonnull)manager result:(BOOL)success;

@end

@interface MotifyPersonalProfileManager : NSObject

/** 修改完成回调 */
//@property (nonatomic,strong)  MotifityFinishHandler  _Nullable finishHandler;

/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

/**
 *  修改个人描述
 *
 *  @param resume 描述
 */
- (void)motifyPersonalResume:(NSString * _Nonnull)resume;

/** 代理 */
@property (nonatomic, weak)  id<MotifyPersonalProfileManagerDelegate> _Nullable delegate;

@end
