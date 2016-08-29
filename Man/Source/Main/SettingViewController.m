//
//  SettingViewController.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SettingViewController.h"
#import "CommonTitleDetailTableViewCell.h"

#import "AddCreditsViewController.h"
#import "LoginViewController.h"

#import "GetCountRequest.h"
#import "GetPersonProfileRequest.h"
#import "MyProfileViewController.h"
#import "CommonSettingTableViewCell.h"
#import "AppSettingContentViewController.h"

#import "LoginManager.h"

typedef enum {
    RowTypeSetting,
    RowTypeAppSetting,
    RowTypeAddCredits,
} RowType;

@interface SettingViewController ()

/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager* sessionManager;

@property (nonatomic, strong) ImageViewLoader* imageViewLoader;
@property (nonatomic, strong) NSArray *tableViewArray;

@property (nonatomic, strong) NSString* imageUrl;
@property (nonatomic, strong) NSString* firstname;

- (void)setupHeadPhoto;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navRightButton addTarget:self.mainVC action:@selector(pageRightAction:) forControlEvents:UIControlEventTouchUpInside];

    self.CreditsBalanceCount.layer.cornerRadius = 8.0f;
    self.CreditsBalanceCount.layer.masksToBounds = YES;
    
    self.sessionManager = [SessionRequestManager manager];
    
    self.imageUrl = @"";
    self.firstname = @"";
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.CreditBar.layer.cornerRadius = 8.0f;
    self.CreditBar.layer.masksToBounds = YES;
    // 获取余额
    [self getCount];
    
    // 获取男士资料
    [self getPersonalProfile];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadData:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 界面逻辑
- (void)initCustomParam {
    // 初始化父类参数
    [super initCustomParam];
    self.backTitle = NSLocalizedString(@"Setting", nil);
}

- (void)unInitCustomParam {

}

- (void)setupNavigationBar {
    [super setupNavigationBar];
}

- (void)setupContainView {
    [super setupContainView];
    
    [self setupHeadPhoto];
    [self setupTableView];
}

- (void)setupHeadPhoto {
    self.imageViewHead.layer.cornerRadius = self.imageViewHead.frame.size.height / 2;
    self.imageViewHead.layer.masksToBounds = YES;
    
    self.imageViewHead.layer.borderWidth = 5.0;
    self.imageViewHead.layer.borderColor = [UIColor whiteColor].CGColor;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPersonalMessage)];
    [self.imageViewHead addGestureRecognizer:tap];
}

- (void)setupTableView {
//    self.tableView.separatorColor = [UIColor grayColor];
//    
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
//    headerView.backgroundColor = self.tableView.separatorColor;
//    headerView.alpha = 0.4f;
//    [self.tableView setTableHeaderView:headerView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
    
}

- (IBAction)addCreditsAction:(id)sender {
    KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
    // 1。创建充值的控制器
    AddCreditsViewController *credits = [[AddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    // 2。点击跳转
    [nvc pushViewController:credits animated:YES];
    
}


- (void)editPersonalMessage{
     KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
    // 个人资料
    MyProfileViewController *profile = [[MyProfileViewController alloc] initWithNibName:nil bundle:nil];
    [nvc pushViewController:profile animated:YES];
}
#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    
    // 主tableView
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    CGSize viewSize;
    NSValue *rowSize;
    
    // 个人资料
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(_tableView.frame.size.width, [CommonSettingTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeSetting] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    // 设置
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(_tableView.frame.size.width, [CommonSettingTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeAppSetting] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    // 充值
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(_tableView.frame.size.width, [CommonSettingTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeAddCredits] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    self.tableViewArray = array;
    
    if(isReloadView) {
        [self.tableView reloadData];
        
        // 头像
        self.imageViewHead.image = [UIImage imageNamed:@"Setting-HeaderImage-Test"];
        [self.imageViewLoader stop];
        self.imageViewLoader = [ImageViewLoader loader];
        self.imageViewLoader.view = self.imageViewHead;
        self.imageViewLoader.url = self.imageUrl;
        if ([self.imageViewLoader.url isEqualToString:AppDelegate().errorUrlConnect]) {
//            self.imageViewHead.image = [UIImage imageNamed:@"Setting-HeaderImage-Test"];
        } else {
            self.imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:self.imageViewLoader.url];
            [self.imageViewLoader loadImage];
        }
        
        // 名字
        self.titleLabel.text = self.firstname;
    }
}

- (BOOL)getCount {
    GetCountRequest* request = [[GetCountRequest alloc] init];
    request.finishHandler = ^(BOOL success, OtherGetCountItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
        if( success ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"SettingViewController::getCount( 获取男士余额成功 )");
                if( item ) {
                     [self.CreditsBalanceCount setTitle:[NSString stringWithFormat:@"%.1f", item.money] forState:UIControlStateNormal];
                    [self.CreditsBalanceCount sizeToFit];
                }
            });
        }
    };
    return [self.sessionManager sendRequest:request];
}

- (BOOL)getPersonalProfile{
    self.sessionManager = [SessionRequestManager manager];
    GetPersonProfileRequest *request = [[GetPersonProfileRequest alloc] init];
    request.finishHandler = ^(BOOL success, PersonalProfile *item, NSString *error, NSString *errmsg){
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"SettingViewController::getPersonalProfile( 获取男士详情成功 )");
//                if ([item.photoUrl isEqualToString:errorUrl]) {


                     self.imageUrl = item.photoUrl;

               
                self.firstname = item.firstname;
                [self reloadData:YES];
            });
            
        }
        
    };
    return [self.sessionManager sendRequest:request];
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
            case RowTypeSetting:{
                // 个人资料
                
                CommonSettingTableViewCell *cell = [CommonSettingTableViewCell getUITableViewCell:tableView];
                result = cell;
                
                [cell.leftImageView setImage:[UIImage imageNamed:@"Setting-MyProfile"]];
                cell.titleLabel.text = NSLocalizedStringFromSelf(@"MY_PROFILE");
                cell.titleLabel.textColor = [UIColor colorWithIntRGB:255 green:102 blue:0 alpha:255];
                cell.detailLabel.text = NSLocalizedStringFromSelf(@"EDIT_VIEW_PROFILE");
                cell.detailLabel.textColor = [UIColor colorWithIntRGB:121 green:121 blue:121 alpha:255];
                cell.detailLabel.font = [UIFont systemFontOfSize:14];
                
            }break;
            case RowTypeAppSetting:{
                // 设置
                CommonSettingTableViewCell *cell = [CommonSettingTableViewCell getUITableViewCell:tableView];
                result = cell;
                
                [cell.leftImageView setImage:[UIImage imageNamed:@"Setting-AppSettings"]];
                cell.titleLabel.text = NSLocalizedStringFromSelf(@"APP_SETTINGS");
                cell.titleLabel.textColor = [UIColor colorWithIntRGB:255 green:102 blue:0 alpha:255];
                cell.detailLabel.text = NSLocalizedStringFromSelf(@"NOTIFICATION_ACCOUNT_AND_OTHER");
                cell.detailLabel.textColor = [UIColor colorWithIntRGB:121 green:121 blue:121 alpha:255];
                cell.detailLabel.font = [UIFont systemFontOfSize:14];
                
            }break;
            case RowTypeAddCredits:{
                // 充值
                CommonSettingTableViewCell *cell = [CommonSettingTableViewCell getUITableViewCell:tableView];
                result = cell;
                
                [cell.leftImageView setImage:[UIImage imageNamed:@"Setting-AddCredits"]];
                cell.titleLabel.textColor = [UIColor colorWithIntRGB:0 green:102 blue:255 alpha:255];
                cell.titleLabel.text = NSLocalizedStringFromSelf(@"ADD_CREDITS");
                cell.detailLabel.text = NSLocalizedStringFromSelf(@"CREDITS_ARE_USED_TO_CONNECT_PEOPLE");
                cell.detailLabel.font = [UIFont systemFontOfSize:14];
                cell.detailLabel.textColor = [UIColor colorWithIntRGB:121 green:121 blue:121 alpha:255];
                [cell setSeparatorInset:UIEdgeInsetsZero];
                
            }break;
            default:break;
        }
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
    
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
        
        // 类型
        RowType type = (RowType)[[dictionarry valueForKey:ROW_TYPE] intValue];
        switch (type) {
            case RowTypeSetting:{
                // 个人资料
                MyProfileViewController *profile = [[MyProfileViewController alloc] initWithNibName:nil bundle:nil];
                [nvc pushViewController:profile animated:YES];
                
            }break;
            case RowTypeAppSetting:{
                // 设置
//                AppSettingViewController *appSetting = [[AppSettingViewController alloc] initWithNibName:nil bundle:nil];
//
//                [nvc pushViewController:appSetting animated:YES];
                
                AppSettingContentViewController *appSetting = [[AppSettingContentViewController alloc] initWithNibName:nil bundle:nil];
                [nvc pushViewController:appSetting animated:YES];
            }break;
            case RowTypeAddCredits:{
                // 充值
                // 1。创建充值的控制器
                AddCreditsViewController *credits = [[AddCreditsViewController alloc] initWithNibName:nil bundle:nil];

                // 2。点击跳转
                [nvc pushViewController:credits animated:YES];
                
            }
                
                break;
            default:break;
        }
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
