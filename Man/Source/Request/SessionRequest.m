//
//  SessionRequest.m
//  dating
//
//  Created by Max on 16/3/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@implementation SessionRequest

- (id)init {
    if( self = [super init] ) {
        self.manager = [RequestManager manager];
        self.isHandleAlready = NO;
    }
    return self;
}

- (BOOL)sendRequest {
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg {
    
}

@end
