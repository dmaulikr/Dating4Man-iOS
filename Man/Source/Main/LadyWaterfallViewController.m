//
//  LadyWaterfallViewController.m
//  dating
//
//  Created by Calvin on 16/12/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyWaterfallViewController.h"
#import "LadyDetailViewController.h"
#import "ServerViewControllerManager.h"

#import "UIScrollView+PullRefresh.h"

#import "QueryLadyListItemObject.h"
#import "GetQueryLadyListRequest.h"

#import "LiveChatManager.h"
#import "LoginManager.h"

#define PageSize 100

@interface LadyWaterfallViewController ()<LiveChatManagerDelegate, LoginManagerDelegate,UIScrollViewRefreshDelegate,LadyWaterfallViewDelegate,LadySearthViewDelegate>
#pragma mark - 变量
/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager* sessionManager;

/**
 *  LiveChat管理器
 */
@property (nonatomic,strong) LiveChatManager *liveChatManager;

/**
 *  Login管理器
 */
@property (nonatomic,strong) LoginManager *loginManager;
/**
 *  页数
 */
@property (nonatomic,assign) int pageCount;

/**
 *  每页个数
 */
@property (nonatomic,assign) int dataCountInPage;

/**
 *  女士数组
 */
@property (nonatomic, strong) NSMutableArray *womanArray;
@end

@implementation LadyWaterfallViewController

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.collectionView.waterfallViewDelegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if( self.womanArray.count == 0 && self.loginManager.status == LOGINED ) {
        // 已登陆, 没有女士, 下拉控件, 触发调用刷新女士列表
        [self.collectionView startPullDown:YES];
    }

    [self reloadData:YES];
}

- (void)viewDidAppear:(BOOL)animated {
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
    
    self.womanArray = [NSMutableArray array];
    self.sessionManager = [SessionRequestManager manager];
    
    self.liveChatManager = [LiveChatManager manager];
    [self.liveChatManager addDelegate:self];
    
    self.loginManager = [LoginManager manager];
    [self.loginManager addDelegate:self];
}

- (void)dealloc {
    [self.liveChatManager removeDelegate:self];
    [self.loginManager removeDelegate:self];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
}

- (void)setupContainView {
    [super setupContainView];
    
    [self setupWaterfallView];
}

- (void)setupWaterfallView {
    self.mainVC.pagingScrollView.delaysContentTouches = NO;
    // 初始化下拉
    [self.collectionView initPullRefresh:self pullDown:YES pullUp:YES];
}

#pragma mark - 数据逻辑
/**
 *  刷新界面
 *
 *  @param isReloadView
 */
- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    if( isReloadView ) {
        self.collectionView.items = self.womanArray;
        
        [self.collectionView reloadData];
        
        //偏移collectionView 隐藏搜索框
        [self.collectionView setContentInset:UIEdgeInsetsMake(-50, 0, 0, 0)];
    }
}

/**
 *  下拉刷新
 */
- (void)pullDownRefresh {
    self.view.userInteractionEnabled = NO;
    [self getQueryLadyList:NO];
}

/**
 *  上拉更多
 */
- (void)pullUpRefresh {
    self.view.userInteractionEnabled = NO;
    [self getQueryLadyList:YES];
}

- (BOOL)getQueryLadyList:(BOOL)loadMore {
    GetQueryLadyListRequest *request = [[GetQueryLadyListRequest alloc] init];
    
    if( !loadMore ) {
        // 刷最新
        self.pageCount = 1;
        
    } else {
        // 刷更多
        self.pageCount++;
    }
    
    // 每页最大纪录数
    request.pageSize = PageSize;
    request.page = self.pageCount;
    
    if (self.searthView.minValue >0 || self.searthView.maxValue >0) {
        request.age1 = self.searthView.minValue;
        request.age2  = self.searthView.maxValue;
    }
    
    // 在线状态
    request.onlineStatus = (self.searthView.online)?LADY_ONLINE:LADY_OSTATUS_DEFAULT;
    request.searchWay = SearchTypeDEFAULT;
    
    // 性别
    request.genderType = [self getGenderType];//
    
    // 调用接口
    request.finishHandler = ^(BOOL success, NSMutableArray<QueryLadyListItemObject *> * _Nonnull itemArray,int totalCount, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if( success ) {
                NSLog(@"LadyListViewController::getQueryLadyList( 获取女士列表成功, loadMore : %d, count : %ld )", loadMore, (long)itemArray.count);
                if( !loadMore ) {
                    // 清空列表
                    [self.womanArray removeAllObjects];
                    
                    // 停止头部
                    [self.collectionView finishPullDown:YES];
                    
                } else {
                    // 停止底部
                    [self.collectionView finishPullUp:YES];
                    
                }
                
                for(QueryLadyListItemObject* item in itemArray) {
                    [self addLadyIfNotExist:item];
                }
                
                [self reloadData:YES];
                
                
            } else {
                NSLog(@"LadyListViewController::getQueryLadyList( 获取女士列表失败 )");
                
                if( !loadMore ) {
                    // 停止头部
                    [self.collectionView finishPullDown:YES];
                    
                } else {
                    // 停止底部
                    [self.collectionView finishPullUp:YES];
                    
                }
                
                [self reloadData:YES];
                
            }
            
            self.view.userInteractionEnabled = YES;
        });
        
    };
    return [self.sessionManager sendRequest:request];
}

/**
 *  根据界面选项获取性别类型
 *
 *  @return 性别类型
 */
- (LadyGenderType)getGenderType
{
    LadyGenderType genderType = LadyGenderType::LADY_GENDER_DEFAULT;
    switch (self.searthView.isMale) {
        case 0:
           genderType = LadyGenderType::LADY_GENDER_FEMALE;
            break;
        case 1:
            genderType = LadyGenderType::LADY_GENDER_MALE;
            break;
    }
    return genderType;
}

- (void)addLadyIfNotExist:(QueryLadyListItemObject* _Nonnull)lady {
    bool bFlag = NO;
    for(QueryLadyListItemObject* item in self.womanArray) {
        if( [lady.womanid isEqualToString:item.womanid] ) {
            // 已经存在
            bFlag = true;
            break;
        }
    }
    
    if( !bFlag ) {
        // 不存在
        [self.womanArray addObject:lady];
    }
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self pullDownRefresh];
}

- (void)pullUpRefresh:(UIScrollView *)scrollView {
    // 上拉更多回调
    if (self.womanArray.count > 10) {
        [self pullUpRefresh];
    }
}

#pragma mark - WaterfallViewDelegate

- (void)waterfallView:(UICollectionView *)waterfallView didSelectLady:(QueryLadyListItemObject *)item
{
    LadyDetailViewController* vc = [[LadyDetailViewController alloc] initWithNibName:nil bundle:nil];
    vc.womanId = item.womanid;
    vc.ladyListImageUrl = item.photoURL;
    KKNavigationController* nvc = (KKNavigationController* )self.mainVC.navigationController;
    [nvc pushViewController:vc animated:YES];
}

- (void)didChatButtonFromWaterfallViewIndex:(NSInteger)index
{
    QueryLadyListItemObject *currentItem = [self.collectionView.items objectAtIndex:index];
    
    UIViewController* vc = [[ServerViewControllerManager manager] chatViewController:currentItem.firstname womanid:currentItem.womanid photoURL:currentItem.photoURL];
    KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
    [nvc pushViewController:vc animated:YES];
}

- (void)showSearthView
{
    if (!self.searthView) {
        self.searthView = [LadySearthView initLadySearthViewXib];
        self.searthView.delegate = self;
        self.searthView.frame = self.view.window.bounds;
        [self.view.window addSubview:self.searthView];
    }
    else
    {
        [self.searthView showAnimation];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.searthView) {
        [self.searthView hideAnimation];
    }
}

#pragma mark - 搜索框按钮点击事件
- (void)searchFinish
{
    [self.searthView hideAnimation];
    [self.collectionView startPullDown:YES];
}
@end
