//
//  AddFavouriteLadyRequest.m
//  dating
//
//  Created by test on 16/4/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "AddFavouriteLadyRequest.h"

@implementation AddFavouriteLadyRequest
- (id)init{
    if (self = [super init]) {
        self.womanId = nil;
    }
    
    return self;
}



- (BOOL)sendRequest {
    if( self.manager ) {
        __weak typeof(self) weakSelf = self;
        return HTTPREQUEST_INVALIDREQUESTID != [self.manager addFavouritesLadyWithWomanId:self.womanId finishHandler:^(BOOL success, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
            if( !self.isHandleAlready && self.delegate && [self.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:self handleRespond:success errnum:errnum errmsg:errmsg];
                weakSelf.isHandleAlready = YES;
            }
            
            if( !bFlag ) {
                weakSelf.finishHandler(success, errnum, errmsg);
            }
            
        }];
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        self.finishHandler(NO, errnum, errmsg);
    }
}

@end
