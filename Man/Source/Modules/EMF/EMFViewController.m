//
//  EMFViewController.m
//  dating
//
//  Created by alex shum on 16/10/10.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "EMFViewController.h"
#import "LiveChatManager.h"
#import "AddCreditsViewController.h"
#import "JWURLProtocol.h"
#import "LoginManager.h"
#import "MonthFeeManager.h"
#import "PaymentManager.h"
#import "PaymentErrorCode.h"

typedef enum EMFAlertType {
    EMFAlertTypeFailServer = 1000,
    AlertTypeDefault,
    AlertTypeAppStorePay,
    AlertTypeCheckOrder,
    AlertTypeBuyMonthFee

} AlertType;

static NSString *const PUBLICCSS01 = @"/Public/Css/jquery.mobile.min.css?v=1.51";
static NSString *const PUBLICCSS02 = @"/Public/Css/public.css?v=1.65";
static NSString *const PUBLICCSS03 = @"/Public/charmingdate/css/css.css?v=1.61";
static NSString *const PUBLICCSS04 = @"/Public/Css/women_list.css?v=1.64";
static NSString *const PUBLICCSS05 = @"/Public/Js/jquery.min.js?v=1.52";
static NSString *const PUBLICCSS06 = @"/Public/Js/jquery.mobile.js?v=1.52";
static NSString *const PUBLICCSS07 = @"/Public/Js/login.js?v=1.56";
static NSString *const PUBLICCSS08 = @"/Public/Js/blocksit.min.js";
static NSString *const PUBLICCSS09 = @"/Public/Js/jquery.form.min.js";
static NSString *const PUBLICCSS10 = @"/Public/Js/public.js?v=1.09";
static NSString *const PUBLICCSS11 = @"/Public/Js/base64.js";
static NSString *const PUBLICCSS12 = @"/Public/Js/base_jqm.js?v=1.70";
static NSString *const PUBLICCSS13 = @"/Public/Js/iscroll.js?v=1.52";
static NSString *const PUBLICCSS14 = @"/Public/Js/util.js";
static NSString *const PUBLICCSS15 = @"/Public/Js/json.js";
static NSString *const PUBLICCSS16 = @"/Public/Js/framework.chat.js?v=1.68";
static NSString *const PUBLICCSS17 = @"/Public/Js/socket.js?v=1.51";
static NSString *const PUBLICCSS18 = @"/Public/Js/touchSwipe.min.js";
static NSString *const PUBLICCSS19 = @"/Public/Js/age.scroller.js";
static NSString *const PUBLICCSS20 = @"/Public/Js/TouchSlide.1.1.source.js";
static NSString *const PUBLICCSS21 = @"/Public/Js/animation.js?v=1.52";
static NSString *const PUBLICCSS22 = @"/Public/Css/chat_scroll.css?v=1.52";
static NSString *const PUBLICCSS23 = @"/Public/Js/chat_scroll.js?v=1.52";
static NSString *const PUBLICCSS24 = @"/Public/charmingdate/css/swipe.css";
static NSString *const PUBLICCSS25 = @"/Public/Js/klass.min.js";
static NSString *const PUBLICCSS26 = @"/Public/Js/photoswipe.jquery-3.0.4.min.js?v=1.57";

@interface EMFViewController () <UIWebViewDelegate, LoginManagerDelegate, MonthFeeManagerDelegate, PaymentManagerDelegate, JWURLProtocolDelegate>{
}

/**
 *  Login管理器
 */
@property (nonatomic,strong) LoginManager *loginManager;

/** 月费管理器 */
@property (nonatomic,strong) MonthFeeManager *monthFeeManager;

/** 月费类型 */
@property (nonatomic,assign) MonthFeeType memberType;

/**
 *  支付管理器
 */
@property (nonatomic, strong) PaymentManager* paymentManager;

/**
 *  当前支付订单号
 */
@property (nonatomic, strong) NSString* orderNo;

/**
 是否第一次加载完成
 */
@property (assign, atomic) BOOL isFirstTimeFinish;

// 清空所有webview的Cookice
- (void)clearAllCookies;


@end

@implementation EMFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userId  = self.loginManager.loginItem.manid;
    self.userSid = self.loginManager.loginItem.sessionid;
    
    self.requesStart = YES;
    self.isOpenWebview = NO;
    [self showFailLoad:NO];
    
    // 适应大小
    self.EMFWebView.scalesPageToFit = YES;
    // 设置代理
    [self.EMFWebView setDelegate:self];
    self.EMFWebView.canBounces = YES;
   // 刚开始设置隐藏，当加载完，0.3秒才显示
    [self.EMFWebView setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"self hideLoading alextest1 EMFViewController didReceiveMemoryWarning");
    //[self.EMFWebView stopLoading];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self FailLoadWebview];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.paymentManager = [PaymentManager manager];
    [self.paymentManager addDelegate:self];
    
    self.monthFeeManager = [MonthFeeManager manager];
    [self.monthFeeManager addDelegate:self];
   
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.paymentManager removeDelegate:self];
    [self.monthFeeManager removeDelegate:self];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 进来前第一次才请求加载webviw
    if (self.requesStart) {
        // webview 加载中
        [self requestEMFWebview];
        self.requesStart = NO;
    }
    else{
        KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
        // 隐藏导航栏
        [nvc setNavigationBarHidden:YES animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
    // 显示导航栏
    [nvc setNavigationBarHidden:NO animated:NO];
}

// 清空所有webview的Cookice
- (void)clearAllCookies
{
    NSHTTPCookie *Cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (Cookie in [storage cookies]) {
        [storage deleteCookie:Cookie];
    }
}

// 请求EMFwebview
- (void)requestEMFWebview
{
    // 清空所有cookies
    [self clearAllCookies];
    
    // EMF的网址和权限
    NSString *webSiteUrl = @"";
    webSiteUrl = [NSString stringWithFormat:@"%@/?topage=emf&user_id=%@&user_sid=%@", AppDelegate().wapSite, self.userId, self.userSid];
    // webSiteUrl = [NSString stringWithFormat:@"%@/?topage=emf", AppDelegate().wapSite];

    // webview请求url
    NSURL *url = [NSURL URLWithString:webSiteUrl];
    // url请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:60];
    // 在请求的头加上DEVICE_TYPE字段
    [request addValue:@"31" forHTTPHeaderField:@"DEVICE_TYPE"];
    // 加载请求
    [self showAndResetLoading];
    NSLog(@"[self showLoading]");
    [self.EMFWebView loadRequest:request];
    
}

// 点击重新加载
- (IBAction)reloadWebview:(id)sender {
    [self requestEMFWebview];
    [self LoadingWebview];
}

#pragma mark - UIWebViewDelegate

/*每次url的请求前回调，注意只有当需要跳转到不同的主网域（如demo－m.chnlove.com和demo.chnlove.com不同主网域），返回值NO取消请求。才会经过DidStartLoad－>didFinishLoad／didFailLoadWithError。 相同网域返回值为NO也一样会处理请求，就是都不会经过DidStartLoad－>didFinishLoad*/
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

    if( self.isFirstTimeFinish ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAndResetLoading];
            
        });
    }
    NSURL *url = [request URL];
    NSString* strAbsolute = [url absoluteString];
    NSString *strFragment  = [url fragment];
    NSString *strQuery     = [url query];
    
    NSString *strEMFgoBack = [NSString stringWithFormat:@"/?topage=emf&user_id=%@&user_sid=%@", self.userId, self.userSid ];
    NSString *checkout = @"/payment/checkout1.php";
    NSString *credits = @"/payment/credits.php";
    NSString *premium  = @"/payment/credits.php?client=mobile&mfee=1";
    //NSLog(@"strFragment:%@ strEMFgoBack:%@", strFragment,strEMFgoBack);
    // EMF的网址和权限
    NSString *loginUrl = @"";
    loginUrl = [NSString stringWithFormat:@"%@/member/login", AppDelegate().wapSite];
    // EMF后退点击请求
    if ((strFragment) && ([strFragment isEqualToString:strEMFgoBack])) {
        //NSLog(@"strFragment isEqualToString:strEMFgoBack");
        [NSURLProtocol unregisterClass:[JWURLProtocol class]];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"self hideLoading shouldStartLoadWithRequest");
            [self hideLoading];
            KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
            [nvc popViewControllerAnimated:NO];
        });
        return NO;
    }
    // 月费点击请求
    else if ( (strQuery != nil) && [strQuery rangeOfString:premium].location != NSNotFound)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            NSLog(@"self hideLoading shouldStartLoadWithRequest Tips_Buy_MonthFee");
            NSString *tips = NSLocalizedStringFromSelf(@"Tips_Buy_MonthFee");
            UIAlertView *premiumAlertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            premiumAlertView.tag = AlertTypeBuyMonthFee;
            [premiumAlertView show];
            
        });
        return NO;
    }
    // 其他买点点击请求
    else if ( (strQuery != nil) && ([strQuery rangeOfString:checkout].location != NSNotFound || [strQuery rangeOfString:credits].location != NSNotFound) )
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"self hideLoading shouldStartLoadWithRequest AddCreditsViewController");
            [self hideLoading];
            // 充值
            KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
            // 1。创建充值的控制器
            AddCreditsViewController *credits = [[AddCreditsViewController alloc] initWithNibName:nil bundle:nil];
            // 2。点击跳转
            [nvc pushViewController:credits animated:NO];
            
        });
        return NO;
    }
    else if((strAbsolute) && ([strAbsolute rangeOfString:loginUrl ].location != NSNotFound))
    {
        // NSLog(@"shouldStartLoadWithRequest is member/login");
        // 主线程登陆
        dispatch_async(dispatch_get_main_queue(), ^{
            KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
            [nvc setNavigationBarHidden:NO animated:NO];
            [self.EMFWebView setHidden:YES];
            [self.EMFWebView stopLoading];
            [self.loginManager logout:NO];
            [self.loginManager autoLogin];
        });
    }
 
    if (self.isFirstTimeFinish) {
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* _Nullable data, NSURLResponse *_Nullable response, NSError* _Nullable error){
            if( self.isFirstTimeFinish ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideAndResetLoading];
                });
            }
        }];
        [dataTask resume];
    }

    
    return YES;
}

// 要开始加载了
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"webViewDidFinishLoad statusCode:webViewDidStartLoad");
        // 获取屏幕大小，在加载前赋值webview的高度，防止显示时因导航栏隐藏，导致上移
        CGRect frame = [[UIScreen mainScreen] applicationFrame];
        CGRect webViewFrame = self.EMFWebView.frame;
        webViewFrame.size.height = frame.size.height;
        self.EMFWebView.frame = webViewFrame;
     NSLog(@"self.view.frame:%@", NSStringFromCGRect(self.EMFWebView.frame));
    // });
    
}

// 加载完成回调，并不代表渲染完成了
- (void)webViewDidFinishLoad:(UIWebView *)webView
{

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSLog(@"self.view.frame:%@", NSStringFromCGRect(self.EMFWebView.frame));
        // 获取屏幕大小，在加载前赋值webview的高度，防止显示时因导航栏隐藏，导致上移
        CGRect frame = [[UIScreen mainScreen] applicationFrame];
        CGRect webViewFrame = self.EMFWebView.frame;
        webViewFrame.size.height = frame.size.height;
        self.EMFWebView.frame = webViewFrame;

        // 隐藏导航栏
        //if (self.isOpenWebview) {
        self.isFirstTimeFinish = YES;
        [self hideLoading];
        KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
        [nvc setNavigationBarHidden:YES animated:NO];
        NSLog(@"self hideLoading webViewDidFinishLoad statusCode: [self.EMFWebView setHidden:NO] frame:%@;",NSStringFromCGRect(self.EMFWebView.frame));
        [self.EMFWebView setHidden:NO];
        [self showFailLoad:NO];
        [self.EMFWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
        [self.EMFWebView stringByEvaluatingJavaScriptFromString:@"changeMonthFeePrice(14.99);"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
        [self.EMFWebView stringByEvaluatingJavaScriptFromString:@"document.loction.href"];

    });
    
}

// 加载失败回调
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"self hideLoading didFailLoadWithError:%@", error);
    [self FailLoadWebview];
    switch (error.code) {
        case NSURLErrorNotConnectedToInternet :
        {
            // NSURL *url = [[webView request] URL];
            
            //[self showFailLoad:YES];
            NSLog(@"没有连接网络");
        }
            break;
        case NSURLErrorCancelled :
        {
        }
            break;
        case NSURLErrorNetworkConnectionLost :
        {
            //[self hideLoading];
            //[self showFailLoad:YES];
        }
        default:
            break;
    }
}

// 加载中界面
- (void)LoadingWebview
{
    dispatch_async(dispatch_get_main_queue(), ^{
        KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
        [nvc setNavigationBarHidden:NO animated:NO];
        [self showFailLoad:NO];
        //self.isOpenWebview = NO;
        [self.EMFWebView setHidden:YES];
    });
    
}

// 失败显示重新加载界面
- (void)FailLoadWebview
{
    self.isFirstTimeFinish = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.EMFWebView stopLoading];
        [self.EMFWebView setHidden:YES];
        [self hideAndResetLoading];
        KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
        [nvc setNavigationBarHidden:NO animated:NO];
        [self showFailLoad:YES];
        self.isOpenWebview = NO;
        
    });
}


#pragma mark - 界面逻辑
- (void)initCustomParam {
    NSLog(@"alextest initCustomParam");
    // 初始化父类参数
    [super initCustomParam];
    self.backTitle = NSLocalizedString(@"Home", nil);
    
    [NSURLProtocol registerClass:[JWURLProtocol class]];
    [JWURLProtocol setDelegate:self];
    
    self.loginManager = [LoginManager manager];
    [self.loginManager addDelegate:self];
    
    self.isFirstTimeFinish = NO;
    
}

- (void)dealloc {
     NSLog(@"alextest dealloc");
    self.EMFWebView.delegate = nil;
    [self.EMFWebView stopLoading];
    [self.EMFWebView removeFromSuperview];
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self.loginManager removeDelegate:self];
    [NSURLProtocol unregisterClass:[JWURLProtocol class]];
    [JWURLProtocol setDelegate:nil];
}

#pragma mark - LoginManager回调
- (void)manager:(LoginManager * _Nonnull)manager onLogin:(BOOL)success loginItem:(LoginItemObject * _Nullable)loginItem errnum:(NSString * _Nonnull)errnum errmsg:(NSString * _Nonnull)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"MainViewController::onLogin( 接收登录回调 success : %d )", success);
        //        [self reloadData:YES animated:NO];
        if (success) {
            // 主线程登陆
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userId  = loginItem.manid;
                self.userSid = loginItem.sessionid;
                
                self.isOpenWebview = NO;
                [self requestEMFWebview];
                
            });
        }
        else
        {
            [self FailLoadWebview];
        }
        
        //LiveChatManager* manager = [LiveChatManager manager];
        //NSLog(@"manager.sid:%@, self.sid:%@", manager.userSid, self.userSid);
        
    });
}

- (void)manager:(LoginManager * _Nonnull)manager onLogout:(BOOL)kick {
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"MainViewController::onLogout( 接收注销回调 kick : %d )", kick);
    });
}

// 显示加载失败view
- (void) showFailLoad:(BOOL)isShow
{
    [self.failLoadView setHidden:!isShow];
    //[self.failLoadView setHidden:NO];
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


#pragma mark PaymentManagerDelegate
/**
 *  获取订单回调（若失败则无法retry）
 *
 *  @param mgr     manager
 *  @param result  处理是否成功
 *  @param code    错误号
 *  @param orderNo 订单号
 */
- (void)onGetOrderNo:(PaymentManager* _Nonnull)mgr result:(BOOL)result code:(NSString* _Nonnull)code orderNo:(NSString* _Nonnull)orderNo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if( result ) {
            NSLog(@"SettingViewController::onGetOrderNo( 获取订单成功, orderNo : %@ )", orderNo);
            self.orderNo = orderNo;
            
        } else {
            NSLog(@"[self hideLoading] SettingViewController::onGetOrderNo( 获取订单失败, code : %@ )", code);
            
            [self.EMFWebView reload];
            
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

/**
 *  AppStore支付回调（可调retry重试支付）
 *
 *  @param mgr      manager
 *  @param result   处理是否成功
 *  @param orderNo  订单号
 *  @param canRetry 是否可重试支付
 */
- (void)onAppStorePay:(PaymentManager* _Nonnull)mgr result:(BOOL)result orderNo:(NSString* _Nonnull)orderNo canRetry:(BOOL)canRetry
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [self.orderNo isEqualToString:orderNo] ) {
            if( result ) {
                NSLog(@"SettingViewController::onAppStorePay( AppStore支付成功, orderNo : %@ )", orderNo);
                
            } else {
                NSLog(@"[self hideLoading] SettingViewController::onAppStorePay( AppStore支付失败, orderNo : %@, canRetry :%d )", orderNo, canRetry);
                
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

/**
 *  验证订单回调（可调retry重试支付）
 *
 *  @param mgr      manager
 *  @param result   处理是否成功
 *  @param code     错误码
 *  @param orderNo  订单号
 *  @param canRetry 是否可重试支付
 */
- (void)onCheckOrder:(PaymentManager* _Nonnull)mgr result:(BOOL)result code:(NSString* _Nonnull)code orderNo:(NSString* _Nonnull)orderNo canRetry:(BOOL)canRetry
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [self.orderNo isEqualToString:orderNo] ) {
            if( result ) {
                NSLog(@"SettingViewController::onCheckOrder( 验证订单成功, orderNo : %@ )", orderNo);
                
            } else {
                NSLog(@"[self hideLoading SettingViewController::onCheckOrder( 验证订单失败, orderNo : %@, canRetry :%d, code : %@ )", orderNo, canRetry, code);
                
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

/**
 *  支付完成
 *
 *  @param mgr      manager
 *  @param orderNo  订单号
 */
- (void)onPaymentFinish:(PaymentManager* _Nonnull)mgr orderNo:(NSString* _Nonnull)orderNo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"self hideLoading SettingViewController::onPaymentFinish( 支付完成 orderNo : %@ )", orderNo);
        
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
 //       self.monthFeeManager.bRequest = NO;
 //       [self.monthFeeManager getQueryMemberType];
        
    });
}

#pragma mark MonthFeeManagerDelegate
/**
 *  月费管理器状态
 *
 *  @param manager    月费管理器
 *  @param success    成功
 *  @param errnum     错误编码
 *  @param errmsg     错误信息
 *  @param memberType 月费类型
 */
- (void)manager:(MonthFeeManager * _Nonnull)manager onGetMemberType:(BOOL)success  errnum:(NSString * _Nonnull)errnum errmsg:(NSString * _Nonnull)errmsg memberType:(int)memberType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"self hideLoading SettingViewController::onGetMemberType( 获取月费类型, memberType : %d )", memberType);
        if (success) {
            self.memberType = (MonthFeeType)memberType;
            if (self.isFirstTimeFinish) {
                 [self hideLoading];
            }
        }
        
    });
}


/**
 *  月费管理器费用信息
 *
 *  @param manager    月费管理器
 *  @param success    成功
 *  @param errnum     错误编码
 *  @param errmsg     错误信息
 *  @param tipsArray  提示内容数组
 */
- (void)manager:(MonthFeeManager * _Nonnull)manager onGetMonthFee:(BOOL)success  errnum:(NSString * _Nonnull)errnum errmsg:(NSString * _Nonnull)errmsg tips:(NSArray * _Nonnull)tipsArray
{

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
                    NSLog(@"[self showLoading]");
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
                    NSLog(@"[self showLoading]");
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
                    NSLog(@"[self showLoading]");
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


-(void)JWURLProtocol:(JWURLProtocol *)protocol task:(NSURLSessionTask *)task didCompleWithError:(NSError *)error
{

    NSLog(@"alextest didCompleteWithError absoluteString:%@ code:%ld error;%@ ", [[task.currentRequest URL] absoluteString], (long)error.code , error);

        if ( [[[task.currentRequest URL] absoluteString]rangeOfString:@".jpg"].location != NSNotFound ||  [[[task.currentRequest URL] absoluteString]rangeOfString:@".png"].location != NSNotFound) {
            return;
        }
    
    BOOL result = NO;
        if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS01].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS02].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS03].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS04].location != NSNotFound)
        {
    
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString]rangeOfString:PUBLICCSS05].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString]rangeOfString:PUBLICCSS06].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS07].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS08].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS09].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS10].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS11].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS12].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS13].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS14].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS15].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS16].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS17].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS18].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS19].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS20].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS21].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS22].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS23].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS24].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS25].location != NSNotFound)
        {
            result = YES;
        }
        else if ([[[task.currentRequest URL] absoluteString] rangeOfString:PUBLICCSS26].location != NSNotFound)
        {
            result = YES;
        }
    
        switch (error.code) {
            case NSURLErrorNotConnectedToInternet :
            {
                result = YES;
            }
                break;
            case NSURLErrorCancelled :
            {
            }
                break;
            case NSURLErrorNetworkConnectionLost :
            {
                result = YES;
            }
            default:
                break;
        }
    
    if (result) {
        [self FailLoadWebview];
    }
}

-(void)JWURLProtocol:(JWURLProtocol *)protocol task:(NSURLSessionDataTask *)task didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"alextest didReceiveResponse absouluteString:%@", [[task.currentRequest URL] absoluteString]);
    NSLog(@"self.view.frame:%@", NSStringFromCGRect(self.EMFWebView.frame));
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    CGRect webViewFrame = self.EMFWebView.frame;
    if (webViewFrame.size.height  < frame.size.height) {
        webViewFrame.size.height = frame.size.height;
         dispatch_async(dispatch_get_main_queue(), ^{
             self.EMFWebView.frame = webViewFrame;
         });
    }

}




@end
