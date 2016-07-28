 //
//  ConfigManager.m
//  dating
//
//  Created by Max on 16/2/29.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ConfigManager.h"
#import "UpdateAppManager.h"

typedef enum AlertType {
    AlertTypeDefault,
    AlertTypeForce,
} AlertType;

@interface ConfigManager () {
    
}
@property (nonatomic, strong) SynConfigItemObject* item;
@property (nonatomic, strong) NSMutableArray* finishHandlers;
@property (nonatomic, assign) NSInteger requestId;
@property (nonatomic,strong) UpdateAppManager *updateManager;
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
        self.updateManager = [UpdateAppManager manager];
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
            
            return YES;
            
        } else {
            self.requestId = [[RequestManager manager] synConfig:^(BOOL success, SynConfigItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
                // 接口返回
                __block NSString* blockErrnum = errnum;
                __block NSString* blockErrmsg = errmsg;
                __block BOOL blockSuccess = success;
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    if( self.finishHandlers ) {
                        if( blockSuccess ) {
                            self.item = item;
//                            [self callbackConfigStatus:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
                            
                            // 升级判断
                            self.updateManager.appleStoreUrl = item.pub.iOSStoreUrl;
                            if( item.pub.iOSForceUpdate ) {
                                // 强制更新
                                UIAlertView *forceUpdateAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Update", nil) message:NSLocalizedString(@"Update_Force_Tips", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                                forceUpdateAlertView.tag = AlertTypeForce;
                                [forceUpdateAlertView show];
                                
                            } else {
                                if ([self.updateManager isNewVersionCode:item.pub.iOSVerCode] && [self.updateManager isBanned:item.pub.iOSVerName]) {
                                    // 存在可以升级的版本
                                    [self.updateManager setUpdateVersionInfoBanned:item.pub.iOSVerName];
                                    UIAlertView *updateAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Update", nil) message:NSLocalizedString(@"Update_Tips", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
                                    updateAlertView.tag = AlertTypeDefault;
                                    [updateAlertView show];
                                    
                                } else {
                                    // 没有可以升级的版本, 直接回调
                                    [self callbackConfigStatus:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
                                }

                            }
                            
                        } else {
                            // 没有可以升级的版本, 直接回调
                            [self callbackConfigStatus:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
                        }
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if( alertView.tag == AlertTypeDefault ) {
        // 普通升级
        switch (buttonIndex) {
            case 0:{
                // 升级
                if( self.item.pub.iOSStoreUrl && self.item.pub.iOSStoreUrl.length > 0 ) {
                    [self.updateManager sendUpdateRequest:self.item.pub.iOSStoreUrl];
                }
                
                // 直接回调
                [self callbackConfigStatus:YES errnum:@"" errmsg:@""];
                
            }break;
            case 1:{
                // 取消
                // 直接回调
                [self callbackConfigStatus:YES errnum:@"" errmsg:@""];
                
            }break;
        }
        
    } else if( alertView.tag == AlertTypeForce ) {
        // 强制升级
        if( self.item.pub.iOSStoreUrl && self.item.pub.iOSStoreUrl.length > 0 ) {
            [self.updateManager sendUpdateRequest:self.item.pub.iOSStoreUrl];
        }
        
        // 清空同步配置
        self.item = nil;
        
        // 回调失败
        [self callbackConfigStatus:NO errnum:@"" errmsg:@""];
    }
}

- (void)callbackConfigStatus:(BOOL)success errnum:(NSString *)errnum errmsg:(NSString *)errmsg {
    // 主线程回调
    for(SynConfigFinishHandler handler in self.finishHandlers) {
        handler(success, self.item, errnum, errmsg);
    }
    
    // 清除所有回调
    [self.finishHandlers removeAllObjects];
}

- (void)clean {
    self.item = nil;
}

@end
