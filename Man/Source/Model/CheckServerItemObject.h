//
//  CheckServerItemObject.h
//  dating
//
//  Created by Max on 16/6/7.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckServerItemObject : NSObject
/**
 *  web域名
 */
@property (strong) NSString* webhost;
/**
 *  app域名
 */
@property (strong) NSString* apphost;
/**
 *  wap域名
 */
@property (strong) NSString* waphost;
/**
 *  支付地址
 */
@property (strong) NSString* pay_api;
/**
 *  支付地址
 */
@property (assign) BOOL fake;
@end
