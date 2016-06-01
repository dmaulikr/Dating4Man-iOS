//
//  QueryLadyListItemObject.h
//  dating
//
//  Created by lance on 16/3/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <manrequesthandler/item/Lady.h>

@interface QueryLadyListItemObject : NSObject

/** 年龄 */
@property (nonatomic,assign) int age;
/** 女士ID */
@property (nonatomic,strong) NSString *womanid;
/** 女士first name */
@property (nonatomic,strong) NSString *firstname;
/** 重量 */
@property (nonatomic,strong) NSString *weight;
/** 高度 */
@property (nonatomic,strong) NSString *height;
/** 国家 */
@property (nonatomic,strong) NSString *country;
/** 省份 */
@property (nonatomic,strong) NSString *province;
/** 图片URL */
@property (nonatomic,strong) NSString *photoURL;
/** 在线状态 */
@property (nonatomic,assign) LadyOnlineStatus onlineStatus;
@end
