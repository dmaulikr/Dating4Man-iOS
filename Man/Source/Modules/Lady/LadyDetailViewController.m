//
//  LadyDetailViewController.m
//  dating
//
//  Created by Max on 16/2/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyDetailViewController.h"
#import "ServerViewControllerManager.h"
#import "ChatViewController.h"
#import "LadyDetailPhototViewController.h"

#import "CommonPageViewTableViewCell.h"
#import "LadyDetailNameTableViewCell.h"
#import "CommonTitleTableViewCell.h"
#import "CommonDetailTableViewCell.h"

#import "GetLadyDetailRequest.h"
#import "AddFavouriteLadyRequest.h"
#import "RemoveFavouriteLadyRequest.h"
#import "ReportLadyRequest.h"
#import "LadyDetailItemObject.h"

#import "KKCheckButton.h"
#import "ContactManager.h"
#import "UIImage+Resize.h"

#import "SessionRequestManager.h"
#import "LiveChatManager.h"

typedef enum {
    RowTypePhoto,
    RowTypeName,
    RowTypeLocation,
    RowTypeDescription,
} RowType;


typedef enum : NSUInteger {
    ActionSheetBtnActionTypeCancel,
    ActionSheetBtnActionTypeReport,
} ActionSheetBtnActionType;


@interface LadyDetailViewController () <PZPhotoViewDelegate, PZPagingScrollViewDelegate, UIActionSheetDelegate, KKCheckButtonDelegate, ContactManagerDelegate, ImageViewLoaderDelegate,LadyDetailNameTableViewCellDelegate,UIAlertViewDelegate>
/**
 *  详情分栏
 */
@property (nonatomic, strong) NSArray* tableViewArray;

/**
 *  相册当前下标
 */
@property (nonatomic, assign) NSInteger photoIndex;

/**
 *  相册列表
 */
@property (nonatomic, strong) NSArray* imageList;

/** 请求管理者 */
@property (nonatomic,strong) SessionRequestManager *sessionManager;

/**
 *  女士详情
 */
@property (nonatomic,strong) LadyDetailItemObject *item;

/**
 *  联系人管理器
 */
@property (nonatomic,strong) ContactManager *contactManager;

/**
 *  点击手势
 */
@property (nonatomic,strong) UITapGestureRecognizer *tap;

@end

@implementation LadyDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.addFavouriesBtn.userInteractionEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    if( !self.viewDidAppearEver ) {
        [self getLadyDetail];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - 界面逻辑
- (void)initCustomParam{
    // 初始化父类参数
    [super initCustomParam];
    
    self.sessionManager = [SessionRequestManager manager];
    self.contactManager = [ContactManager manager];
    self.photoIndex = 0;
    self.backToChat = NO;
}

- (void)unInitCustomParam {

}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    UIBarButtonItem *barButtonItem = nil;
    UIImage *image = nil;
    UIButton* button = nil;
    
    // 标题
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    image = [UIImage imageNamed:@"LadyDetail-Camera"];
    [button setImage:image forState:UIControlStateDisabled];
    NSString* title = [NSString stringWithFormat:@" %ld / %lu", self.imageList.count > 0?(long)self.photoIndex + 1:0, (unsigned long)self.imageList.count];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button sizeToFit];
    [button setEnabled:NO];
    self.navigationItem.titleView = button;
    
    // 隐藏附件数目
//    if (self.items.count == 0) {
//        self.navigationItem.titleView.hidden = YES;
//    }
    
    // 右边按钮
    NSMutableArray *array = [NSMutableArray array];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"..." forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(reportAction:) forControlEvents:UIControlEventTouchUpInside];
    button.hidden = YES;
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [array addObject:barButtonItem];
    
    self.navigationItem.rightBarButtonItems = array;
}

- (void)setupContainView {
    [super setupContainView];
    [self setupTableView];
    
    self.chatBtn.enabled = NO;
}


- (void)setupTableView {
    self.tableView.separatorColor = [UIColor grayColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    headerView.backgroundColor = self.tableView.separatorColor;
    [self.tableView setTableHeaderView:headerView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
    
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 78, 0);
}

- (IBAction)reportAction:(id)sender {
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report", nil];
    [sheet showInView:self.view];
}

- (IBAction)chatAction:(id)sender {
    if( self.backToChat ) {
        // 从聊天界面进入, 直接退出
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        // 进入聊天界面
        UIViewController* vc = [[ServerViewControllerManager manager] chatViewController:self.item.firstname womanid:self.item.womanid photoURL:self.item.photoURL];
        KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
        [nvc pushViewController:vc animated:YES];
    }

}

- (IBAction)favouriteChange:(id)sender {
    if( self.item.isFavorite ) {
        // 取消收藏
        [self removeFavouriesLady];
       
    } else {
        // 增加收藏
        [self addFavouriesLady];
    }
}

#pragma mark - 图片点击手势方法
- (void)lookBigPicture{
    LadyDetailPhototViewController *photo = [[LadyDetailPhototViewController alloc] initWithNibName:nil bundle:nil];
    photo.ladyListArray = self.imageList;
    photo.ladyListPath = self.imageList;
    photo.photoIndex = self.photoIndex;
    photo.enableScroll = NO;

    [self presentViewController:photo animated:NO completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }];
}

#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView {
    // 主tableView
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    CGSize viewSize;
    NSValue *rowSize;
    
    // 图片
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 140);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypePhoto] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    // 姓名
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [LadyDetailNameTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeName] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
//    // 国家
//    dictionary = [NSMutableDictionary dictionary];
//    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonTitleTableViewCell cellHeight]);
//    rowSize = [NSValue valueWithCGSize:viewSize];
//    [dictionary setValue:rowSize forKey:ROW_SIZE];
//    [dictionary setValue:[NSNumber numberWithInteger:RowTypeLocation] forKey:ROW_TYPE];
//    [array addObject:dictionary];
    
    // 描述
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonDetailTableViewCell cellHeight:self.tableView.frame.size.width detailAttributedString:[self parseResume:self.item.resume font:[UIFont systemFontOfSize:17]]] + 128);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeDescription] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    self.tableViewArray = array;
    
    // 增加相册
    NSMutableArray* imageList = [NSMutableArray array];
    if( self.item.photoList && self.item.photoList.count > 0 ) {
        // 复制附件图片
        [imageList addObjectsFromArray:self.item.photoList];
    }else if (self.item.photoList.count == 0 && ![AppDelegate().errorUrlConnect isEqualToString:self.item.photoURL]){
        if( nil != self.item.photoURL ) {
            [imageList addObject:self.item.photoURL];
        }
    }
    self.imageList = imageList;

    if( isReloadView ) {
        [self setupNavigationBar];
        [self.tableView reloadData];
        
        if( self.item.isFavorite ) {
            // 显示取消收藏
            [self.addFavouriesBtn setImage:[UIImage imageNamed:@"LadyDetail-FavoriteNormal"] forState:UIControlStateNormal];
            [self.addFavouriesBtn setImage:[UIImage imageNamed:@"LadyDetail-FavoriteHighlight"] forState:UIControlStateHighlighted];
        } else {
            // 显示收藏
            [self.addFavouriesBtn setImage:[UIImage imageNamed:@"LadyDetail-FavoriteRemoveNormal"] forState:UIControlStateNormal];
            [self.addFavouriesBtn setImage:[UIImage imageNamed:@"LadyDetail-FavoriteRemoveHighlight"] forState:UIControlStateHighlighted];
            
        }
    }
    
}

- (NSAttributedString* )parseResume:(NSString* )text font:(UIFont* )font {
    NSMutableString* htmlString = [[NSMutableString alloc] initWithString:@"<html><body style='color:#888888;font-family:sans-serif;'><font size=\"5\">"];
    if( text != nil ) {
        [htmlString appendString:text];
    }
    [htmlString appendString:@"</font></body></html>"];
    
    NSData* data = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithData:data
                                                                                         options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                                    NSFontAttributeName : font
                                                                                                    }
                                                                              documentAttributes:nil
                                                                                           error:nil];
    return attributeString;
}

//- (void)showLoading {
//    self.loadingView.hidden = NO;
//    self.view.userInteractionEnabled = NO;
//}
//- (void)hideLoading {
//    self.loadingView.hidden = YES;
//    self.view.userInteractionEnabled = YES;
//
//}

#pragma mark - 画廊回调 (PZPagingScrollViewDelegate)
- (Class)pagingScrollView:(PZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    return [UIImageViewTopFit class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(PZPagingScrollView *)pagingScrollView {
    NSUInteger count = 0;
    if (self.imageList != nil) {
        count = self.imageList.count;
    }
    return count;
}

- (UIView *)pagingScrollView:(PZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    UIImageViewTopFit* view = [[UIImageViewTopFit alloc] initWithFrame:CGRectMake(0, 0, pagingScrollView.frame.size.width, pagingScrollView.frame.size.height)];
    [view setContentMode:UIViewContentModeScaleAspectFit];
    return view;
}

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookBigPicture)];
    pageView.userInteractionEnabled = YES;
    [pageView addGestureRecognizer:tap];
    
    // 还原默认图片
    UIImageViewTopFit* imageView = (UIImageViewTopFit *)pageView;
    [imageView setImage:nil];
    
    // 图片路径
    NSString* url = [self.imageList objectAtIndex:index];
    // 停止旧的
    static NSString *imageViewLoaderKey = @"imageViewLoaderKey";
    ImageViewLoader* imageViewLoader = objc_getAssociatedObject(pageView, &imageViewLoaderKey);
    [imageViewLoader stop];
    
    // 创建新的
    imageViewLoader = [ImageViewLoader loader];
    objc_setAssociatedObject(pageView, &imageViewLoaderKey, imageViewLoader, OBJC_ASSOCIATION_RETAIN);
    
    // 加载图片
    imageViewLoader.delegate = self;
    imageViewLoader.view = imageView;
    imageViewLoader.url = url;
    imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:imageViewLoader.url];
    [imageViewLoader loadImage];
    
}

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    self.photoIndex = index;
    [self setupNavigationBar];
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 0;
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        count = 1;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        number = self.tableViewArray.count;
    }
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
        CGSize viewSize;
        NSValue *value = [dictionarry valueForKey:ROW_SIZE];
        [value getValue:&viewSize];
        height = viewSize.height;
    }
  
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
        
        // 大小
        CGSize viewSize;
        NSValue *value = [dictionarry valueForKey:ROW_SIZE];
        [value getValue:&viewSize];
        
        // 类型
        RowType type = (RowType)[[dictionarry valueForKey:ROW_TYPE] intValue];
        switch (type) {
            case RowTypePhoto:{
                // 图片
                CommonPageViewTableViewCell* cell = [CommonPageViewTableViewCell getUITableViewCell:tableView];
                result = cell;
                
                cell.pagingScrollView.pagingViewDelegate = self;
                self.pagingScrollView = cell.pagingScrollView;
                
                if (self.item.isonline) {
                    [cell.onlineView setBackgroundColor:[UIColor colorWithIntRGB:1 green:170 blue:1 alpha:255]];
                } else {
                    [cell.onlineView setBackgroundColor:[UIColor colorWithIntRGB:160 green:160 blue:160 alpha:255]];
                }
                
                
            }break;
            case RowTypeName:{
                // 姓名
                LadyDetailNameTableViewCell *cell = [LadyDetailNameTableViewCell getUITableViewCell:tableView];
                result = cell;
                cell.delegate = self;
                
                if( self.item.firstname && self.item.age ) {
                    cell.titleLabel.text = [NSString stringWithFormat:@"%@, %d", self.item.firstname, self.item.age];
                } else {
                    cell.titleLabel.text = @"";
                }
                
                if( self.item.country ) {
                    cell.countryLabel.text = self.item.country;
                } else {
                    cell.countryLabel.text = @"";
                }
                
                if (self.item.isonline) {
                    self.chatBtn.enabled = YES;
                } else {
                    self.chatBtn.enabled = NO;
                }
                
            }break;
            case RowTypeLocation:{
                // 国家
                CommonTitleTableViewCell *cell = [CommonTitleTableViewCell getUITableViewCell:tableView];
                result = cell;
                
                [cell.leftImageView setImage:[UIImage imageNamed:@"MyProfile-Location"]];
                cell.titleLabel.text = self.item.country;
                
            }break;
            case RowTypeDescription:{
                // 描述
                CommonDetailTableViewCell *cell = [CommonDetailTableViewCell getUITableViewCell:tableView];
                result = cell;
                cell.detailLabel.attributedText = [self parseResume:self.item.resume font:[UIFont systemFontOfSize:17]];

            }break;
            default:break;
        }
        [result setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([tableView isEqual:self.tableView]) {
        NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
        
        // 类型
        RowType type = (RowType)[[dictionarry valueForKey:ROW_TYPE] intValue];
        switch (type) {
            case RowTypePhoto:{
                // 照片
            }break;
            case RowTypeName:{
                
            }break;
            case RowTypeLocation:{
                
            }break;
            case RowTypeDescription:{
                
            }break;
            default:
                break;
        }
        
    }
    
}

#pragma mark - 接口处理
- (BOOL)getLadyDetail {
    [self showLoading];
    GetLadyDetailRequest *request = [[GetLadyDetailRequest alloc] init];
    request.womanId = self.womanId;
    self.item = [[LadyDetailItemObject alloc] init];
    request.finishHandler = ^(BOOL success, LadyDetailItemObject *item, NSString * _Nullable errnum, NSString * _Nullable errmsg){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            
            if (success) {
                self.addFavouriesBtn.userInteractionEnabled = YES;
                
                self.item = item;
                [self reloadData:YES];
                
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errmsg delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil) , nil];
                [alertView show];
            }
        });
    };
    
    return [self.sessionManager sendRequest:request];
}

- (BOOL)addFavouriesLady {
    [self showLoading];
    AddFavouriteLadyRequest *request = [[AddFavouriteLadyRequest alloc] init];
    request.womanId = self.womanId;
    request.finishHandler = ^(BOOL success,NSString *error,NSString *errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            
            if (success) {
                // 收藏成功, 更新最近联系人数据
                LadyRecentContactObject* recent = [self.contactManager getOrNewRecentWithId:self.item.womanid];
                recent.firstname = self.item.firstname;
//                recent.photoURL = self.item.photoURL;
                [ContactManager updateLasttime:recent];
                self.item.isFavorite = YES;
                
                // 更新联系人列表
                [self.contactManager updateRecents];
                
                // 刷新界面
                [self reloadData:YES];
                
                // 获取女士详情
                [[LiveChatManager manager] getUserInfo:self.item.womanid];
            }
            
        });
    };
    return [self.sessionManager sendRequest:request];
    
}

- (BOOL)removeFavouriesLady {
    [self showLoading];
    
    RemoveFavouriteLadyRequest *request = [[RemoveFavouriteLadyRequest alloc] init];
    request.womanId = self.item.womanid;
    request.finishHandler = ^(BOOL success,NSString *error,NSString *errmsg){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            
            if (success) {
                // 标记女士为未收藏
                self.item.isFavorite = NO;
                
                // 刷新界面
                [self reloadData:YES];
            }
            
        });
    };
    return [self.sessionManager sendRequest:request];
}

- (BOOL)reportLady {
    [self showLoading];
    
    ReportLadyRequest *request = [[ReportLadyRequest alloc] init];
    request.womanId = self.item.womanid;
    request.finishHandler = ^(BOOL success,NSString *error,NSString *errmsg){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            
            // 弹窗
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromSelf(@"Report_Tips") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alertView show];
        });
    };
    return [self.sessionManager sendRequest:request];
}

#pragma mark - 代理方法回调
- (void)LadyDetailNameTableViewCellReportBtnClick:(LadyDetailNameTableViewCell *)cell {
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedStringFromSelf(@"Report_Button_Tips"), nil];
    
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case ActionSheetBtnActionTypeReport:{
            [self reportLady];
            
        }break;
        case ActionSheetBtnActionTypeCancel:{
            
        }break;
        default:
            break;
    }
}


@end
