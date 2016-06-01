//
//  PublicItemObject.h
//  dating
//
//  Created by Max on 16/2/29.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicItemObject : NSObject
/**
 *  虚拟礼物版本号
 */
@property (nonatomic, assign) NSInteger vgVer;

/**
 *  Android客户端内部版本号
 */
@property (nonatomic, assign) NSInteger apkVerCode;

/**
 *  Android客户端版本名称
 */
@property (nonatomic, strong) NSString* apkVerName;

/**
 *  是否强制升级
 */
@property (nonatomic, assign) BOOL apkForceUpdate;

/**
 *  是否开通facebook登录
 */
@property (nonatomic, assign) BOOL facebook_enable;

/**
 *  安装文件检验码
 */
@property (nonatomic, strong) NSString* apkFileVerify;

/**
 *  安装包下载URL
 */
@property (nonatomic, strong) NSString*	apkVerURL;

/**
 *  Store URL
 */
@property (nonatomic, strong) NSString*	apkStoreURL;

/**
 *  LiveChat语音下载/上传
 */
@property (nonatomic, strong) NSString*	chatVoiceHostUrl;

/**
 *  选择点数充值页面URL
 */
@property (nonatomic, strong) NSString*	addCreditsUrl;

/**
 *  指定点数充值页面URL
 */
@property (nonatomic, strong) NSString*	addCredits2Url;	// 指定点数充值页面URL

/**
 *  当前IP对应的国家代码
 */
@property (nonatomic, assign) NSInteger ipcountry;

/**
 *  iOS客户端内部版本号
 */
@property (nonatomic, assign) NSInteger iOSVerCode;

/**
 *  iOS客户端版本名称
 */
@property (nonatomic, strong) NSString* iOSVerName;

/**
 *  iOS是否强制升级
 */
@property (nonatomic, assign) BOOL iOSForceUpdate;

/**
 *  appstore地址
 */
@property (nonatomic, strong) NSString* iOSStoreUrl;

@end
