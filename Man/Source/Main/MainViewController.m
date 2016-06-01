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

@interface MainViewController () <LiveChatManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) NSInteger curIndex;

/**
 *  LiveChat管理器
 */
@property (nonatomic,strong) LiveChatManager *liveChatManager;

@end

@implementation MainViewController
@synthesize items;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.liveChatManager = [LiveChatManager manager];
    // 接收Livechat事件, 不需要注销事件
    [self.liveChatManager addDelegate:self];
    
    [self resetParam];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view layoutIfNeeded];
    if( !self.viewDidAppearEver ) {
        [self reloadData:YES];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 界面逻辑
- (void)setupNavigationBar {
    [super setupNavigationBar];
    
    UIViewController* vc = [self.items objectAtIndex:_curIndex];
    self.navigationItem.titleView = vc.navigationItem.titleView;
    [self.navigationItem setLeftBarButtonItems:vc.navigationItem.leftBarButtonItems animated:YES];
    [self.navigationItem setRightBarButtonItems:vc.navigationItem.rightBarButtonItems animated:YES];
    
}

#pragma mark - 左右页面切换
- (void)pageLeftAction:(id)sender {
    if( _curIndex > 0 ) {
        _curIndex -= 1;
        [self reloadData:YES];
    }

}

- (void)pageRightAction:(id)sender {
    if( _curIndex < self.items.count ) {
        _curIndex += 1;
        [self reloadData:YES];
    }
}

#pragma mark - 数据逻辑
- (void)resetParam {
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

- (void)reloadData:(BOOL)isReloadView {
    if( isReloadView ) {
        [self.pagingScrollView displayPagingViewAtIndex:_curIndex animated:YES];
        
        [self setupNavigationBar];
    }
    
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
            [nvc.navigationBar setTranslucent:NO];
            [nvc.navigationBar setBarTintColor:self.navigationController.navigationBar.barTintColor];
            nvc.customDefaultBackTitle = @"Back";
            nvc.customDefaultBackImage = [UIImage imageNamed:@"Navigation-Back"];
            [self presentViewController:nvc animated:NO completion:nil];
            
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

    UIViewController* vc = [self.items objectAtIndex:index];
    if( vc.view != nil ) {
        [vc.view removeFromSuperview];
    }

    [pageView removeAllSubviews];
    
    [vc.view setFrame:CGRectMake(0, 0, pageView.self.frame.size.width, pageView.self.frame.size.height)];
    [pageView addSubview:vc.view];


}

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    _curIndex = index;
    [self setupNavigationBar];
}

#pragma mark - 点击被踢提示
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self reloadData:YES];
}

#pragma mark - LivechatManager回调
- (void)onRecvKickOffline:(KICK_OFFLINE_TYPE)kickType {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ChatViewController::onSendTextMsg( 接收被踢下线通知回调 kickType : %d )", kickType);
        if( KOT_OTHER_LOGIN == kickType ) {
            [[LoginManager manager] logout:YES];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"You have been signed out because your account is logged in elsewhere." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
        }
    });
}

@end
