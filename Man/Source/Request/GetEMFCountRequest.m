//
//  GetEMFCountRequest.m
//  dating
//
//  Created by alex shum on 16/10/11.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "GetEMFCountRequest.h"

@implementation GetEMFCountRequest


- (instancetype)init{
    if (self = [super init]) {
        
    }
    
    return self;
}

- (BOOL)sendRequest {
    if( self.manager ) {
        return HTTPREQUEST_INVALIDREQUESTID != [self.manager getEMFCount:^(BOOL success, int total, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
            if( !self.isHandleAlready && self.delegate && [self.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:self handleRespond:success errnum:errnum errmsg:errmsg];
                self.isHandleAlready = YES;
            }
            
            if( !bFlag ) {
                self.finishHandler(success, total, errnum, errmsg);
            }
            
        }];
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        self.finishHandler(NO, 0, errnum, errmsg);
    }
}

@end
