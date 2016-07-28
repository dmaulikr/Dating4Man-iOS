//
//  GetPaymentOrderRequest.m
//  dating
//
//  Created by  Samson on 6/22/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import "GetPaymentOrderRequest.h"

@implementation GetPaymentOrderRequest
/**
 *  初始化
 *
 *  @return this
 */
- (id)init
{
    self = [super init];
    if (nil != self) {
        self.manId = nil;
        self.sid = nil;
        self.number = nil;
        
        self.finishHandler = nil;
    }
    return self;
}

// SessionRequest请求
- (BOOL)sendRequest
{
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        return HTTPREQUEST_INVALIDREQUESTID != [self.manager getPaymentOrder:self.manId sid:self.sid number:self.number finishHandler:^(BOOL success, NSString * _Nonnull code, NSString * _Nonnull orderNo, NSString * _Nonnull productId)
        {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
            if( !self.isHandleAlready && self.delegate && [self.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:self handleRespond:success errnum:code errmsg:@""];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag ) {
                weakSelf.finishHandler(success, code, orderNo, productId);
            }
            
        }];
    }
    return NO;
}

// SessionRequest重登录完成回调
- (void)callRespond:(BOOL)success errnum:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg
{
    if( nil != self.finishHandler && !success ) {
        self.finishHandler(NO, errnum, @"", @"");
    }
}
@end
