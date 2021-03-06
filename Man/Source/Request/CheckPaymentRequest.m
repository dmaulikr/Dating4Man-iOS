//
//  CheckPaymentRequest.m
//  dating
//
//  Created by  Samson on 6/22/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import "CheckPaymentRequest.h"

@implementation CheckPaymentRequest
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
        self.receipt = nil;
        self.orderNo = nil;
        self.code = 0;
        
        self.finishHandler = nil;
    }
    return self;
}

// SessionRequest请求
- (BOOL)sendRequest
{
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        return HTTPREQUEST_INVALIDREQUESTID != [self.manager checkPayment:self.manId sid:self.sid receipt:self.receipt orderNo:self.orderNo code:self.code  finishHandler:^(BOOL success, NSString * _Nonnull code)
        {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
            if( !self.isHandleAlready && self.delegate && [self.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:self handleRespond:success errnum:code errmsg:@""];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag ) {
                weakSelf.finishHandler(success, code);
            }
        }];
    }
    return NO;
}

// SessionRequest重登录完成回调
- (void)callRespond:(BOOL)success errnum:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg
{
    if( nil != self.finishHandler && !success ) {
        self.finishHandler(NO, errnum);
    }
}
@end
