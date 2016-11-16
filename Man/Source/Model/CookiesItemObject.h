//
//  CookiesItemObject.h
//  dating
//
//  Created by alex on 16/9/29.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CookiesItemObject : NSObject

/** 小高级表情路径 */
@property (nonatomic,strong) NSString *domain;
/** 小高级表情路径 */
@property (nonatomic,strong) NSString *accessOtherWeb;
/** 小高级表情路径 */
@property (nonatomic,strong) NSString *symbol;
/** 小高级表情路径 */
@property (nonatomic,strong) NSString *isSend;
/** 小高级表情路径 */
@property (nonatomic,strong) NSString *expiresTime;
/** 小高级表情路径 */
@property (nonatomic,strong) NSString *cName;
/** 小高级表情路径 */
@property (nonatomic,strong) NSString *value;

//初始化
- (CookiesItemObject *)init;


@end