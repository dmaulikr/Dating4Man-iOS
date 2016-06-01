//
//  LadyListViewController.m
//  dating
//
//  Created by Max on 16/2/15.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyListViewController.h"
#import "LadyDetailViewController.h"
#import "ChatViewController.h"

#import "LadyListTableViewCell.h"
#import "UIScrollView+Refresh.h"

#import "QueryLadyListItemObject.h"
#import "GetQueryLadyListRequest.h"

#import "LiveChatManager.h"
#import "LoginManager.h"

#define MinAgeRange 18
#define MaxAgeRange 100
#define defaultOffset 64.0
#define PageSize 10

typedef enum {
    OnlineTypeOFFLINE = 0,
    OnlineTypeONLINE = 1
} OnlineType;

@interface LadyListViewController () <LadyListTableViewDelegate, LiveChatManagerDelegate, LoginManagerDelegate>
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
 *  是否在线
 */
@property (nonatomic, assign) BOOL online;

/**
 *  女士数组
 */
@property (nonatomic, strong) NSMutableArray *womanArray;

/**
 *  点击手势
 */
@property (nonatomic,strong) UITapGestureRecognizer *tap;
#pragma mark - 方法
/**
 *  刷新界面
 *
 *  @param isReloadView
 */
- (void)reloadData:(BOOL)isReloadView;

/**
 *  下拉刷新
 */
- (void)pullDownRefresh;

/**
 *  上拉更多
 */
- (void)pullUpRefresh;

/**
 *  刷新邀请人数
 */
- (void)reloadInviteUsers;

@end

@implementation LadyListViewController
#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.chatNowBtn.adjustsImageWhenHighlighted = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    [self.loginManager addDelegate:self];
    [self.liveChatManager addDelegate:self];
    
    if( self.womanArray.count == 0 && self.loginManager.status == LOGINED ) {
        // 已登陆, 没有女士, 下拉控件, 触发调用刷新女士列表
        [self.tableView headerBeginRefreshing];
    }

    [self reloadInviteUsers];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.liveChatManager removeDelegate:self];
    [self.loginManager removeDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 界面逻辑
- (void)initCustomParam {
    //设置默认搜索状态
    self.online = YES;
    
    self.womanArray = [NSMutableArray array];
    self.sessionManager = [SessionRequestManager manager];
    
    self.liveChatManager = [LiveChatManager manager];
    self.loginManager = [LoginManager manager];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    
    UIBarButtonItem *barButtonItem = nil;
    UIImage* image = nil;
    UIButton* button = nil;
    
    // 标题
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    image = [UIImage imageNamed:@"Navigation-Qpid"];
    [button setImage:image forState:UIControlStateDisabled];
    [button setTitle:@"QDate" forState:UIControlStateNormal];
    [button sizeToFit];
    [button setEnabled:NO];
    self.navigationItem.titleView = button;
    
    // 左边按钮
    NSMutableArray *array = [NSMutableArray array];
    
    self.navLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    image = [UIImage imageNamed:@"Navigation-Setting"];
    [self.navLeftButton setImage:image forState:UIControlStateNormal];
    [self.navLeftButton sizeToFit];
    [self.navLeftButton addTarget:self.mainVC action:@selector(pageLeftAction:) forControlEvents:UIControlEventTouchUpInside];
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navLeftButton];
    [array addObject:barButtonItem];
    
    self.navigationItem.leftBarButtonItems = array;
    
    // 右边按钮
    array = [NSMutableArray array];
    
    self.navRightButton = [BadgeButton buttonWithType:UIButtonTypeCustom];
    image = [UIImage imageNamed:@"Navigation-ChatList"];
    [self.navRightButton setImage:image forState:UIControlStateNormal];
    image = [UIImage imageNamed:@"Navigation-Badge"];
    self.navRightButton.imageBadge = image;
    self.navRightButton.badgeValue = nil;
    [self.navRightButton sizeToFit];
    [self.navRightButton addTarget:self.mainVC action:@selector(pageRightAction:) forControlEvents:UIControlEventTouchUpInside];
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navRightButton];
    [array addObject:barButtonItem];
    
    self.navigationItem.rightBarButtonItems = array;
    
    [self.mainVC setupNavigationBar];
    
}

- (void)setupContainView {
    [super setupContainView];
    
    [self setupTableView];
    [self setupSearchView];
    
}

- (void)setupTableView {
    [self.tableView addHeaderWithTarget:self action:@selector(pullDownRefresh)];
    [self.tableView addFooterWithTarget:self action:@selector(pullUpRefresh)];
}

- (void)setupSearchView{
    // 设置搜索按钮
    [self setupSearchBtn];
    
    // 设置搜索条件选择
    [self setupSexChooseView];
    
    // 设置年龄选择
    [self setupAgeSlider];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearchTable)];
    [self.searchTable addGestureRecognizer:tap];
    
}

- (void)setupSearchBtn {
    // 设置搜索按钮
    self.searchBtn.layer.cornerRadius = 5.0f;
    self.searchBtn.layer.borderWidth = 1;
    self.searchBtn.layer.borderColor = [UIColor grayColor].CGColor;
    self.searchBtn.layer.masksToBounds = YES;
}

- (void)setupSexChooseView {
    
    [self.sexSegment setTitle:@"Both" forSegmentAtIndex:0];
    [self.sexSegment setTitle:@"Female" forSegmentAtIndex:1];
    [self.sexSegment setTitle:@"Male" forSegmentAtIndex:2];
    
    self.sexSegment.selectedSegmentIndex = 1;
    
    

}

- (void)setupAgeSlider {
    // 设置年龄选择
    // 最大范围
    self.ageSlider.positionMaxValue = MaxAgeRange - MinAgeRange;
    
    // 右边位置
    self.ageSlider.positionValue = MaxAgeRange - MinAgeRange - 1;
    
    // 背景填充
    self.ageSlider.trackBackgroundImage = [self createImageWithColor:[UIColor colorWithIntRGB:201 green:201 blue:201 alpha:255] imageRect:CGRectMake(0.0f, 0.0f, 1.0f, 3.0f)];
    self.ageSlider.trackFillImage = [self createImageWithColor:[UIColor colorWithIntRGB:201 green:201 blue:201 alpha:255]  imageRect:CGRectMake(0.0f, 0.0f, 1.0f, 3.0f)];
    
    // 滑块图片
    UIImage *colorImage = [self createImageWithColor:[UIColor colorWithIntRGB:201 green:201 blue:201 alpha:255] imageRect:CGRectMake(0.0f, 0.0f, 18.0f, 18.0f)];
    // 滑块高亮图片
       self.ageSlider.handleImage = [colorImage circleImage];
    
    [self.ageSlider addTarget:self action:@selector(updateSliderLabel) forControlEvents:UIControlEventValueChanged];
    
    self.minValueLabel.text = [NSString stringWithFormat:@"%d", MinAgeRange];
    self.maxValueLabel.text = [NSString stringWithFormat:@"%d",(int)self.ageSlider.positionValue + MinAgeRange];
}

- (void)updateSliderLabel {
    // 设置年龄范围
    self.minValueLabel.text = [NSString stringWithFormat:@"%d",(int)self.ageSlider.leftValue + MinAgeRange];
    self.maxValueLabel.text = [NSString stringWithFormat:@"%d",(int)self.ageSlider.rightValue + MinAgeRange];
}



- (UIImage *)createImageWithColor:(UIColor *)color imageRect:(CGRect)rect{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    if( isReloadView ) {
        self.tableView.items = self.womanArray;
        [self.tableView reloadData];
    }
}

- (void)pullDownRefresh {
    [self getQueryLadyList:NO];
}

- (void)pullUpRefresh {
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
    
    if (self.minValueLabel.text || self.maxValueLabel.text) {
        request.age1 = [self.minValueLabel.text intValue];
        request.age2  = [self.maxValueLabel.text intValue];
    }
    
    // 在线状态
    request.onlineStatus = (self.online)?LADY_ONLINE:LADY_OSTATUS_DEFAULT;
    request.searchWay = SearchTypeDEFAULT;
    
    // 调用接口
    request.finishHandler = ^(BOOL success, NSMutableArray<QueryLadyListItemObject *> * _Nonnull itemArray,int totalCount, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
        if( success ) {
            NSLog(@"LadyListViewController::getQueryLadyList( 获取女士列表成功, count : %ld )", (long)itemArray.count);
            dispatch_async(dispatch_get_main_queue(), ^{
                if( !loadMore ) {
                    // 清空列表
                    [self.womanArray removeAllObjects];
                    
                    // 停止头部
                    [self.tableView headerEndRefreshing];
                } else {
                    // 停止底部
                    [self.tableView footerEndRefreshing];
                }
                
                for(QueryLadyListItemObject* item in itemArray) {
                    [self addLadyIfNotExist:item];
                }
                
                [self reloadData:YES];
                
                if( !loadMore ) {
                    if( self.womanArray.count > 0 ) {
                        // 拉到最顶
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    }
                }
                
            });
        } else {
            NSLog(@"LadyListViewController::getQueryLadyList( 获取女士列表失败 )");
            dispatch_async(dispatch_get_main_queue(), ^{
                if( !loadMore ) {
                    // 停止头部
                    [self.tableView headerEndRefreshing];
                } else {
                    // 停止底部
                    [self.tableView footerEndRefreshing];
                }
                
                [self reloadData:YES];
            });
        }
    };
    return [self.sessionManager sendRequest:request];
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

- (void)reloadInviteUsers {
    // 刷邀请人数
    NSArray* array = [self.liveChatManager getInviteUsers];
    self.navRightButton.badgeValue = array.count > 0?[NSString stringWithFormat:@"%ld", (long)array.count]:nil;
//    [self setupNavigationBar];
}

#pragma mark - 界面事件
- (IBAction)backToLastLady:(id)sender {
    LadyListTableViewCell *currentCell = [self.tableView visibleCells].firstObject;
    NSIndexPath *currentLadyIndex = [self.tableView indexPathForCell:currentCell];
    NSIndexPath *lastLadyIndex = [NSIndexPath indexPathForItem:currentLadyIndex.item + 1 inSection:currentLadyIndex.section];
    if( currentLadyIndex.item < self.womanArray.count - 1 ) {
        [self.tableView scrollToRowAtIndexPath:lastLadyIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
    } else {
        // 执行下拉刷新操作
        [self.tableView footerBeginRefreshing];
    }

}

- (void)buttonBarAction:(id)sender {
    // 搜索栏选择器的选择
    UIButton* button = (UIButton* )sender;
    for( UIButton* item in self.itemSelect.items ) {
        if( item.tag == button.tag ) {
            [item setSelected:YES];
        } else {
            [item setSelected:NO];
            
        }
    }
    
}

- (IBAction)onlineStatusChange:(id)sender {
    // 记录选择的在线状态
    if( self.onlineStatusSelect.isOn ) {
        self.online = YES;
    } else {
        self.online = NO;
    }
}

- (IBAction)searchConfig:(id)sender {
    
    [self.tableView setAllowsSelection:NO];
    // 搜素按钮点击弹出搜索栏
    [UIView animateWithDuration:0.5 animations:^{
        self.searchTop.constant = 0;
        [self.view layoutIfNeeded];
    }];
    [self.onlineStatusSelect setOn:self.online];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearchTable)];
    [self.tableView addGestureRecognizer:tap];
    self.tap = tap;
    
}

- (IBAction)searchFinish:(id)sender {
    // 搜索栏搜索按钮的点击
    [UIView animateWithDuration:0.5 animations:^{
        self.searchTop.constant = -self.searchTable.bounds.size.height;  
        [self.view layoutIfNeeded];
    }];
    [self.tableView setAllowsSelection:YES];
    [self.tableView removeGestureRecognizer:self.tap];
    [self getQueryLadyList:NO];
}

- (IBAction)chatNowAction:(id)sender {
    // 点击聊天
    ChatViewController* vc = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
    
    LadyListTableViewCell *currentCell = [self.tableView visibleCells].firstObject;
    NSIndexPath *currentLadyIndex = [self.tableView indexPathForCell:currentCell];
    QueryLadyListItemObject *currentItem = [self.tableView.items objectAtIndex:currentLadyIndex.row];
    vc.firstname = currentItem.firstname;
    vc.womanId = currentItem.womanid;
    vc.photoURL = currentItem.photoURL;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dismissSearchTable {
    [self.tableView setAllowsSelection:YES];
    [self.tableView removeGestureRecognizer:self.tap];
    // 点击view搜索的View退回
    [UIView animateWithDuration:0.5 animations:^{
        self.searchTop.constant = -self.searchTable.bounds.size.height;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - 列表界面回调
- (void)tableView:(LadyListTableView *)tableView didSelectLady:(QueryLadyListItemObject *)item {
    LadyDetailViewController* vc = [[LadyDetailViewController alloc] initWithNibName:nil bundle:nil];
    vc.itemObject = item;
    KKNavigationController* nvc = (KKNavigationController* )self.mainVC.navigationController;
    [nvc pushViewController:vc animated:YES];
}

- (void)tableView:(LadyListTableView *)tableView didShowLady:(QueryLadyListItemObject *)item {
    if( item.onlineStatus == LADY_ONLINE ) {
        self.chatNowBtn.backgroundColor = [UIColor colorWithRed:102/255.0 green:153/255.0 blue:0/255.0 alpha:1.0];
        self.chatNowBtn.enabled = YES;
    } else {
        self.chatNowBtn.backgroundColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0];
        self.chatNowBtn.enabled = NO;
    }
}

#pragma mark - 代理方法回调
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    // 控制拖拽偏移量,保持头部不回弹
    if (scrollView.contentOffset.y < -defaultOffset) {
        CGPoint offsetY = scrollView.contentOffset;
        offsetY.y = -defaultOffset;
        scrollView.contentOffset = offsetY;
    }else if (scrollView.contentOffset.y - scrollView.contentSize.height + defaultOffset - scrollView.frame.size.height < 0 && scrollView.contentSize.height - scrollView.contentOffset.y < scrollView.frame.size.height){
        //保持底部不回弹
        CGPoint offsetY = scrollView.contentOffset;
        offsetY.y = scrollView.contentOffset.y + defaultOffset ;
        scrollView.contentOffset = offsetY;
    }
}

#pragma mark - LivechatManager回调
- (void)onRecvTextMsg:(LiveChatMsgItemObject* _Nonnull)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LadyListViewController::onRecvTextMsg( 接收文本消息回调 fromId : %@ )", msg.fromId);
        [self reloadInviteUsers];
    });
}

#pragma mark - 登陆管理器回调 (LoginManagerDelegate)
- (void)manager:(LoginManager *)manager onLogin:(BOOL)success loginItem:(LoginItemObject *)loginItem errnum:(NSString *)errnum errmsg:(NSString *)errmsg {
    NSLog(@"LadyListViewController::onLogin( success : %d )", success);
    if( success ) {
        if( self.womanArray.count == 0 ) {
            // 已登陆, 没有女士, 下拉控件, 触发调用刷新女士列表
            [self.tableView headerBeginRefreshing];
        }
        
    }
}
@end
