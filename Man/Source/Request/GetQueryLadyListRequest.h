//
//  GetQueryLadyListRequest.h
//  dating
//
//  Created by lance on 16/3/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionRequest.h"


/**
 *  获取女士列表接口
 */
typedef enum {
    SearchTypeDEFAULT = 1,
    SearchTypeFAVOURITE,
    SearchTypeBYID,
    SearchTypeBYCONDITION,
    SearchTypeWITHVIDEO,
    SearchTypeWITHPHONE,
    SearchTypeNEWEST
} SearchType;


typedef enum {
    OrderTypeDEFAULT = -1,
    OrderTypeNEWST ,
    OrderTypeAGEUP ,
    OrderTypeAGEDOWN
} OrderType;

@interface GetQueryLadyListRequest : SessionRequest


/** 获取女士列表接口当前页数 */
@property (nonatomic,assign) int page;
/** 设置每页行数 */
@property (nonatomic,assign) int pageSize;
/** 查询类型 */
@property (nonatomic,assign) SearchType searchWay;
/** 女士ID */
@property (nonatomic,strong) NSString * _Nullable womanId;
/** 在线状态 */
@property (nonatomic,assign) LadyOnlineStatus onlineStatus;
/** 起始年龄 */
@property (nonatomic,assign) int age1;
/** 结束年龄 */
@property (nonatomic,assign) int age2;
/** 国家 */
@property (nonatomic,strong) NSString * _Nullable country;
/** 排序 */
@property (nonatomic,assign) OrderType orderBy;


/**
 *  获取女士列表接口
 */

@property (nonatomic, strong) onlineListFinishHandler _Nullable finishHandler;

- (BOOL)sendRequest;

//- (void)callRespond:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg;
- (void)callRespond:(NSString* _Nullable)errnum errmsg:(NSString * _Nullable)errmsg  pageCount:(int)pageCount;

@end
