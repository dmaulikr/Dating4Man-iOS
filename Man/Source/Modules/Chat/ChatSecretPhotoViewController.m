//
//  ChatSecretPhotoViewController.m
//  dating
//
//  Created by test on 16/7/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatSecretPhotoViewController.h"
#import "AddCreditsViewController.h"

#import "LiveChatManager.h"
#import "RequestErrorCode.h"

#import "MonthFeeManager.h"
#import "PaymentManager.h"
#import "PaymentErrorCode.h"
#import "PZPhotoView.h"

typedef enum : NSUInteger {
    SecretPhotoStatusNormal,
    SecretPhotoStatusFee,
} SecretPhotoStatus;

typedef enum AlertType {
    AlertTypeDefault = 100000,
    AlertTypeAppStorePay,
    AlertTypeCheckOrder,
    AlertTypeBuyMonthFee
} AlertType;

@interface ChatSecretPhotoViewController ()<LiveChatManagerDelegate, UIAlertViewDelegate, UIActionSheetDelegate,MonthFeeManagerDelegate,PaymentManagerDelegate,PZPhotoViewDelegate>

@property (nonatomic, strong) LiveChatManager *liveChatManager;
/** 私密照状态 */
@property (nonatomic,assign) SecretPhotoStatus status;
/** 私密照数据 */
@property (nonatomic,strong) UIImage *secretPhotoImage;
/**
 *  点击手势
 */
@property (strong) UIPinchGestureRecognizer* pinch;

/**
 *  当前获取图片
 */
@property (assign) GETPHOTO_PHOTOSIZE_TYPE photoSizeType;
/**
 *  支付管理器
 */
@property (nonatomic, strong) PaymentManager* paymentManager;
/** 月费类型 */
@property (nonatomic,assign) MonthFeeType memberType;
/**
 *  月费管理器
 */
@property (nonatomic, strong) MonthFeeManager *monthFeeManager;
/**
 *  当前支付订单号
 */
@property (nonatomic, strong) NSString* orderNo;
/** 可滚动距离 */
@property (nonatomic,strong) PZPhotoView *imageScrollViewPhoto;
@end

@implementation ChatSecretPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    if( !self.viewDidAppearEver ) {
        CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        UIImageView *secretImageView = [[UIImageView alloc] initWithFrame:frame];
        secretImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        secretImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.secretImageView = secretImageView;
        [self.view insertSubview:self.secretImageView atIndex:0];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        self.view.multipleTouchEnabled = YES;
        [self.view addGestureRecognizer:tap];
        self.view.userInteractionEnabled = YES;
        
        // 显示可缩放的清晰图
        PZPhotoView *imagePhoto = [[PZPhotoView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [imagePhoto prepareForReuse];
        imagePhoto.photoViewDelegate = self;
        [self.view insertSubview:imagePhoto atIndex:0];
        self.imageScrollViewPhoto = imagePhoto;
        
        
        // 根据付费状态设置显示状态
        self.status = self.msgItem.secretPhoto.isGetCharge?SecretPhotoStatusFee:SecretPhotoStatusNormal;
        
        // 如果已经付费
        if( self.msgItem.secretPhoto.isGetCharge ) {
            if( !self.secretImageView.image ) {
                // 清晰图不存在, 直接下载
                [self downSecretPhotoAction:nil];
            }
        }
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.monthFeeManager removeDelegate:self];
    [self.paymentManager removeDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.monthFeeManager = [MonthFeeManager manager];
    [self.monthFeeManager addDelegate:self];
    
    [self.monthFeeManager getQueryMemberType];
    
    self.paymentManager = [PaymentManager manager];
    [self.paymentManager addDelegate:self];
    
}

#pragma mark - 界面初始化
- (void)setupContainView {
    [super setupContainView];
    
    self.buyBtn.layer.cornerRadius = 5.0f;
    self.buyBtn.layer.masksToBounds = YES;
    
    self.downBtn.layer.cornerRadius = 5.0f;
    self.downBtn.layer.masksToBounds = YES;
}

- (void)hideDownControll {
    self.downBtn.hidden = YES;
    self.downTip.hidden = YES;
}

- (void)showDownControll {
    self.downBtn.hidden = NO;
    self.downTip.hidden = NO;
}

- (void)hideBuyControll {
    self.creditTip.hidden = YES;
    self.buyBtn.hidden = YES;
}

- (void)showBuyControll {
    self.creditTip.hidden = NO;
    self.buyBtn.hidden = NO;
}

- (void)initCustomParam {
    [super initCustomParam];
    self.liveChatManager = [LiveChatManager manager];
    [self.liveChatManager addDelegate:self];
    self.backTitle = NSLocalizedString(@"SecretPhoto", nil);
}

- (void)dealloc {
    [self.liveChatManager removeDelegate:self];
}

#pragma mark - 购买状态
- (void)setStatus:(SecretPhotoStatus)status {
    // 显示描述
    self.fileName.text = self.msgItem.secretPhoto.photoDesc;
    
    switch (status) {
        case SecretPhotoStatusNormal:{
            // 没付费状态(收到的图片)
            // 显示模糊图
            NSData *data = [NSData dataWithContentsOfFile:self.msgItem.secretPhoto.showFuzzyFilePath];
            self.secretImageView.image = [UIImage imageWithData:data];
            if( self.secretImageView.image != nil ) {
                // 图片已经存在
                // 显示购买按钮, 提示信息
                [self showBuyControll];
                
            } else {
                // 获取模糊图, 显示菊花
                [self showLoading];
                self.view.userInteractionEnabled = YES;

                [self.liveChatManager getPhoto:self.msgItem.fromId photoId:self.msgItem.secretPhoto.photoId sizeType:GPT_ORIGINAL sendType:self.msgItem.sendType];
                
            }
        }break;
        case SecretPhotoStatusFee:{
            // 付费状态
            // 隐藏购买控件
            [self hideBuyControll];
            [self hideDownControll];
            
            // 显示清晰图
            self.secretImageView.image = nil;
            if( self.msgItem.secretPhoto.srcFilePath.length > 0 ) {
                NSData *data = [NSData dataWithContentsOfFile:self.msgItem.secretPhoto.srcFilePath];
                self.secretImageView.image = [UIImage imageWithData:data];
            }
//            else if (self.msgItem.secretPhoto.showFuzzyFilePath > 0) {
//                NSData *data = [NSData dataWithContentsOfFile:self.msgItem.secretPhoto.showFuzzyFilePath];
//                self.secretImageView.image = [UIImage imageWithData:data];
//                [self showLoading];
//                self.view.userInteractionEnabled = YES;
//            }
            
            if( self.secretImageView.image ) {
                // 增加手势
                [self hideLoading];

                self.secretImageView.hidden = YES;
                // 清晰图添加加缩放功能
                [self.imageScrollViewPhoto setImage:self.secretImageView.image];
                self.imageScrollViewPhoto.imageViewContentMode = UIViewContentModeScaleAspectFit;
                
                
            } else {
                // 显示下载控件
                [self showDownControll];
                NSData *data = [NSData dataWithContentsOfFile:self.msgItem.secretPhoto.showFuzzyFilePath];
                self.secretImageView.image = [UIImage imageWithData:data];
//                [self showLoading];
                self.view.userInteractionEnabled = YES;
            }
            
        }break;
            
        default:
            break;
    }
}

#pragma mark - 界面事件
- (IBAction)buySecretPhotoAction:(id)sender {
    // 点击购买图片
    [self hideBuyControll];
    
    // 显示菊花
    [self showLoading];
    self.view.userInteractionEnabled = YES;
    
    if( ![self.liveChatManager PhotoFee:self.msgItem.fromId mphotoId:self.msgItem.secretPhoto.photoId] ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideLoading];
            [self showBuyControll];
        });
    }
    
}

- (IBAction)downSecretPhotoAction:(id)sender {
    // 点击下载图片
    [self hideDownControll];
    
    if (self.msgItem.sendType == LCMessageItem::SendType_Send) {
        // 获取付费图片(自己发的图片), 显示菊花
        [self showLoading];
        self.view.userInteractionEnabled = YES;
        [self.liveChatManager getPhoto:self.msgItem.toId photoId:self.msgItem.secretPhoto.photoId sizeType:GPT_ORIGINAL sendType:self.msgItem.sendType];
    } else {
        // 获取付费图片(收到的图片), 显示菊花
        [self showLoading];
        self.view.userInteractionEnabled = YES;
        [self.liveChatManager getPhoto:self.msgItem.fromId photoId:self.msgItem.secretPhoto.photoId sizeType:GPT_ORIGINAL sendType:self.msgItem.sendType];
    }
}

/**
 *  下载图片写入相册
 *
 *
 */
- (IBAction)saveSecretPhotoAction:(id)sender {
    self.secretImageView.userInteractionEnabled = NO;
    if (self.secretImageView.image) {
        UIImageWriteToSavedPhotosAlbum(self.secretImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

/**
 *  保存图片下载完成回调
 *
 *  @param image       图片
 *  @param error       成功信息
 *  @param contextInfo 信息内容
 */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *successMsg = NSLocalizedStringFromSelf(@"Photo_Successful_Save");
    NSString *errorMsg = NSLocalizedStringFromSelf(@"Photo_Error");
    if (nil == error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:successMsg delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil ,nil];
        [alert show];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil,nil];
        [alert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSInteger tag = alertView.tag;
    
    switch (tag) {
        case AlertTypeDefault: {
            // 点击普通提示
        }break;
        case AlertTypeAppStorePay: {
            // Apple支付中
            switch (buttonIndex) {
                case 0:{
                    // 点击取消
                    [self cancelPay];
                    
                }break;
                case 1:{
                    // 点击重试
                    [self showLoading];
                    [self.paymentManager retry:self.orderNo];
                    
                }break;
                default:
                    break;
            }
        }break;
        case AlertTypeCheckOrder: {
            // 账单验证中
            switch (buttonIndex) {
                case 0:{
                    // 点击取消, 自动验证
                    [self.paymentManager autoRetry:self.orderNo];
                    [self cancelPay];
                    
                }break;
                case 1:{
                    // 点击重试, 手动验证
                    [self showLoading];
                    [self.paymentManager retry:self.orderNo];
                    
                }break;
                default:
                    break;
            }
        }
        case AlertTypeBuyMonthFee:{
            switch (buttonIndex) {
                case 0:{
                }break;
                case 1:{
                    [self showLoading];
                    [self.paymentManager pay:@"SP2010"];
                    
                }break;
                default:
                    break;
            }
            
        }
        default:
            break;
    }
    
}

#pragma mark - 手势回调
- (void)pinchAction:(UIPinchGestureRecognizer *)recognizer{
    // 对图片进行缩放
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    
    recognizer.scale = 1;
    
    if (recognizer.view.transform.a < 1 && recognizer.view.transform.d < 1) {
        [UIView animateWithDuration:(1)
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn|
         UIViewAnimationOptionAllowUserInteraction|
         UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self.view.layer setAffineTransform:CGAffineTransformMakeScale(recognizer.view.transform.a, recognizer.view.transform.d)];
                         } completion:^(BOOL finished){
                             [UIView animateWithDuration:(1)
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseOut|
                              UIViewAnimationOptionAllowUserInteraction|
                              UIViewAnimationOptionBeginFromCurrentState
                                              animations:^{
                                                  //                                                  CGFloat transfromA = recognizer.view.transform.a;
                                                  
                                                  //                                                  [self.view.layer setAffineTransform:CGAffineTransformMakeScale(recognizer.view.transform.a, recognizer.view.transform.d)];
                                                  [self.view.layer setAffineTransform:CGAffineTransformMakeScale(1, 1)];
                                              }completion:nil];
                         }];
        
    }
    //    NSLog(@"transform %@",NSStringFromCGAffineTransform(recognizer.view.transform));
    //    NSLog(@"transform %f",self.secretImageView.frame.size.height);
    //    self.secretImageView.center = self.imageScrollView.center;
    //    self.imageScrollView.contentSize = CGSizeMake(self.view.frame.size.width * recognizer.view.transform.a, self.secretImageView.frame.size.height * recognizer.view.transform.d);
    //
    //    NSLog(@" UIScreen %@",NSStringFromCGSize(CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)));
    //    NSLog(@" contentSize %@",NSStringFromCGSize(self.imageScrollView.contentSize));
}


- (void)dismiss {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - 私密照回调
- (void)onGetPhoto:(LCC_ERR_TYPE)errType errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg msgList:(NSArray<LiveChatMsgItemObject*>* _Nonnull)msgList sizeType:(GETPHOTO_PHOTOSIZE_TYPE)sizeType {
    dispatch_async(dispatch_get_main_queue(), ^{
        for(LiveChatMsgItemObject* msgItem in msgList) {
            if( [msgItem.secretPhoto.photoId isEqualToString:self.msgItem.secretPhoto.photoId] ) {
                NSLog(@"ChatSecretPhotoViewController::onGetPhoto( 获取私密照 errType : %d, msgItem.msgId : %ld )", errType, (long)msgItem.msgId);
                
                // 停止菊花
                [self hideLoading];
                
                if (sizeType == GPT_ORIGINAL) {
                    // 保存数据
                    self.msgItem = msgItem;
                    
                    // 根据付费状态设置显示状态
                    self.status = self.msgItem.secretPhoto.isGetCharge?SecretPhotoStatusFee:SecretPhotoStatusNormal;
                    
                }
            }
        }
        
    });
}

- (void)onPhotoFee:(bool)success errNo:(NSString *)errNo errMsg:(NSString *)errMsg msgItem:(LiveChatMsgItemObject *)msgItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [msgItem.secretPhoto.photoId isEqualToString: self.msgItem.secretPhoto.photoId] ) {
            NSLog(@"ChatSecretPhotoViewController::onPhotoFee( 获取收费私密照 success : %d, path : %@ )", success, msgItem.secretPhoto.showSrcFilePath);
            // 保存数据
            self.msgItem = msgItem;
            
            // 停止菊花
            [self hideLoading];
            
            if( success ) {
                // 根据付费状态设置显示状态
                self.status = self.msgItem.secretPhoto.isGetCharge?SecretPhotoStatusFee:SecretPhotoStatusNormal;
                
                // 购买成功, 自动点击下载
                [self downSecretPhotoAction:nil];
                
            } else {
                if( [errNo isEqualToString:LIVECHAT_NO_MONEY] ) {
                    // 弹出买点
                    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringFromSelf(@"Add_More_Credits"), nil];
                    [sheet showInView:self.view];
                    
                } else {
                    // 直接提示错误信息
                    NSString* tips = NSLocalizedStringFromErrorCode(errNo);
                    if( tips.length == 0) {
                        tips = errMsg;
                    }
                    
                    if( tips.length == 0 ) {
                        tips = NSLocalizedStringFromSelf(@"Send_Error_Tips_Other");
                    }
                    
                    // 弹出重试
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Close", nil), nil];
                    [alertView show];
                }
            }
            
        }
    });
}

#pragma mark - 底部弹出选择器回调
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self showBuyControll];
    if( buttonIndex != actionSheet.cancelButtonIndex ) {
        
        switch (self.memberType) {
            case MonthFeeTypeNoramlMember:
            case MonthFeeTypeFeeMember:{
                // 跳转买点
                AddCreditsViewController *vc = [[AddCreditsViewController alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:vc animated:YES];
            }break;
            case MonthFeeTypeNoFirstFeeMember:
            case MonthFeeTypeFirstFeeMember:{
                //                NSString *tips = NSLocalizedStringFromSelf(@"Tips_Buy_MonthFee");
                NSString *price = NSLocalizedString(@"Tips_MonthFee_Price", nil);
                NSString *tips = [NSString stringWithFormat:NSLocalizedString(@"Tips_Buy_MonthFee", nil),price];
                UIAlertView *monthFeeAlertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                monthFeeAlertView.tag = AlertTypeBuyMonthFee;
                [monthFeeAlertView show];
            }break;
            default:
                break;
        }
        
        //        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)reloadMsgItem:(LiveChatMsgItemObject *)msgItem {
    self.msgItem = msgItem;
}





#pragma mark - 支付模块
- (void)cancelPay {
    self.orderNo = nil;
}

- (NSString* )messageTipsFromErrorCode:(NSString *)errorCode defaultCode:(NSString *)defaultCode {
    // 默认错误
    NSString* messageTips = NSLocalizedStringFromSelf(defaultCode);
    
    if(
       [errorCode isEqualToString:PAY_ERROR_OVER_CREDIT_20038] ||
       [errorCode isEqualToString:PAY_ERROR_CAN_NOT_ADD_CREDIT_20043] ||
       [errorCode isEqualToString:PAY_ERROR_INVALID_MONTHLY_CREDIT_40005] ||
       [errorCode isEqualToString:PAY_ERROR_REQUEST_SAMETIME_50000]
       ) {
        // 具体错误
        messageTips = NSLocalizedStringFromSelf(errorCode);
        
    } else if(
              [errorCode isEqualToString:PAY_ERROR_NORMAL] ||
              [errorCode isEqualToString:PAY_ERROR_10003] ||
              [errorCode isEqualToString:PAY_ERROR_10005] ||
              [errorCode isEqualToString:PAY_ERROR_10006] ||
              [errorCode isEqualToString:PAY_ERROR_10007] ||
              [errorCode isEqualToString:PAY_ERROR_20014] ||
              [errorCode isEqualToString:PAY_ERROR_20015] ||
              [errorCode isEqualToString:PAY_ERROR_20030] ||
              [errorCode isEqualToString:PAY_ERROR_20031] ||
              [errorCode isEqualToString:PAY_ERROR_20032] ||
              [errorCode isEqualToString:PAY_ERROR_20033] ||
              [errorCode isEqualToString:PAY_ERROR_20035] ||
              [errorCode isEqualToString:PAY_ERROR_20037] ||
              [errorCode isEqualToString:PAY_ERROR_20039] ||
              [errorCode isEqualToString:PAY_ERROR_20040] ||
              [errorCode isEqualToString:PAY_ERROR_20041] ||
              [errorCode isEqualToString:PAY_ERROR_20042] ||
              [errorCode isEqualToString:PAY_ERROR_20043] ||
              [errorCode isEqualToString:PAY_ERROR_20044] ||
              [errorCode isEqualToString:PAY_ERROR_20045]
              ) {
        // 普通错误
        messageTips = NSLocalizedStringFromSelf(PAY_ERROR_NORMAL);
        
    }
    
    return messageTips;
}

#pragma mark - Apple支付回调
- (void)onGetOrderNo:(PaymentManager* _Nonnull)mgr result:(BOOL)result code:(NSString* _Nonnull)code orderNo:(NSString* _Nonnull)orderNo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( result ) {
            NSLog(@"ChatViewController::onGetOrderNo( 获取订单成功, orderNo : %@ )", orderNo);
            self.orderNo = orderNo;
            
        } else {
            NSLog(@"ChatViewController::onGetOrderNo( 获取订单失败, code : %@ )", code);
            
            // 隐藏菊花
            [self hideLoading];
            
            NSString* tips = [self messageTipsFromErrorCode:code defaultCode:PAY_ERROR_NORMAL];
            tips = [NSString stringWithFormat:@"%@ (%@)",tips,code];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            alertView.tag = AlertTypeDefault;
            [alertView show];
        }
    });
}

- (void)onAppStorePay:(PaymentManager* _Nonnull)mgr result:(BOOL)result orderNo:(NSString* _Nonnull)orderNo canRetry:(BOOL)canRetry {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [self.orderNo isEqualToString:orderNo] ) {
            if( result ) {
                NSLog(@"ChatViewController::onAppStorePay( AppStore支付成功, orderNo : %@ )", orderNo);
                
            } else {
                NSLog(@"ChatViewController::onAppStorePay( AppStore支付失败, orderNo : %@, canRetry :%d )", orderNo, canRetry);
                
                // 隐藏菊花
                [self hideLoading];
                
                if( canRetry ) {
                    // 弹出重试窗口
                    NSString* tips = [self messageTipsFromErrorCode:PAY_ERROR_OTHER defaultCode:PAY_ERROR_OTHER];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
                    alertView.tag = AlertTypeAppStorePay;
                    [alertView show];
                    
                } else {
                    // 弹出提示窗口
                    NSString* tips = [self messageTipsFromErrorCode:PAY_ERROR_NORMAL defaultCode:PAY_ERROR_NORMAL];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                    alertView.tag = AlertTypeDefault;
                    [alertView show];
                }
            }
        }
        
    });
}

- (void)onCheckOrder:(PaymentManager* _Nonnull)mgr result:(BOOL)result code:(NSString* _Nonnull)code orderNo:(NSString* _Nonnull)orderNo canRetry:(BOOL)canRetry {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [self.orderNo isEqualToString:orderNo] ) {
            if( result ) {
                NSLog(@"ChatViewController::onCheckOrder( 验证订单成功, orderNo : %@ )", orderNo);
                
            } else {
                NSLog(@"ChatViewController::onCheckOrder( 验证订单失败, orderNo : %@, canRetry :%d, code : %@ )", orderNo, canRetry, code);
                
                // 隐藏菊花
                [self hideLoading];
                
                if( canRetry ) {
                    // 弹出重试窗口
                    NSString* tips = [self messageTipsFromErrorCode:PAY_ERROR_OTHER defaultCode:PAY_ERROR_OTHER];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
                    alertView.tag = AlertTypeCheckOrder;
                    [alertView show];
                    
                } else {
                    // 弹出提示窗口
                    NSString* tips = [self messageTipsFromErrorCode:code defaultCode:PAY_ERROR_NORMAL];
                    tips = [NSString stringWithFormat:@"%@ (%@)",tips,code];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                    alertView.tag = AlertTypeDefault;
                    [alertView show];
                }
            }
        }
    });
}

- (void)onPaymentFinish:(PaymentManager* _Nonnull)mgr orderNo:(NSString* _Nonnull)orderNo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ChatViewController::onPaymentFinish( 支付完成 orderNo : %@ )", orderNo);
        
        // 隐藏菊花
        [self hideLoading];
        
        // 弹出提示窗口
        NSString* tips = NSLocalizedStringFromSelf(@"PAY_SUCCESS");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        alertView.tag = AlertTypeDefault;
        [alertView show];
        
        // 清空订单号
        [self cancelPay];
        
        // 重新请求接口,获取最新状态
        self.monthFeeManager.bRequest = NO;
        [self.monthFeeManager getQueryMemberType];
        
        
    });
}

#pragma mark - 月费管理器回调
- (void)manager:(MonthFeeManager *)manager onGetMemberType:(BOOL)success errnum:(NSString *)errnum errmsg:(NSString *)errmsg memberType:(MonthFeeType)memberType {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ChatViewController::onGetMemberType( 获取月费类型, memberType : %d )", memberType);
        if (success) {
            self.memberType = memberType;
            
        }else {
            self.memberType = MonthFeeTypeNoramlMember;
        }
    });
}


#pragma mark - 照片手势处理回调

- (void)photoViewDidSingleTap:(PZPhotoView *)photoView {
    [self dismissViewControllerAnimated:NO completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)photoViewDidDoubleTap:(PZPhotoView *)photoView {
    
}

- (void)photoViewDidTwoFingerTap:(PZPhotoView *)photoView {
    
}

- (void)photoViewDidDoubleTwoFingerTap:(PZPhotoView *)photoView {
    
}

#pragma mark - 下载完成回调
- (void)loadImageFinish:(ImageViewLoader *)imageViewLoader success:(BOOL)success {
    if (success) {
        //        [self hideLoading];
    }else {
        
    }
    
}
@end
