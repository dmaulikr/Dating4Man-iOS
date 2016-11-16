//
//  GetMonthlyFeeRequest.m
//  dating
//
//  Created by lance on 16/8/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "GetMonthlyFeeRequest.h"

@implementation GetMonthlyFeeRequest
- (id)init{
    if (self = [super init]) {
    }
    
    return self;
}

- (BOOL)sendRequest {
    if( self.manager ) {
        return HTTPREQUEST_INVALIDREQUESTID != [self.manager getMonthlyFee:^(BOOL success, NSString * _Nonnull errnum, NSString * _Nonnull errmsg, NSArray * _Nonnull tipsArray) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
            if( !self.isHandleAlready && self.delegate && [self.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:self handleRespond:success errnum:errnum errmsg:errmsg];
                self.isHandleAlready = YES;
            }
            
            if( !bFlag ) {
                self.finishHandler(success, errnum, errmsg,tipsArray);
            }
        }];    }
    
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        NSArray *array = [NSArray array];
        self.finishHandler(NO, errnum, errmsg,array);
    }
}
@end
