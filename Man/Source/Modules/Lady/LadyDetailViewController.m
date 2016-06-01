//
//  LadyDetailViewController.m
//  dating
//
//  Created by Max on 16/2/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyDetailViewController.h"
#import "ChatViewController.h"
#import "CommonPageViewTableViewCell.h"
#import "LadyDetailNameTableViewCell.h"
#import "CommonTitleTableViewCell.h"
#import "CommonDetailTableViewCell.h"
#import "GetLadyDetailRequest.h"
#import "SessionRequestManager.h"
#import "LadyDetailItemObject.h"
#import "AddFavouriteLadyRequest.h"
#import "RemoveFavouriteLadyRequest.h"
#import "KKCheckButton.h"
#import "ContactManager.h"
#import "UIImage+Resize.h"
#import "LadyDetailPhototViewController.h"


typedef enum {
    RowTypePhoto,
    RowTypeName,
    RowTypeLocation,
    RowTypeDescription,
} RowType;

@interface LadyDetailViewController () <PZPhotoViewDelegate, PZPagingScrollViewDelegate, UIActionSheetDelegate, KKCheckButtonDelegate, ContactManagerDelegate>
@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, strong) NSArray* items;
@property (nonatomic, strong) NSArray* imageViewLoaders;
@property (nonatomic, strong) NSArray* tableViewArray;
/** 请求管理者 */
@property (nonatomic,strong) SessionRequestManager *sessionManager;
/** 女士详情内容 */
@property (nonatomic,strong) LadyDetailItemObject *item;
/** 图片管理 */
@property (nonatomic,strong) ImageViewLoader *imageViewLoader;

/** 女士图片大图 */
@property (nonatomic,strong) UIImageView *ladyImageView;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet KKCheckButton *addFavouriteBtn;

/** 图片地址 */
@property (nonatomic,strong) NSMutableArray *pathArray;
/** contactlist */
@property (nonatomic,strong) ContactManager *contactManager;
@end

@implementation LadyDetailViewController

- (NSMutableArray *)pathArray{
    if (!_pathArray) {
        _pathArray = [NSMutableArray array];
    }
    return _pathArray;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _curIndex = 0;
    self.contactManager = [ContactManager manager];
    [self.contactManager addDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if( !self.viewDidAppearEver ) {
        [self getLadyDetail];
        [self reloadData:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - 界面逻辑
- (void)initNavigationItems {
    self.customBackTitle = @"Home";
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
    NSString* title = [NSString stringWithFormat:@"%ld/%lu", self.items.count > 0?(long)_curIndex + 1:0, (unsigned long)self.items.count];
    [button setTitle:title forState:UIControlStateNormal];
    [button sizeToFit];
    [button setEnabled:NO];
    self.navigationItem.titleView = button;
    
    if (self.items.count == 0) {
        self.navigationItem.titleView.hidden = YES;
    }
    
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
    self.addFavouriteBtn.adjustsImageWhenHighlighted = NO;
    self.addFavouriteBtn.selectedChangeDelegate = self;

}

- (void)setupTableView {
    self.tableView.separatorColor = [UIColor grayColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    headerView.backgroundColor = self.tableView.separatorColor;
    [self.tableView setTableHeaderView:headerView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
    
    
}

- (IBAction)reportAction:(id)sender {
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report", nil];
    
    [sheet showInView:self.view];
}

- (IBAction)chatAction:(id)sender {
    ChatViewController* vc = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
    vc.firstname = self.item.firstname;
    vc.womanId = self.item.womanid;
    vc.photoURL = self.item.photoURL;
    [self.navigationController pushViewController:vc animated:YES];
}



- (void)selectedChanged:(id)sender {
    UIButton *favoriteBtn = (UIButton *)sender;
    if (favoriteBtn.selected == YES) {
        [favoriteBtn setImage:[UIImage imageNamed:@"LadyDetail-Favorite"] forState:UIControlStateSelected];
        self.item.isFavorite = YES;
        [self addFavouriesLady];

    } else {
        [favoriteBtn setImage:[UIImage imageNamed:@"LadyDetail-UnFavorite" ] forState:UIControlStateSelected];
        self.item.isFavorite = NO;

        [self removeFavouriesLady];
    }
}


#pragma mark - 图片点击手势方法
- (void)lookBigPicture{

    LadyDetailPhototViewController *photo = [[LadyDetailPhototViewController alloc] init];
    photo.ladyListArray = self.items;
    photo.ladyListPath = self.pathArray;
    [self presentViewController:photo animated:YES completion:nil];
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
    viewSize = CGSizeMake(self.tableView.frame.size.width, self.view.frame.size.width);
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
    
    // 国家
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonTitleTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeLocation] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    // 描述
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonDetailTableViewCell cellHeight:self.tableView.frame.size.width detailString:self.item.resume]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeDescription] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    self.tableViewArray = array;
    
    
    if( isReloadView ) {
        [self setupNavigationBar];
        [self.tableView reloadData];
        if (self.item.isFavorite) {
             self.addFavouriteBtn.selected = YES;
            [self.addFavouriteBtn setImage:[UIImage imageNamed:@"LadyDetail-Favorite"] forState:UIControlStateSelected];
        }else{
            [self.addFavouriteBtn setImage:[UIImage imageNamed:@"LadyDetail-UnFavorite"] forState:UIControlStateSelected];
        }

    }
    
    
}

#pragma mark - 画廊回调 (PZPagingScrollViewDelegate)
- (Class)pagingScrollView:(PZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    return [UIImageView class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(PZPagingScrollView *)pagingScrollView {
    
    //    return (nil == self.items)?0:self.items.count;
    NSUInteger count = 0;
    if (self.items == nil) {
        count = 0;
        
    }else{
        count = self.items.count;
        if (count == 0) {
            count = 1;
        }
    }
    return count;
}

- (UIView *)pagingScrollView:(PZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    UIImageView* view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, pagingScrollView.frame.size.width, pagingScrollView.frame.size.height)];
    [view setContentMode:UIViewContentModeScaleAspectFill];
//    [view setContentMode:UIViewContentModeScaleToFill];
    return view;
}

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {

    ImageViewLoader *imageViewLoader = [[ImageViewLoader alloc] init];
    if (self.item.photoList.count > 0) {
        imageViewLoader = [self.imageViewLoaders objectAtIndex:index];
        imageViewLoader.view = pageView;
        imageViewLoader.url = [self.item.photoList objectAtIndex:index];
        imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:imageViewLoader.url];
        [self.pathArray addObject:imageViewLoader.path];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [imageViewLoader loadImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *topImageView = (UIImageView *)imageViewLoader.view;
        
                topImageView.image = [self clipImage:topImageView.image toRect:pageView.frame.size];

                imageViewLoader.view = topImageView;

            });
        });
        
        
    

    }else{
        UIImageView* view = (UIImageView *)pageView;
        imageViewLoader.view = view;
        if (self.itemObject.photoURL.length > 0) {
            imageViewLoader.url = self.itemObject.photoURL;
            imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:imageViewLoader.url];
            [imageViewLoader loadImage];
        }else{
            [view setImage:[UIImage imageNamed:@"LadyList-Lady-Default"]];
        }

    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookBigPicture)];
    imageViewLoader.view.userInteractionEnabled = YES;
    [imageViewLoader.view addGestureRecognizer:tap];
    self.imageViewLoader = imageViewLoader;


    
}

/**
 *  返回指定尺寸的图片
 *
 *  @param image  需要改变的图片
 *  @param reSize 需要改变的大小
 *
 *  @return 指定尺寸的图片
 */



- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{

    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];

    return newImage;
}

/**
 *  计算图片比例
 *
 *  @param image 图片的大小
 *  @param size  截取的大小
 *
 *  @return 截取完成的图片
 */
- (UIImage *)clipImage:(UIImage *)image toRect:(CGSize)size{
    if (image.size.width * size.height <= image.size.height * size.width) {
        CGFloat width  = image.size.width;
        CGFloat height = image.size.width * size.height / size.width;
        return [self imageFromImage:image inRect:CGRectMake(0, 0, width, height)];
    }else{
        CGFloat width  = image.size.height * size.width / size.height;
        CGFloat height = image.size.height;
        return [self imageFromImage:image inRect:CGRectMake((image.size.width - width) / 2, 0, width, height)];
    }
    return nil;
}




- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    
    _curIndex = index;
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
                cell.curIndex = _curIndex;
                self.pagingScrollView = cell.pagingScrollView;
                if (self.item.isonline) {
                    [cell.onlineView setBackgroundColor:[UIColor colorWithIntRGB:102 green:153 blue:0 alpha:255]];
                }else {
                    [cell.onlineView setBackgroundColor:[UIColor colorWithIntRGB:161 green:161 blue:161 alpha:255]];
                }
                
                
            }break;
            case RowTypeName:{
                // 姓名
                LadyDetailNameTableViewCell *cell = [LadyDetailNameTableViewCell getUITableViewCell:tableView];
                result = cell;
                cell.titleLabel.text = [NSString stringWithFormat:@"%@, %d",self.item.firstname,self.item.age];
                if (self.item.isonline) {
                    cell.detailLabel.text = @"Online";
                    self.chatBtn.enabled = YES;
                }else {
                    cell.detailLabel.text = @"Offine";
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
                NSString *resume;
                if ([self.item.resume containsString:@"<br />"]) {
                    resume  = [self.item.resume stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
                }else{
                    resume = self.item.resume;
                }
                cell.detailLabel.text = resume;
                
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
- (BOOL)getLadyDetail{
    self.sessionManager = [SessionRequestManager manager];
    GetLadyDetailRequest *request = [[GetLadyDetailRequest alloc] init];
    request.womanId = self.itemObject.womanid;
    self.item = [[LadyDetailItemObject alloc] init];
    request.finishHandler = ^(BOOL success, LadyDetailItemObject *item, NSString * _Nullable errnum, NSString * _Nullable errmsg){
        if (success) {
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.item = item;
            self.items = self.item.photoList;
            NSMutableArray* mutableArray = [NSMutableArray array];
            for (int count = 0; count < self.item.photoList.count; count++) {
                [mutableArray addObject:[[ImageViewLoader alloc] init]];
            }
            self.imageViewLoaders = mutableArray;

            [self reloadData:YES];
        });
        
    };
    
    return [self.sessionManager sendRequest:request];
}

- (BOOL)addFavouriesLady{
    self.sessionManager = [SessionRequestManager manager];
    AddFavouriteLadyRequest *request = [[AddFavouriteLadyRequest alloc] init];
    request.womanId = self.item.womanid;
    request.finishHandler = ^(BOOL success,NSString *error,NSString *errmsg){
        if (success) {
            // 收藏成功, 增加最近联系人
            LadyRecentContactObject* recent = [[LadyRecentContactObject alloc] init];
            recent.womanId = self.item.womanid;
            recent.firstname = self.item.firstname;
            recent.photoURL = self.item.photoURL;
            recent.lasttime = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSinceReferenceDate];
            
            [self.contactManager addRecentContact:recent];
        }
    };
    return [self.sessionManager sendRequest:request];
    
}

- (BOOL)removeFavouriesLady{
    self.sessionManager = [SessionRequestManager manager];
    RemoveFavouriteLadyRequest *request = [[RemoveFavouriteLadyRequest alloc] init];
    request.womanId = self.item.womanid;
    request.finishHandler = ^(BOOL success,NSString *error,NSString *errmsg){


        
    };
    return [self.sessionManager sendRequest:request];
    
}

@end
