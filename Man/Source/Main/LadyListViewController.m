//
//  LadyListViewController.m
//  dating
//
//  Created by Max on 16/2/15.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyListViewController.h"
#import "LadyDetailViewController.h"
#import "ServerViewControllerManager.h"

#import "LadyListTableViewCell.h"
#import "UIScrollView+PullRefresh.h"

#import "QueryLadyListItemObject.h"
#import "GetQueryLadyListRequest.h"

#import "LiveChatManager.h"
#import "LoginManager.h"

#define MinAgeRange 18
#define MaxAgeRange 100
#define DefaultOffset 64.0
#define PageSize 100
#define SearchTableAnimationDuration 0.2
#define ShadowHeight 4


typedef enum {
    OnlineTypeOFFLINE = 0,
    OnlineTypeONLINE = 1
} OnlineType;

@interface LadyListViewController () <LadyListTableViewDelegate, LiveChatManagerDelegate, LoginManagerDelegate, UIScrollViewRefreshDelegate>
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

@end

@implementation LadyListViewController
#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.chatNowBtn.enabled = NO;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if( self.womanArray.count == 0 && self.loginManager.status == LOGINED ) {
        // 已登陆, 没有女士, 下拉控件, 触发调用刷新女士列表
        [self.tableView startPullDown:YES];
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
    
    //设置默认搜索状态
    self.online = NO;
    
    self.womanArray = [NSMutableArray array];
    self.sessionManager = [SessionRequestManager manager];
    
    self.liveChatManager = [LiveChatManager manager];
    [self.liveChatManager addDelegate:self];
    
    self.loginManager = [LoginManager manager];
    [self.loginManager addDelegate:self];

}

- (void)unInitCustomParam {
    [self.liveChatManager removeDelegate:self];
    [self.loginManager removeDelegate:self];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];   
}

- (void)setupContainView {
    [super setupContainView];
    
    [self setupTableView];
    [self setupSearchView];
    
}

- (void)setupTableView {
    self.mainVC.pagingScrollView.delaysContentTouches = NO;
    self.tableView.delaysContentTouches = NO;

    // 初始化下拉
    [self.tableView initPullRefresh:self pullDown:YES pullUp:YES];
}

- (void)setupSearchView{
    // 设置搜索按钮
    [self setupSearchBtn];
    
    // 设置搜索条件选择
    [self setupSexChooseView];
    
    // 设置年龄选择
    [self setupAgeSlider];
    
    // 收起搜索控件手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearchTable)];
    [self.searchTable addGestureRecognizer:tap];
    
}

- (void)setupSearchBtn {
    // 设置搜索按钮
    self.searchBtn.layer.cornerRadius = 5.0f;
    self.searchBtn.layer.borderWidth = 1;
    self.searchBtn.layer.borderColor = [UIColor colorWithIntRGB:200 green:200 blue:200 alpha:255].CGColor;
    self.searchBtn.layer.masksToBounds = YES;
}

- (void)setupSexChooseView {
    
    [self.sexSegment setTitle:NSLocalizedStringFromSelf(@"Both") forSegmentAtIndex:0];
    [self.sexSegment setTitle:NSLocalizedStringFromSelf(@"Female") forSegmentAtIndex:1];
    [self.sexSegment setTitle:NSLocalizedStringFromSelf(@"Male") forSegmentAtIndex:2];
    
    self.sexSegment.selectedSegmentIndex = 1;

}

- (void)setupAgeSlider {
    // 设置年龄选择
    // 最大范围
    self.ageSlider.positionMaxValue = MaxAgeRange - MinAgeRange;
    
    // 右边位置
    self.ageSlider.positionValue = MaxAgeRange - MinAgeRange - 45;
    
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

#pragma mark - 颜色画图
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
/**
 *  刷新界面
 *
 *  @param isReloadView
 */
- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    if( isReloadView ) {
        self.tableView.items = self.womanArray;
        if(self.tableView.items.count > 0) {
            self.pullUpBtn.hidden = NO;
        } else {
            self.pullUpBtn.hidden = YES;
        }
        self.chatNowBtn.enabled = NO;
        [self.tableView reloadData];
        
        LadyListTableViewCell *currentCell = [self.tableView visibleCells].firstObject;
        NSIndexPath *currentLadyIndex = [self.tableView indexPathForCell:currentCell];
        NSInteger row = currentLadyIndex.row;
        
        if( self.womanArray.count > 0) {
            if( row < self.womanArray.count ) {
                NSIndexPath* nextLadyIndex = [NSIndexPath indexPathForRow:row inSection:0];
                [self.tableView scrollToRowAtIndexPath:nextLadyIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
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
    
    if (self.minValueLabel.text || self.maxValueLabel.text) {
        request.age1 = [self.minValueLabel.text intValue];
        request.age2  = [self.maxValueLabel.text intValue];
    }
    
    // 在线状态
    request.onlineStatus = (self.online)?LADY_ONLINE:LADY_OSTATUS_DEFAULT;
    request.searchWay = SearchTypeDEFAULT;
    
    // 性别
    request.genderType = [self getGenderType];
    
    // 调用接口
    request.finishHandler = ^(BOOL success, NSMutableArray<QueryLadyListItemObject *> * _Nonnull itemArray,int totalCount, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if( success ) {
                NSLog(@"LadyListViewController::getQueryLadyList( 获取女士列表成功, loadMore : %d, count : %ld )", loadMore, (long)itemArray.count);
                if( !loadMore ) {
                    // 清空列表
                    [self.womanArray removeAllObjects];
                    
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                    
                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                    
                }
                
                for(QueryLadyListItemObject* item in itemArray) {
                    [self addLadyIfNotExist:item];
                }
                
                [self reloadData:YES];
                
                if( !loadMore ) {
                    if( self.womanArray.count > 0 ) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            // 拉到最顶
                            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        });
                    }
                }
                
            } else {
                NSLog(@"LadyListViewController::getQueryLadyList( 获取女士列表失败 )");
                
                if( !loadMore ) {
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                    
                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                    
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
    switch (self.sexSegment.selectedSegmentIndex) {
        case 0:
            genderType = LadyGenderType::LADY_GENDER_DEFAULT;
            break;
        case 1:
            genderType = LadyGenderType::LADY_GENDER_FEMALE;
            break;
        case 2:
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

#pragma mark - 界面事件
- (IBAction)backToLastLady:(id)sender {
    LadyListTableViewCell *currentCell = [self.tableView visibleCells].firstObject;
    NSIndexPath *currentLadyIndex = [self.tableView indexPathForCell:currentCell];
    NSInteger row = currentLadyIndex.row + 1;

    if( self.womanArray.count > 0) {
        if( row < self.womanArray.count ) {
            // 显示下一个
            NSIndexPath* nextLadyIndex = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView scrollToRowAtIndexPath:nextLadyIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
        } else {
            // 最后一个
            // 执行下拉刷新操作
            [self.tableView startPullUp:YES];
        }
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
    [UIView animateWithDuration:SearchTableAnimationDuration animations:^{
        self.searchTop.constant = 0;
        [self.view layoutIfNeeded];
    }];
    [self.onlineStatusSelect setOn:self.online];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearchTable)];
    [self.tableView addGestureRecognizer:tap];
    self.tap = tap;
    self.pullUpBtn.enabled = NO;
    
}

- (IBAction)searchFinish:(id)sender {
    // 搜索栏搜索按钮的点击
    [UIView animateWithDuration:SearchTableAnimationDuration animations:^{
        self.searchTop.constant = -self.searchTable.bounds.size.height - ShadowHeight;
        [self.view layoutIfNeeded];
    }];
    [self.tableView setAllowsSelection:YES];
    [self.tableView removeGestureRecognizer:self.tap];
    self.pullUpBtn.enabled = YES;
    
    [self.tableView startPullDown:YES];
}

- (IBAction)chatNowAction:(id)sender {
    // 点击聊天
    LadyListTableViewCell *currentCell = [self.tableView visibleCells].firstObject;
    NSIndexPath *currentLadyIndex = [self.tableView indexPathForCell:currentCell];
    QueryLadyListItemObject *currentItem = [self.tableView.items objectAtIndex:currentLadyIndex.row];
    
    UIViewController* vc = [[ServerViewControllerManager manager] chatViewController:currentItem.firstname womanid:currentItem.womanid photoURL:currentItem.photoURL];
    KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
    [nvc pushViewController:vc animated:YES];
}

- (void)dismissSearchTable {
    [self.tableView setAllowsSelection:YES];
    [self.tableView removeGestureRecognizer:self.tap];
    self.pullUpBtn.enabled = YES;
    // 点击view搜索的View退回
    [UIView animateWithDuration:SearchTableAnimationDuration animations:^{
        self.searchTop.constant = -self.searchTable.bounds.size.height - ShadowHeight;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - 列表界面回调
- (void)tableView:(LadyListTableView *)tableView didSelectLady:(QueryLadyListItemObject *)item {
    LadyDetailViewController* vc = [[LadyDetailViewController alloc] initWithNibName:nil bundle:nil];
    vc.womanId = item.womanid;
    vc.ladyListImageUrl = item.photoURL;
    KKNavigationController* nvc = (KKNavigationController* )self.mainVC.navigationController;
    [nvc pushViewController:vc animated:YES];
}

- (void)tableView:(LadyListTableView *)tableView didShowLady:(QueryLadyListItemObject *)item {
    if( item.onlineStatus == LADY_ONLINE ) {
        self.chatNowBtn.enabled = YES;
    } else {
        self.chatNowBtn.enabled = NO;
    }
    self.pullUpBtn.enabled = YES;
    self.searchShowBtn.enabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        self.chatNowBtn.enabled = NO;
        self.pullUpBtn.enabled = NO;
        self.searchShowBtn.enabled = NO;
    }
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self pullDownRefresh];
}

- (void)pullUpRefresh:(UIScrollView *)scrollView {
    // 上拉更多回调
    [self pullUpRefresh];
}

#pragma mark - LivechatManager回调
- (void)onRecvTextMsg:(LiveChatMsgItemObject* _Nonnull)msg {

}

#pragma mark - 登陆管理器回调 (LoginManagerDelegate)
- (void)manager:(LoginManager *)manager onLogin:(BOOL)success loginItem:(LoginItemObject *)loginItem errnum:(NSString *)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LadyListViewController::onLogin( success : %d )", success);
        if( success ) {
            if( self.womanArray.count == 0 ) {
                // 已登陆, 没有女士, 下拉控件, 触发调用刷新女士列表
                [self.tableView startPullDown:YES];
            }
        }
    });
}

- (void)manager:(LoginManager * _Nonnull)manager onLogout:(BOOL)kick {
    if( kick ) {
        self.womanArray = [NSMutableArray array];
        self.pageCount = 1;
        [self reloadData:YES];
    }
}

@end
