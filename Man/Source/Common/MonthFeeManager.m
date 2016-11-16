//
//  MonthFeeManager.m
//  dating
//
//  Created by lance on 16/8/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "MonthFeeManager.h"
#import "GetMonthlyFeeRequest.h"
#import "GetQueryMemberTypeRequest.h"
#import "LiveChatManager.h"
#import "LoginManager.h"

@interface MonthFeeManager()<LiveChatManagerDelegate>


/** 任务管理 */
@property (nonatomic,strong) SessionRequestManager *sessionManager;
/**
 *  Livechat管理器
 */
@property (nonatomic, strong) LiveChatManager *liveChatManager;

/**
 *  回调数组
 */
@property (nonatomic, strong) NSMutableArray* delegates;

/** 月费状态 */
@property (nonatomic,assign) int  memberType;

@end



static MonthFeeManager *gManager = nil;
@implementation MonthFeeManager
+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if( self = [super init] ) {
        self.bRequest = NO;
        self.memberType = MonthFeeTypeNoramlMember;
        
        self.delegates = [NSMutableArray array];
        
        self.liveChatManager = [LiveChatManager manager];
        [self.liveChatManager addDelegate:self];
        
    }
    return self;
}


- (void)dealloc {
    [self.liveChatManager removeDelegate:self];
}


- (void)addDelegate:(id<MonthFeeManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)removeDelegate:(id<MonthFeeManagerDelegate>)delegate{
    @synchronized(self.delegates) {
        for(NSValue* value in self.delegates) {
            id<MonthFeeManagerDelegate> item = (id<MonthFeeManagerDelegate>)value.nonretainedObjectValue;
            if( item == delegate ) {
                [self.delegates removeObject:value];
                break;
            }
        }
        
    }
}




- (BOOL)getQueryMemberType {
    // 获取本地用户状态
    if (self.bRequest) {
        [self onGetQueryMemberType:YES errnum:@"" errmsg:@""];
    }else {
        // 重新获取用户状态
        self.sessionManager = [SessionRequestManager manager];
        GetQueryMemberTypeRequest *request = [[GetQueryMemberTypeRequest alloc] init];
        request.finishHandler = ^(BOOL success,NSString *errmun,NSString *errmsg , int memberType) {
            NSLog(@"MonthFeeManager::getQueryMemberType( 获取服务器月费状态, memberType : %d )", memberType);
            
            __block BOOL blockSuccess = success;
            __block NSString *blockErrnum = errmun;
            __block NSString *blockErrmsg = errmsg;
            if (success) {
                self.memberType = memberType;
                self.bRequest = YES;
            }else {
                self.memberType = MonthFeeTypeNoramlMember;
            }
            [self onGetQueryMemberType:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
        };
        
        return [self.sessionManager sendRequest:request];
    }
    return YES;
}


- (BOOL)getMonthFee {
    self.sessionManager = [SessionRequestManager manager];
    GetMonthlyFeeRequest *request = [[GetMonthlyFeeRequest alloc] init];
    request.finishHandler = ^(BOOL success, NSString* _Nonnull errnum, NSString* _Nonnull errmsg, NSArray * _Nonnull tipsArray) {
        NSLog(@"MonthFeeManager::getMonthFee( 获取月费信息, tipsArray : %@)", tipsArray);
        [self onGetgetMonthFee:success errnum:errnum errmsg:errmsg tips:tipsArray];
    };
    
    
    return [self.sessionManager sendRequest:request];
}



- (void)onGetQueryMemberType:(BOOL)success errnum:(NSString *)errnum errmsg:(NSString *)errmsg {

        @synchronized(self.delegates) {
            for(NSValue* value in self.delegates) {
                id<MonthFeeManagerDelegate> delegate = (id<MonthFeeManagerDelegate>)value.nonretainedObjectValue;
                if( [delegate respondsToSelector:@selector(manager:onGetMemberType:errnum:errmsg:memberType:)] ) {
                    [delegate manager:self onGetMemberType:success errnum:errnum errmsg:errmsg memberType:self.memberType];
                }
            }
        }
 
}


- (void)onGetgetMonthFee:(BOOL)success errnum:(NSString *)errnum errmsg:(NSString *)errmsg tips:(NSArray *)tipsArray {
    // 主线程回调
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self.delegates) {
            for(NSValue* value in self.delegates) {
                id<MonthFeeManagerDelegate> delegate = (id<MonthFeeManagerDelegate>)value.nonretainedObjectValue;
                if( [delegate respondsToSelector:@selector(manager:onGetMonthFee:errnum:errmsg:tips:)] ) {
                    [delegate manager:self onGetMonthFee:success errnum:errnum errmsg:errmsg tips:tipsArray];
                }
            }
        }
    });
}

#pragma mark - LivechatManager回调
- (void)OnLogin:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg isAutoLogin:(BOOL)isAutoLogin {
    if( isAutoLogin && errType == LCC_ERR_SUCCESS ) {
        self.bRequest = NO;
        [self getQueryMemberType];
        
    }
}

@end
