//
//  RequestManager.h
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <httpclient/HttpRequestDefine.h>

#import "RequestErrorCode.h"

#import "LoginItemObject.h"
#import "RegisterItemObject.h"

#import "LadyRecentContactObject.h"
#import "LadyDetailItemObject.h"
#import "QueryLadyListItemObject.h"
#import "VideoItemObject.h"
#import "PersonalProfile.h"
#import "SynConfigItemObject.h"
#import "OtherGetCountItemObject.h"
#import "CheckServerItemObject.h"

@interface RequestManager : NSObject
@property (nonatomic, strong) NSString* _Nonnull versionCode;
#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

#pragma mark - 公共模块
/**
 *  设置是否打印日志
 *
 *  @param enable <#enable description#>
 */
- (void)setLogEnable:(BOOL)enable;

/**
 *  设置接口目录
 *
 *  @param directory 可写入目录
 */
- (void)setLogDirectory:(NSString * _Nonnull)directory;

///**
// *  设置应用版本号
// *
// *  @param version 应用版本号
// */
//- (void)setVersionCode:(NSString * _Nonnull)version;

/**
 *  设置接口服务器域名
 *
 *  @param webSite Web接口服务器域名
 *  @param appSite App接口服务器域名
 */
- (void)setWebSite:(NSString * _Nonnull)webSite appSite:(NSString * _Nonnull)appSite;

/**
 *  设置假服务器域名
 *
 *  @param fakeSite 假服务器域名
 */
- (void)setFakeSite:(NSString * _Nonnull)fakeSite;

/**
 *  获取Web服务器域名
 */
- (NSString * _Nonnull)getWebSite;
/**
 *  获取app接口域名
 */
- (NSString * _Nonnull)getAppSite;

/**
 *  设置语音服务器域名
 *
 *  @param pubSite 语音服务器域名
 */
- (void)setVoiceSite:(NSString * _Nonnull)voiceSite;

/**
 *  设置接口服务器用户认证
 *
 *  @param user     用户名
 *  @param password 密码
 */
- (void)setAuthorization:(NSString * _Nonnull)user password:(NSString * _Nonnull)password;

/**
 *  清除Cookies
 */
- (void)cleanCookies;

/**
 *  根据域名获取Cookies
 *
 *  @param site 域名
 */
- (void)getCookies:(NSString * _Nonnull)site;

/**
 *  停止请求接口
 *
 *  @param requestId 请求Id
 */
- (void)stopRequest:(NSInteger)requestId;

/**
 *  停止所有请求接口
 *
 */
- (void)stopAllRequest;

/**
 *  获取设备Id
 *
 *  @return 设备Id
 */
- (NSString * _Nonnull)getDeviceId;

#pragma mark - 真假服务器模块
/**
 *  获取服务器接口回调
 *
 *  @param success 成功失败
 *  @param item    成功Item
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^CheckServerFinishHandler)(BOOL success, CheckServerItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg);

/**
 *  获取服务器接口
 *
 *  @param user          用户
 *  @param finishHandler 接口回调
 *
 *  @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)checkServer:(NSString * _Nonnull)user finishHandler:(CheckServerFinishHandler _Nullable)finishHandler;

#pragma mark - 登陆认证模块
/**
 *  登陆接口回调
 *
 *  @param success 成功失败
 *  @param item    成功Item
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^LoginFinishHandler)(BOOL success, LoginItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg);

/**
 *  登陆接口
 *
 *  @param user          用户
 *  @param password      密码
 *  @param checkcode     验证码
 *  @param finishHandler 接口回调
 *
 *  @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)login:(NSString * _Nonnull)user password:(NSString * _Nonnull)password checkcode:(NSString * _Nonnull)checkcode finishHandler:(LoginFinishHandler _Nullable)finishHandler;

/**
 *  获取验证码接口回调
 *
 *  @param success 成功失败
 *  @param data    验证码图片二进制流
 *  @param len     验证码图片二进制流长度
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^GetCheckCodeFinishHandler)(BOOL success, const char * _Nullable data, int len, NSString * _Nonnull errnum, NSString * _Nonnull errmsg);

/**
 *  获取验证码接口
 *
 *  @param finishHandler 接口回调
 *
 *  @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)getCheckCode:(GetCheckCodeFinishHandler _Nullable)finishHandler;


#pragma mark - 注册模块
/**
 *  注册接口回调
 *
 *  @param success 成功失败
 *  @param item    成功Item
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^registerFinishHandler)(BOOL success, RegisterItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg);
/* 注册接口
 * @param user				账号
 * @param password			密码
 * @param male				性别, true:男性/false:女性
 * @param firstname         用户firstname
 * @param lastname			用户lastname
 * @param country			国家区号,参考数组<CountryArray>
 * @param birthday_y		生日的年
 * @param birthday_m		生日的月
 * @param birthday_d		生日的日
 * @param weeklymail		是否接收订阅
 * @param model				移动设备型号
 * @param deviceId			设备唯一标识
 * @param manufacturer		制造厂商
 * @param referrer			app推广参数（安装成功app第一次运行时GooglePlay返回）
 * @param finishHandler     接口回调
 *
 * @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)registerUser:(NSString * _Nonnull)user
                 password:(NSString * _Nonnull)password
                      sex:(BOOL)isMale
                firstname:(NSString * _Nonnull)firstname
                 lastname:(NSString * _Nonnull)lastname
                  country:(int)country
               birthday_y:(NSString * _Nonnull)birthday_y
               birthday_m:(NSString * _Nonnull)birthday_m
               birthday_d:(NSString * _Nonnull)birthday_d
               weeklymail:(BOOL)isWeeklymail
            finishHandler:(registerFinishHandler _Nullable)finishHandler;




#pragma mark - 个人资料模块

/**
 *  获取男士个人资料回调
 *
 *  @param success 成功
 *  @param item    男士资料
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^getMyProfileFinishHandler)(BOOL success,PersonalProfile * _Nonnull item ,NSString * _Nonnull errnum, NSString * _Nonnull errmsg);

/**
 *  获取男士个人资料
 *
 *  @param finishHandler 接口回调
 *
 * @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)getMyProfileFinishHandler:(getMyProfileFinishHandler  _Nullable)finishHandler;

/**
 *  更新男士个人资料回调
 *
 *  @param success 成功
 *  @param motify  是否修改
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^updateMyProfileFinishHandler)(BOOL success,BOOL motify ,NSString * _Nonnull errnum, NSString * _Nonnull errmsg);

/**
 *  更新男士资料
 *
 *  @param weight        体重
 *  @param height        高度
 *  @param language      语言
 *  @param ethnicity     人种
 *  @param religion      宗教
 *  @param education     教育程度
 *  @param profession    职业
 *  @param income        收入
 *  @param children      孩子
 *  @param smoke         吸烟
 *  @param drink         喝酒
 *  @param resume        详情
 *  @param interests     兴趣爱好
 *  @param finishHandler 接口回调
 *
 * @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)updateMyProfileWeight:(int)weight
                      height:(int)height
                    language:(int)language
                   ethnicity:(int)ethnicity
                    religion:(int)religion
                   education:(int)education
                  profession:(int)profession
                      income:(int)income
                    children:(int)children
                       smoke:(int)smoke
                       drink:(int)drink
                      resume:(NSString * _Nonnull)resume
                   interests:(NSMutableArray * _Nonnull) interests
                      finish:(updateMyProfileFinishHandler _Nullable)finishHandler;

/**
 *  开始编辑男士资料详情
 *
 *  @param success 成功
 *  @param errnum  错误编码
 *  @param errmsg  错误信息
 */
typedef void (^startEditResumeFinishHandler)(BOOL success, NSString * _Nonnull errnum, NSString * _Nonnull errmsg);
/**
 *  开始编辑男士详情
 *
 *  @param finishHandler 接口回调
 *
 * @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)startEditResumeFinishHandler:(startEditResumeFinishHandler _Nullable)finishHandler;


/**
 *  上传接口回调
 *
 *  @param success 成功失败
 *  @param
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^uploadHeaderPhotoFinishHandler)(BOOL success, NSString * _Nonnull errnum, NSString * _Nonnull errmsg);


/* 上传接口
 * @param fileName 文件名称
 *
 */
- (NSInteger)uploadHeaderPhoto:(NSString * _Nonnull)fileName finishHandler:(uploadHeaderPhotoFinishHandler _Nullable)finishHandler;



#pragma mark - 女士模块
/**
 *  获取最近联系人接口回调
 *
 *  @param success 成功失败
 *  @param items   最近联系人列表 LadyRecentContactObject
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^RecentContactListFinishHandler)(BOOL success, NSArray * _Nonnull items, NSString * _Nonnull errnum, NSString * _Nonnull errmsg);

/**
 *  获取最近联系人接口
 *
 *  @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)getRecentContactList:(RecentContactListFinishHandler _Nullable)finishHandler;



/**
 *  移除联系人接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^removeContactLishFinishHandler)(BOOL success, NSString * _Nonnull errnum, NSString * _Nonnull errmsg);

/**
 *  移除联系人列表接口
 *
 *  @param womanIdArray  移除联系人的id
 *
 *
 *  @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)removeContactListWithWomanId:(NSArray * _Nonnull)womanIdArray finishHandler:(removeContactLishFinishHandler _Nullable)finishHandler;

typedef void(^addFavouritesLadyFinishHandler)(BOOL success, NSString * _Nonnull errnum, NSString * _Nonnull errmsg);


/**
 *  添加收藏女士
 *
 *  @param womanId       女士id
 *
 *
 *  @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)addFavouritesLadyWithWomanId:(NSString * _Nonnull)womanId finishHandler:(addFavouritesLadyFinishHandler _Nullable)finishHandler;


typedef void(^removeFavouritesLadyFinishHandler)(BOOL success, NSString * _Nonnull errnum, NSString * _Nonnull errmsg);

/**
 *  移除收藏女士
 *
 *  @param womanId       女士id
 *
 *
 *  @return 成功:请求Id/失败:无效Id
 */

- (NSInteger)removeFavouritesLadyWithWomanId:(NSString * _Nonnull)womanId finishHandler:(removeFavouritesLadyFinishHandler _Nullable)finishHandler;

typedef void(^reportLadyFinishHandler)(BOOL success, NSString* _Nonnull errnum, NSString* _Nonnull errmsg);
/**
 *  举报女士
 *
 *  @param womanId 女士id
 *
 *  @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)reportLady:(NSString* _Nonnull)womanId finishHandler:(reportLadyFinishHandler _Nullable)finishHandler;


#pragma mark - online列表
typedef void (^onlineListFinishHandler)(BOOL success, NSMutableArray * _Nonnull itemArray,int totalCount,NSString * _Nonnull errnum, NSString * _Nonnull errmsg);


- (NSInteger)getQueryLadyListPageIndex:(int)pageIndex
                             pageSize:(int)pageSize
                           searchType:(int)searchType
                              womanId:(NSString * _Nonnull)womanId
                             isOnline:(int)isOnline
                         ageRangeFrom:(int)ageRangeFrom
                           ageRangeTo:(int)ageRangeTo
                              country:(NSString * _Nonnull)country
                              orderBy:(int)orderBy
                           genderType:(LadyGenderType)genderType
                        finishHandler:(onlineListFinishHandler _Nullable)finishHandler;

#pragma mark - 女士详细列表
typedef void (^LadyDetailFinishHandler)(BOOL success, LadyDetailItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg);

- (NSInteger)getLadyDetailWithWomanId:(NSString * _Nonnull)womanId finishHandler:(LadyDetailFinishHandler _Nullable)finishHandler;


#pragma mark - 其他模块
/**
 *  同步配置接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^SynConfigFinishHandler)(BOOL success, SynConfigItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg);

- (NSInteger)synConfig:(SynConfigFinishHandler _Nullable)finishHandler;

/**
 *  统计男士数据接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^GetCountFinishHandler)(BOOL success, OtherGetCountItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg);

- (NSInteger)getCount:(GetCountFinishHandler _Nullable)finishHandler;

/**
 *  收集程序崩溃数据
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^UploadCrashLogFinishHandler)(BOOL success, NSString * _Nonnull errnum, NSString * _Nonnull errmsg);

- (NSInteger)uploadCrashLogWithFile:(NSString * _Nonnull)srcDirectory tmpDirectory:(NSString * _Nonnull)tmpDirectory finishHandler:(UploadCrashLogFinishHandler _Nullable)finishHandler;

#pragma mark - 支付
/**
 *  获取订单信息接口回调
 *
 *  @param success   成功失败
 *  @param code      错误码
 *  @param orderNo   订单号
 *  @param productId 产品号
 */
typedef void (^GetPaymentOrderFinishHandler)(BOOL success, NSString* _Nonnull code, NSString* _Nonnull orderNo, NSString* _Nonnull productId);

- (NSInteger)getPaymentOrder:(NSString* _Nonnull)manId sid:(NSString* _Nonnull)sid number:(NSString* _Nonnull)number finishHandler:(GetPaymentOrderFinishHandler _Nullable)finishHandler;

/**
 *  验证订单信息
 *
 *  @param success 成功失败
 *  @param code    错误码
 */
typedef void (^CheckPaymentFinishHandler)(BOOL success, NSString* _Nonnull code);

- (NSInteger)checkPayment:(NSString* _Nonnull)manId sid:(NSString* _Nonnull)sid receipt:(NSString* _Nonnull)receipt orderNo:(NSString* _Nonnull)orderNo finishHandler:(CheckPaymentFinishHandler _Nullable)finishHandler;

@end
