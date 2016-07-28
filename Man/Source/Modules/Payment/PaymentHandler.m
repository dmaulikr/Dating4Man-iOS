//
//  PaymentHandler.m
//  demo
//
//  Created by  Samson on 6/22/16.
//  Copyright © 2016 Samson. All rights reserved.
//  支付处理器(包括AppStore支付处理和接口请求验证订单处理)

#import "PaymentHandler.h"
#import "SessionRequestManager.h"
#import "AppStorePayHandler.h"
#import "CheckPaymentRequest.h"

@interface PaymentHandler () <AppStorePayHandlerDeleagte>
// 回调
@property (nonatomic, weak) id<PaymentHandlerDelegate> delegate;
// 订单号
@property (nonatomic, strong) NSString* orderNo;
// 产品ID
@property (nonatomic, strong) NSString* productId;
// 男士ID
@property (nonatomic, strong) NSString* manId;
// sid
@property (nonatomic, strong) NSString* sid;
// AppStore支付凭证
@property (nonatomic, strong) NSString* receipt;
// 支付状态
@property (nonatomic, assign) PaymentHandleState state;
// 是否正在处理中
@property (nonatomic, assign) BOOL isHandling;
// 请求管理器
@property (nonatomic, strong) SessionRequestManager* sessionRequestMgr;
// AppStore支付处理器
@property (nonatomic, strong) AppStorePayHandler* appStorePayHandler;

// 不判断是否正在处理的start
- (BOOL)startWithoutHandling;
// 向AppStore支付
- (BOOL)payWithStore;
// 验证支付信息
- (BOOL)checkPayment;
@end

@implementation PaymentHandler
/**
 *  初始化
 *
 *  @param orderNo   订单号
 *  @param productId 产品ID
 *  @param manId     男士ID
 *  @param sid       sid
 *  @param delegate  回调
 *
 *  @return this
 */
- (id _Nullable)initWithOrderNo:(NSString* _Nonnull)orderNo productId:(NSString* _Nonnull)productId manId:(NSString* _Nonnull)manId sid:(NSString* _Nonnull)sid delegate:(id<PaymentHandlerDelegate> _Nonnull)delegate
{
    self = [super init];
    if (nil != self) {
        self.delegate = delegate;
        self.orderNo = orderNo;
        self.productId = productId;
        self.manId = manId;
        self.sid = sid;
        self.state = PaymentHandleStatePayWithStore;
        self.isHandling = NO;
        self.sessionRequestMgr = [SessionRequestManager manager];
    }
    return self;
}

/**
 *  开始支付(或重试)
 *
 *  @return 是否成功
 */
- (BOOL)start
{
    if (!self.isHandling) {
        [self startWithoutHandling];
    }
    return self.isHandling;
}

/**
 *  不判断是否正在处理中的start
 *
 *  @return 是否成功
 */
- (BOOL)startWithoutHandling
{
    // 不是正在处理状态
    switch (self.state) {
        case PaymentHandleStatePayWithStore:
            self.isHandling = [self payWithStore];
            break;
        case PaymentHandleStateCheckPayment:
            self.isHandling = [self checkPayment];
            break;
        case PaymentHandleStateFinish:
            break;
    }
    return self.isHandling;
}

/**
 *  向AppStore支付
 *
 *  @return 处理结果
 */
- (BOOL)payWithStore
{
    self.appStorePayHandler = [[AppStorePayHandler alloc] initWithProductId:self.productId orderNo:self.orderNo manId:self.manId delegate:self];
    [self.appStorePayHandler pay];
    return YES;
}

/**
 *  验证支付信息
 *
 *  @return 处理结果
 */
- (BOOL)checkPayment
{
    CheckPaymentRequest* request = [[CheckPaymentRequest alloc] init];
    request.manId = self.manId;
    request.sid = self.sid;
    request.orderNo = self.orderNo;
    request.receipt = self.receipt;
    request.finishHandler = ^(BOOL success, NSString* _Nonnull code) {
        if (nil != self.delegate) {
            if (success) {
                self.state = PaymentHandleStateFinish;
            }
            self.isHandling = NO;
            BOOL isNetErr = ([code length] == 0);
            [self.delegate updatePaymentState:self state:self.state success:success code:code isNetErr:isNetErr];
        }
    };
    
    return [self.sessionRequestMgr sendRequest:request];
}

#pragma mark - AppStorePayHandlerDeleagte回调
/**
 *  支付完成回调
 *
 *  @param handler 支付处理器
 *  @param result  是否支付成功
 *  @param
 */
- (void)getProductFinish:(AppStorePayHandler* _Nonnull)handler result:(BOOL)result
{
    if (!result) {
        // 获取Product失败
        self.isHandling = NO;
        
        if (nil != self.delegate) {
            [self.delegate updatePaymentState:self state:self.state success:result code:@"" isNetErr:NO];
        }
    }
}

#pragma mark - 更新支付信息
/**
 *  更新AppStore支付信息
 */
- (void)updatedTransactions:(SKPaymentTransaction* _Nonnull)transaction
{
    // 判断是否成功及是否需要回调
    BOOL success = NO;
    BOOL isCallback = YES;
    switch (transaction.transactionState) {
        case SKPaymentTransactionStatePurchased:
            success = YES;
            break;
        case SKPaymentTransactionStateFailed:
        case SKPaymentTransactionStateRestored:
        case SKPaymentTransactionStateDeferred:
            success = NO;
            break;
        case SKPaymentTransactionStatePurchasing:
            success = YES;
            isCallback = NO;
            break;
    }
    
    // 回调
    if (isCallback && nil != self.delegate) {
        [self.delegate updatePaymentState:self state:PaymentHandleStatePayWithStore success:success code:@"" isNetErr:NO];
    }
    
    if (!success) {
        // 支付失败，设置不继续处理
        self.isHandling = NO;
    }
    else if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
        // 支付成功，获取凭证
        self.receipt = [AppStorePayHandler getReceipt];
        
        // 状态设为验证支付信息，继续处理
        self.state = PaymentHandleStateCheckPayment;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startWithoutHandling];
        });
    }
    
    // 设置支付完成(iOS不再回调本支付信息)
    if (isCallback) {
        [AppStorePayHandler finish:transaction];
    }
}
@end
