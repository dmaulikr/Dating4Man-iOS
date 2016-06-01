//
//  RegisterItemOject.h
//  dating
//
//  Created by lance on 16/3/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <manrequesthandler/item/RegisterItem.h>

@interface RegisterItemObject : NSObject

/** 是否登录成功 */
@property (nonatomic,assign) BOOL login;
/** 用户id */
@property (nonatomic,strong) NSString *manid;
/** email */
@property (nonatomic,strong) NSString *email;
/** firstname */
@property (nonatomic,strong) NSString *firstname;
/** lastname */
@property (nonatomic,strong) NSString *lastname;
/** 跨服务标识 */
@property (nonatomic,strong) NSString *sid;
/** 注册步骤 */
@property (nonatomic,strong) NSString *reg_step;
/** 登录错误代码 */
@property (nonatomic,strong) NSString *errnum;
/** 登录错误代码描述 */
@property (nonatomic,strong) NSString *errtext;
/** 头像url */
@property (nonatomic,strong) NSString *photoURL;
/** 跨服务标识 */
@property (nonatomic,strong) NSString *sessionid;
/** google analytics userID */
@property (nonatomic,strong) NSString *ga_uid;
/** 私密照片发送权限 */
@property (nonatomic,assign) BOOL photosend;
/** 私密照片接收权限 */
@property (nonatomic,assign) BOOL photoreceived;
/** 微视频接收权限 */
@property (nonatomic,assign) BOOL videoreceived;


@end
