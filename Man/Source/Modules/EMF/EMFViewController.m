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

@interface EMFViewController () <UIWebViewDelegate, LoginManagerDelegate, MonthFeeManagerDelegate, PaymentManagerDelegate>{
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
    // Do any additional setup after loading the view.
    //[self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.userId  = self.loginManager.loginItem.manid;
    self.userSid = self.loginManager.loginItem.sessionid;
    
    self.requesStart = YES;
    self.isOpenWebview = NO;
    [self showFailLoad:NO];
    
    // 适应大小
//    self.EMFWebView.scalesPageToFit = YES;
//    // 设置代理
    [self.EMFWebView setDelegate:self];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    self.EMFWebView.canBounces = YES;
//    // 刚开始设置隐藏，当加载完，0.3秒才显示
    [self.EMFWebView setHidden:YES];
    //[self.view addSubview:self.EMFWebView];

//    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"alextest1 EMFViewController didReceiveMemoryWarning");
    [self.EMFWebView stopLoading];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self hideLoading];
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
    //[self hideLoading];
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
//    webSiteUrl = [NSString stringWithFormat:@"http://test:5179@demo-m.charmdate.com"];

    // webview请求url
    NSURL *url = [NSURL URLWithString:webSiteUrl];
    // url请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 在请求的头加上DEVICE_TYPE字段
    [request addValue:@"31" forHTTPHeaderField:@"DEVICE_TYPE"];
    //hi[request setHTTPMethod:@"POST"];
    // 加载请求
    [self showLoading];
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
            [self showLoading];
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
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* _Nullable data, NSURLResponse *_Nullable response, NSError* _Nullable error){
        NSURL *url = [request URL];
        NSString* strfragment = [url fragment];
        NSHTTPURLResponse *tmpresponse = (NSHTTPURLResponse*) response;

        if( self.isFirstTimeFinish ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoading];
            });
        }
        
        if (200 != tmpresponse.statusCode) {
            [self FailLoadWebview];
        } else if( [strfragment isEqualToString:@"emf_mails"] ){
            self.isOpenWebview = YES;
        }

    }];
    [dataTask resume];
    
    return YES;
}

// 要开始加载了
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // 获取屏幕大小，在加载前赋值webview的高度，防止显示时因导航栏隐藏，导致上移
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    CGRect webViewFrame = self.EMFWebView.frame;
    webViewFrame.size.height = frame.size.height;
    self.EMFWebView.frame = webViewFrame;
    
}

// 加载完成回调，并不代表渲染完成了
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:webView.request completionHandler:^(NSData* _Nullable data, NSURLResponse *_Nullable response, NSError* _Nullable error){
        NSHTTPURLResponse *tmpresponse = (NSHTTPURLResponse*) response;
        //NSLog(@"webViewDidFinishLoad statusCode:%ld", (long)tmpresponse.statusCode);
        if (self.isOpenWebview && tmpresponse.statusCode == 200) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //NSLog(@"webViewDidFinishLoad DISPATCH_TIME_NOW statusCode:%ld", (long)tmpresponse.statusCode);
                // 隐藏导航栏
                KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
                [nvc setNavigationBarHidden:YES animated:NO];
                [self.EMFWebView setHidden:NO];
                [self.EMFWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
                [self.EMFWebView stringByEvaluatingJavaScriptFromString:@"changeMonthFeePrice(14.99);"];
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
                
            });
        }
        else
        {
            [self FailLoadWebview];
        }
    }];
    [dataTask resume];
    
    self.isFirstTimeFinish = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoading];
    });
}

// 加载失败回调
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //NSLog(@"didFailLoadWithError:%@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoading];
    });
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
        [self.EMFWebView setHidden:YES];
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
    
    self.loginManager = [LoginManager manager];
    [self.loginManager addDelegate:self];
    
    self.isFirstTimeFinish = NO;
    
}

- (void)dealloc {
     NSLog(@"alextest dealloc");
    self.EMFWebView.delegate = nil;
    [self.EMFWebView stopLoading];
    [self.EMFWebView removeFromSuperview];
    [self.loginManager removeDelegate:self];
    [NSURLProtocol unregisterClass:[JWURLProtocol class]];
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
            NSLog(@"SettingViewController::onGetOrderNo( 获取订单失败, code : %@ )", code);
            
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
                NSLog(@"SettingViewController::onAppStorePay( AppStore支付失败, orderNo : %@, canRetry :%d )", orderNo, canRetry);
                
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
                NSLog(@"SettingViewController::onCheckOrder( 验证订单失败, orderNo : %@, canRetry :%d, code : %@ )", orderNo, canRetry, code);
                
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
        NSLog(@"SettingViewController::onPaymentFinish( 支付完成 orderNo : %@ )", orderNo);
        
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
        NSLog(@"SettingViewController::onGetMemberType( 获取月费类型, memberType : %d )", memberType);
        if (success) {
            self.memberType = (MonthFeeType)memberType;
            [self hideLoading];
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


@end
