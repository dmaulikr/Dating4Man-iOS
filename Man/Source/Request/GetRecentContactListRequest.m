//
//  GetRecentContactListRequest.m
//  dating
//
//  Created by Max on 16/3/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "GetRecentContactListRequest.h"

@implementation GetRecentContactListRequest

- (BOOL)sendRequest {
    if( self.manager ) {
        return HTTPREQUEST_INVALIDREQUESTID != [self.manager getRecentContactList:^(BOOL success, NSArray * _Nonnull items, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
            if( !self.isHandleAlready && self.delegate && [self.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:self handleRespond:success errnum:errnum errmsg:errmsg];
                self.isHandleAlready = YES;
            }
            
            if( !bFlag ) {
                self.finishHandler(success, items, errnum, errmsg);
            }
            
        }];
    }
    
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        NSArray* array = [NSArray array];
        self.finishHandler(NO, array, errnum, errmsg);
    }
}
@end
