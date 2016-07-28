//
//  ServerManager.m
//  dating
//
//  Created by Max on 16/6/6.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ServerManager.h"
#import "AnalyticsManager.h"

@interface ServerManager () {
    
}

@property (nonatomic, strong) NSMutableArray* finishHandlers;
@property (nonatomic, assign) NSInteger requestId;

@end

static ServerManager* gManager = nil;

@implementation ServerManager
#pragma mark - 获取实例
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

- (BOOL)checkServer:(NSString * _Nonnull)user finishHandler:(CheckServerFinishHandler _Nullable)finishHandler {
    RequestManager* manager = [RequestManager manager];
    
    if( finishHandler ) {
        // 缓存回调
        [self.finishHandlers addObject:finishHandler];
    }
    
    if( self.requestId == HTTPREQUEST_INVALIDREQUESTID ) {
        // 开始获取服务器
        if( self.item ) {
            // 已经获取成功
            if( self.finishHandlers ) {
                for(CheckServerFinishHandler handler in self.finishHandlers) {
                    handler(YES, self.item, @"", @"");
                }
                
                // 清除所有回调
                [self.finishHandlers removeAllObjects];
            }
            
            return YES;
        } else {
            self.requestId = [[RequestManager manager] checkServer:user finishHandler:^(BOOL success, CheckServerItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
                // 接口返回
                __block NSString* blockErrnum = errnum;
                __block NSString* blockErrmsg = errmsg;
                __block BOOL blockSuccess = success;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if( item.fake ) {
                        // 切换到假的服务器
                        [manager setWebSite:item.webhost appSite:item.apphost];
                    } else {
                        // 切换到真的服务器
                        [AppDelegate() setRequestHost:YES];
                    }
                    
                    // 重新初始化跟踪器
                    [[AnalyticsManager manager] initGoogleAnalytics:!item.fake];
                    
                    if( self.finishHandlers ) {
                        if( blockSuccess ) {
                            self.item = item;
                        }
                        
                        for(CheckServerFinishHandler handler in self.finishHandlers) {
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

- (void)clean {
    self.item = nil;
    
    // 切换假服务器环境
    [AppDelegate() setRequestHost:NO];
}
@end
