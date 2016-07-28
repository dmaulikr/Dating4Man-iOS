//
//  ReportLadyRequest.m
//  dating
//
//  Created by  Samson on 7/5/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import "ReportLadyRequest.h"

@implementation ReportLadyRequest
- (id)init{
    if (self = [super init]) {
        self.womanId = nil;
    }
    
    return self;
}

- (BOOL)sendRequest {
    if( self.manager ) {
        return HTTPREQUEST_INVALIDREQUESTID != [self.manager reportLady:self.womanId finishHandler:^(BOOL success, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
            if( !self.isHandleAlready && self.delegate && [self.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:self handleRespond:success errnum:errnum errmsg:errmsg];
                self.isHandleAlready = YES;
            }
            
            if( !bFlag ) {
                self.finishHandler(success, errnum, errmsg);
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
