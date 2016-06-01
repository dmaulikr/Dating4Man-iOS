//
//  GetQueryLadyListRequest.m
//  dating
//
//  Created by lance on 16/3/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "GetQueryLadyListRequest.h"

@implementation GetQueryLadyListRequest
#pragma mark - 默认状态
- (id)init{
    if (self = [super init]) {
        self.page = 1;
        self.pageSize = 10;
        self.searchWay = SearchTypeDEFAULT;
        self.womanId = @"";
        self.age1 = -11;
        self.age2 = -1;
        self.country = @"";
        self.orderBy = OrderTypeDEFAULT;
        self.onlineStatus = LADY_OFFLINE;
    }
    return self;
}


#pragma mark - 发送请求
- (BOOL)sendRequest {
    if( self.manager ) {
        return HTTPREQUEST_INVALIDREQUESTID != [self.manager getQueryLadyListPageIndex:self.page pageSize:self.pageSize searchType:self.searchWay womanId:self.womanId isOnline:self.onlineStatus ageRangeFrom:self.age1 ageRangeTo:self.age2 country:self.country orderBy:self.orderBy finishHandler:^(BOOL success, NSMutableArray * _Nonnull itemArray, int totalCount, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
                BOOL bFlag = NO;
                // 没有处理过, 才进入SessionRequestManager处理
                if( !self.isHandleAlready && self.delegate && [self.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                    bFlag = [self.delegate request:self handleRespond:success errnum:errnum errmsg:errmsg];
                    self.isHandleAlready = YES;
                }
    
                if( !bFlag ) {
                    self.finishHandler(success, itemArray, totalCount,errnum, errmsg);
                }
        }];
        
        
    }
    
    return NO;
}

- (void)callRespond:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg  pageCount:(int)totalCount{
    if( self.finishHandler ) {
        NSMutableArray* array = [NSMutableArray array];
        self.finishHandler(YES, array, totalCount,errnum, errmsg);
    }
}



@end
