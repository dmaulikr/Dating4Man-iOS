//
//  SiteItemObject.h
//  dating
//
//  Created by Max on 16/2/29.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SiteItemObject : NSObject

/**
 *  LiveChat服务器host
 */
@property (nonatomic, strong) NSString*	host;

/**
 *  LiveChat服务器domain
 */
@property (nonatomic, strong) NSString*	domain;

/**
 *  LiveChat proxy host
 */
@property (nonatomic, strong) NSArray*	proxyHostList;

/**
 *  LiveChat端口
 */
@property (nonatomic, assign) NSInteger	port;

/**
 *  使用LiveChat的最少点数
 */
@property (nonatomic, assign) CGFloat minChat;

/**
 *  使用EMF的最少点数
 */
@property (nonatomic, assign) CGFloat minEmf;

/**
 *  站点可查询女士的国家列表
 */
@property (nonatomic, strong) NSArray* countryList;
@end
