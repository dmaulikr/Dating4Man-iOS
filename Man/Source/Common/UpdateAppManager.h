//
//  UpdateAppManager.h
//  dating
//
//  Created by lance on 16/6/1.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UpdateAppManager : NSObject

/** apple */
@property (nonatomic,strong) NSString * _Nonnull appleStoreUrl;
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;


/** 根据字符串判断版本 */
- (BOOL)isNewVersion:(NSString * _Nonnull)newVersion;
/** 根据版本号判断版本 */
- (BOOL)isNewVersionCode:(NSInteger)newVersionCode;
/** 是否新版本 */
- (BOOL)isBanned:(NSString * _Nonnull)newVersion;
/** 设置新版本信息 */
- (BOOL)setUpdateVersionInfoBanned:(NSString * _Nonnull)version;
/** 发送更新请求 */
- (BOOL)sendUpdateRequest:(NSString * _Nonnull)url;
@end

