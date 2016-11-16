//
//  GetQueryMemberTypeRequest.m
//  dating
//
//  Created by lance on 16/8/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "GetQueryMemberTypeRequest.h"

@implementation GetQueryMemberTypeRequest
- (id)init{
    if (self = [super init]) {
    }
    
    return self;
}

- (BOOL)sendRequest {
    if( self.manager ) {
        return HTTPREQUEST_INVALIDREQUESTID != [self.manager getQueryMemberType:^(BOOL success, NSString * _Nonnull errnum, NSString * _Nonnull errmsg, int memberType) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
            if( !self.isHandleAlready && self.delegate && [self.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:self handleRespond:success errnum:errnum errmsg:errmsg];
                self.isHandleAlready = YES;
            }
            
            if( !bFlag ) {
                self.finishHandler(success, errnum, errmsg,memberType);
            }
            
        }];
    }
    
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        int memberType = 0;
        self.finishHandler(NO, errnum, errmsg,memberType);
    }
}
@end
