//
//  UpdateProfileRequest.m
//  dating
//
//  Created by test on 16/5/31.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "UpdateProfileRequest.h"

@implementation UpdateProfileRequest

- (id)init{
    if (self = [super init]) {
        
    }
    
    return self;
}



- (BOOL)sendRequest {
    if( self.manager ) {
        return HTTPREQUEST_INVALIDREQUESTID != [self.manager updateMyProfileWeight:self.weight height:self.height language:self.language ethnicity:self.ethnicity religion:self.religion education:self.education profession:self.profession income:self.income children:self.children smoke:self.smoke drink:self.drink resume:self.resume interests:self.interests finish:^(BOOL success, BOOL motify, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
            
            BOOL bFlag = NO;
            
            // 没有处理过, 才进入SessionRequestManager处理
            if( !self.isHandleAlready && self.delegate && [self.delegate respondsToSelector:@selector(request:handleRespond:errnum:errmsg:)] ) {
                bFlag = [self.delegate request:self handleRespond:success errnum:errnum errmsg:errmsg];
                self.isHandleAlready = YES;
            }
            
            if( !bFlag ) {
                self.finishHandler(success,motify,errnum,errmsg);
            }
        }];
        
        
        
    }
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg {
    if( self.finishHandler && !success ) {
        self.finishHandler(NO, NO, errnum, errmsg);
    }
}


@end
