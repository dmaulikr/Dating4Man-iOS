 //
//  ConfigManager.m
//  dating
//
//  Created by Max on 16/2/29.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ConfigManager.h"

@interface ConfigManager () {
    
}
@property (nonatomic, strong) SynConfigItemObject* item;
@property (nonatomic, strong) NSMutableArray* finishHandlers;
@property (nonatomic, assign) NSInteger requestId;

@end

static ConfigManager* gManager = nil;
@implementation ConfigManager
+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if( self = [super init] ) {
        self.item = nil;
        self.finishHandlers = [NSMutableArray array];
        self.requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    return self;
}

- (BOOL)synConfig:(SynConfigFinishHandler _Nullable)finishHandler {
    if( finishHandler ) {
        // 缓存回调
        [self.finishHandlers addObject:finishHandler];
    }
    
    if( self.requestId == HTTPREQUEST_INVALIDREQUESTID ) {
        // 开始获取同步配置
        if( self.item ) {
            // 已经获取成功
            if( self.finishHandlers ) {
                for(SynConfigFinishHandler handler in self.finishHandlers) {
                    handler(YES, self.item, @"", @"");
                }
                
                // 清除所有回调
                [self.finishHandlers removeAllObjects];
            }
            
        } else {
            self.requestId = [[RequestManager manager] synConfig:^(BOOL success, SynConfigItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
                // 接口返回
                self.item = item;
                
                __block NSString* blockErrnum = errnum;
                __block NSString* blockErrmsg = errmsg;
                __block BOOL blockSuccess = success;
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    if( self.finishHandlers ) {
                        for(SynConfigFinishHandler handler in self.finishHandlers) {
                            handler(blockSuccess, self.item, blockErrnum, blockErrmsg);
                        }
                        
                        // 清除所有回调
                        [self.finishHandlers removeAllObjects];
                    }
                    
                    // 请求完成
                    self.requestId = HTTPREQUEST_INVALIDREQUESTID;
                    
                });
            }];
            
            if( self.requestId != HTTPREQUEST_INVALIDREQUESTID ) {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
