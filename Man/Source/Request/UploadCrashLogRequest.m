//
//  UploadCrashLogRequest.m
//  dating
//
//  Created by test on 16/6/20.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "UploadCrashLogRequest.h"

@implementation UploadCrashLogRequest

- (instancetype)init{
    if ( self = [super init]) {
        self.srcDirectory = @"";
        self.tmpDirectory = @"";
    }
    
    return self;
}




- (BOOL)sendRequest {
    if( self.manager ) {
        return HTTPREQUEST_INVALIDREQUESTID != [self.manager uploadCrashLogWithFile:self.srcDirectory tmpDirectory:self.tmpDirectory finishHandler:^(BOOL success, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
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
