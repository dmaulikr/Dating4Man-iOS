//
//  OtherSynConfigItemObject.h
//  dating
//
//  Created by Max on 16/2/29.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SiteItemObject.h"
#import "PublicItemObject.h"

@interface SynConfigItemObject : NSObject

/**
 *  CL站点
 */
@property (nonatomic, strong) SiteItemObject* cl;

/**
 *  IDA站点
 */
@property (nonatomic, strong) SiteItemObject* ida;

/**
 *  CH站点
 */
@property (nonatomic, strong) SiteItemObject* ch;

/**
 *  LA站点
 */
@property (nonatomic, strong) SiteItemObject* la;

/**
 *  公共配置
 */
@property (nonatomic, strong) PublicItemObject*	pub;

@end
