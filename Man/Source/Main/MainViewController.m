//
//  MainViewController.m
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "MainViewController.h"

#import "LadyListViewController.h"
#import "SettingViewController.h"
#import "ContactListViewController.h"
#import "LoginViewController.h"

#import "LoginManager.h"
#import "LiveChatManager.h"

@interface MainViewController () <LiveChatManagerDelegate, LoginManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, assign) BOOL bLivechatAutoLoginAlready;

/**
 *  LiveChat管理器
 */
@property (nonatomic,strong) LiveChatManager *liveChatManager;

/**
 *  Login管理器
 */
@property (nonatomic,strong) LoginManager *loginManager;

@end

@implementation MainViewController
@synthesize items;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.loginManager = [LoginManager manager];
    [self.loginManager addDelegate:self];
    
    self.liveChatManager = [LiveChatManager manager];
    [self.liveChatManager addDelegate:self];
    
    [self resetParam];
    
    // 跟踪用户行为
    [self reportDidShowPage:_curIndex];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if( !self.viewDidAppearEver ) {
        // 第一次进入, 界面未出现
        [self checkLogin:NO];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    if( !self.viewDidAppearEver ) {
        // 第一次进入, 界面已经出现
        [self reloadData:YES animated:NO];
    }
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 界面逻辑
- (void)initCustomParam {
    // 初始化父类参数
    [super initCustomParam];
    self.backTitle = NSLocalizedString(@"Home", nil);
}

- (void)unInitCustomParam {
    [self.liveChatManager removeDelegate:self];
    [self.loginManager removeDelegate:self];
}
- (void)setupNavigationBar {
    [super setupNavigationBar];
    
    KKViewController* vc = [self.items objectAtIndex:_curIndex];
    self.backTitle = vc.backTitle;
    
    self.navigationItem.titleView = vc.navigationItem.titleView;
    [self.navigationItem setLeftBarButtonItems:vc.navigationItem.leftBarButtonItems animated:YES];
    [self.navigationItem setRightBarButtonItems:vc.navigationItem.rightBarButtonItems animated:YES];
    
}

#pragma mark - 左右页面切换
- (void)pageLeftAction:(id)sender {
    if( _curIndex > 0 ) {
        _curIndex -= 1;
        [self reloadData:YES animated:YES];
    }

}

- (void)pageRightAction:(id)sender {
    if( _curIndex < self.items.count ) {
        _curIndex += 1;
        [self reloadData:YES animated:YES];
    }
}

#pragma mark - 数据逻辑
- (void)resetParam {
    self.bLivechatAutoLoginAlready = NO;
    
    _curIndex = 1;
//    _curIndex = 0;
    
    SettingViewController* vc = [[SettingViewController alloc] initWithNibName:nil bundle:nil];
    vc.mainVC = self;
    [self addChildViewController:vc];
    
    LadyListViewController* vc1 = [[LadyListViewController alloc] initWithNibName:nil bundle:nil];
    vc1.mainVC = self;
    [self addChildViewController:vc1];
    
    ContactListViewController* vc2 = [[ContactListViewController alloc] initWithNibName:nil bundle:nil];
    vc2.mainVC = self;
    [self addChildViewController:vc2];
    
    self.items = [NSArray arrayWithObjects:vc, vc1, vc2, nil];
    
}

- (void)reloadData:(BOOL)isReloadView animated:(BOOL)animated {
//    NSLog(@"MainViewController::reloadData( isReloadView : %ld )", (unsigned long)_curIndex);
    if( isReloadView ) {
        if( animated ) {
            self.navigationController.navigationBar.userInteractionEnabled = NO;
        }
        
        [self.pagingScrollView displayPagingViewAtIndex:_curIndex animated:animated];
        
        [self setupNavigationBar];
    }
    
}

- (void)checkLogin:(BOOL)animated {
    // 未登陆,弹出登陆界面
    LoginManager* manager = [LoginManager manager];
    switch (manager.status) {
        case NONE: {
            // 没登陆
            
        }
        case LOGINING:{
            // 登陆中
            LoginViewController *vc = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
            KKNavigationController *nvc = [[KKNavigationController alloc] initWithRootViewController:vc];
            [nvc.navigationBar setTranslucent:self.navigationController.navigationBar.translucent];
            [nvc.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
            [nvc.navigationBar setBarTintColor:self.navigationController.navigationBar.barTintColor];
            [self presentViewController:nvc animated:animated completion:nil];
            
        }break;
        case LOGINED:{
            // 已经登陆
            
        }break;
        default:
            break;
    }
}

#pragma mark - 画廊回调 (PZPagingScrollViewDelegate)
- (Class)pagingScrollView:(PZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    return [UIView class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(PZPagingScrollView *)pagingScrollView {
    return (nil == self.items)?0:self.items.count;
}

- (UIView *)pagingScrollView:(PZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pagingScrollView.frame.size.width, pagingScrollView.frame.size.height)];
    return view;
}

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    NSLog(@"MainViewController::preparePageViewForDisplay( index : %ld )", (unsigned long)index);
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    UIViewController* vc = [self.items objectAtIndex:index];
    if( vc.view != nil ) {
        [vc.view removeFromSuperview];
    }

    [pageView removeAllSubviews];
    
    [vc.view setFrame:CGRectMake(0, 0, pageView.self.frame.size.width, pageView.self.frame.size.height)];
    [pageView addSubview:vc.view];


}

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    NSLog(@"MainViewController::didShowPageViewForDisplay( index : %ld )", (unsigned long)index);
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    _curIndex = index;
    [self setupNavigationBar];
    
    // 跟踪用户行为
    [self reportDidShowPage:index];
}

#pragma mark - 点击被踢提示
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}

#pragma mark - LivechatManager回调
- (void)OnLogin:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg isAutoLogin:(BOOL)isAutoLogin {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"MainViewController::OnLogin( 接收LivechatManager登录通知回调 isAutoLogin : %d )", isAutoLogin);
        if( !isAutoLogin || errType == LCC_ERR_NOSESSION || errType == LCC_ERR_INVAILDPWD ) {
            if( !self.bLivechatAutoLoginAlready ) {
                // 未处理过
                self.bLivechatAutoLoginAlready = YES;
                
                [[LoginManager manager] logout:NO];
                [[LoginManager manager] autoLogin];
                
            } else {
                // 已经处理, 注销PHP
                [[LoginManager manager] logout:YES];
                
                // 弹出提示
                NSString* tips = NSLocalizedStringFromSelf(@"Tips_You_Connection_Lost");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alertView show];
            }
        }
    });
}

- (void)onRecvKickOffline:(KICK_OFFLINE_TYPE)kickType {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"MainViewController::onRecvKickOffline( 接收LivechatManager被踢下线通知回调 kickType : %d )", kickType);
        if( KOT_OTHER_LOGIN == kickType ) {
            // 注销PHP
            [[LoginManager manager] logout:YES];
            
            // 弹出提示
            NSString* tips = NSLocalizedStringFromSelf(@"Tips_You_Have_Been_Kick");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertView show];
            
        }
    });
}

#pragma mark - LoginManager回调
- (void)manager:(LoginManager * _Nonnull)manager onLogout:(BOOL)kick {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"MainViewController::onLogout( 接收注销回调 kick : %d )", kick);
        if( kick ) {
            self.bLivechatAutoLoginAlready = NO;
            [self.navigationController popToRootViewControllerAnimated:NO];
            
            // 可能是被踢或者注销, 重新检测, 弹出登录框
            [self checkLogin:YES];
            
            _curIndex = 1;
            [self reloadData:YES animated:NO];

        }
    });
}

@end
