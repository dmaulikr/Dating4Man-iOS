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
#import "MonthFeeManager.h"
#import "PaymentManager.h"
#import "PaymentErrorCode.h"
#import "LiveChatManager.h"
#import "ServerManager.h"

#import "GetEMFCountRequest.h"
#import "EMFViewController.h"

typedef enum {
    RowTypeSetting,
    RowTypeAppSetting,
    RowTypeAddCredits,
    RowTypeWebEMF,
} RowType;

typedef enum AlertType {
    AlertTypeDefault = 100000,
    AlertTypeAppStorePay,
    AlertTypeCheckOrder,
    AlertTypeBuyMonthFee
} AlertType;

@interface SettingViewController ()<MonthFeeManagerDelegate,UIAlertViewDelegate,PaymentManagerDelegate, LiveChatManagerDelegate>

/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager* sessionManager;

@property (nonatomic, strong) ImageViewLoader* imageViewLoader;
@property (nonatomic, strong) NSArray *tableViewArray;

@property (nonatomic, strong) NSString* imageUrl;
@property (nonatomic, strong) NSString* firstname;
/** 月费管理器 */
@property (nonatomic,strong) MonthFeeManager *monthFeeManager;

/** 月费类型 */
@property (nonatomic,assign) MonthFeeType memberType;

/**
 余额
 */
@property (strong) OtherGetCountItemObject* otherGetCountItemObject;

/**
 *  支付管理器
 */
@property (nonatomic, strong) PaymentManager* paymentManager;
/**
 *  当前支付订单号
 */
@property (nonatomic, strong) NSString* orderNo;

@property (nonatomic, assign) NSInteger totalEMF;

/**
 *  Livechat管理器
 */
@property (nonatomic, strong) LiveChatManager *liveChatManager;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navRightButton addTarget:self.mainVC action:@selector(pageRightAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.creditsBalanceCount.layer.cornerRadius = 8.0f;
    self.creditsBalanceCount.layer.masksToBounds = YES;
    
    self.premiumView.layer.cornerRadius = 8.0f;
    self.premiumView.layer.masksToBounds = YES;
        
    self.imageUrl = @"";
    self.firstname = @"";
    
    self.totalEMF = 0;
    
    NSLog(@"self.view.frame:%@", NSStringFromCGRect(self.view.frame));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.creditBar.layer.cornerRadius = 8.0f;
    self.creditBar.layer.masksToBounds = YES;

    self.paymentManager = [PaymentManager manager];
    [self.paymentManager addDelegate:self];
    
    self.monthFeeManager = [MonthFeeManager manager];
    [self.monthFeeManager addDelegate:self];
    
    // 获取余额
    [self getCount];
    
    // 获取男士资料
    [self getPersonalProfile];
    
    // 获取EMF没读邮件数
    [self getEMFCount];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.paymentManager removeDelegate:self];
    [self.monthFeeManager removeDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.monthFeeManager getQueryMemberType];
    
    self.imageViewHead.layer.cornerRadius = self.imageViewHead.frame.size.height / 2;
    self.imageViewHead.layer.masksToBounds = YES;
    self.imageViewHead.layer.borderWidth = 5.0f;
    self.imageViewHead.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [self reloadMemberType];
    [self reloadData:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - 界面逻辑
- (void)initCustomParam {
    // 初始化父类参数
    [super initCustomParam];
    self.backTitle = NSLocalizedString(@"Setting", nil);
    
    _memberType = MonthFeeTypeNoramlMember;
    
    self.sessionManager = [SessionRequestManager manager];
    
    self.liveChatManager = [LiveChatManager manager];
    [self.liveChatManager addDelegate:self];

}

- (void)dealloc {
    [self.liveChatManager removeDelegate:self];
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

//- (void)setMemberType:(MonthFeeType)memberType {
//    _memberType = memberType;
//    
//
////    switch (memberType) {
////        case MonthFeeTypeFeeMember:{
////            [self showAlreadyPaidMonthFeeMember];
////            [self showMemberCreditBalance];
////        }break;
////        case MonthFeeTypeNoramlMember:{
////            [self showNormalMemnber];
////            [self showMemberCreditBalance];
////        }break;
////        case MonthFeeTypeFirstFeeMember:
////        case MonthFeeTypeNoFirstFeeMember:{
////            [self showNotPaidMonthFeeMember];
////        }break;
////        default:
////            break;
////    }
//}
/**
 *  显示普通会员
 */
- (void)showNormalMemnber {
    self.premiumViewHeight.constant = 0;
    self.premiumView.hidden = YES;
    self.premiumMarkView.hidden = YES;
    self.buyCreditsBtn.userInteractionEnabled = YES;
}


/**
 *  月费会员未购买月费
 */
- (void)showNotPaidMonthFeeMember {
    
    //月费view
    self.premiumViewHeight.constant = 64;
    self.premiumView.hidden = NO;
    self.buyCreditsBtn.userInteractionEnabled = NO;
    
    //头部月费标识
    self.premiumMarkView.hidden = NO;
    self.premiumMarkView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.premiumMarkView.layer.borderWidth = 2.0f;
    self.premiumMarkView.layer.cornerRadius = 15.0f;
    self.premiumMarkView.layer.masksToBounds = YES;
    [self.premiumMarkView setBackgroundColor:[UIColor clearColor]];
    self.premiumMark.userInteractionEnabled = YES;
     self.premiumMark.imageView.layer.borderWidth = 0.0f;
    [self.premiumMark setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

/**
 *  已经购买月费的月费会员
 */
- (void)showAlreadyPaidMonthFeeMember {
    //月费view
    self.premiumView.hidden = NO;
    self.premiumViewHeight.constant = 0;
    self.buyCreditsBtn.userInteractionEnabled = YES;
    
    //头部月费标识
    self.premiumMarkView.hidden = NO;
    self.premiumMarkView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.premiumMarkView.layer.borderWidth = 3.0f;
    self.premiumMarkView.layer.cornerRadius = 15.0f;
    self.premiumMarkView.layer.masksToBounds = YES;
    [self.premiumMarkView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
    
    self.premiumMark.imageView.layer.borderWidth = 2.0f;
    self.premiumMark.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.premiumMark.imageView.layer.cornerRadius = self.premiumMark.imageView.frame.size.width * 0.5f;
    [self.premiumMark setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    self.premiumMark.userInteractionEnabled = NO;
    
}

/**
 *  显示账户余额
 */
- (void)showMemberCreditBalance {
    self.creditBar.hidden = NO;
    self.creditBalanceHeight.constant = 64;
}

/**
 *  隐藏账户余额
 */
- (void)hideshowMemberCreditBalance {
    self.creditBar.hidden = YES;
    self.creditBalanceHeight.constant = 0;
}

#pragma mark - 点击事件
- (IBAction)buyPremium:(id)sender {
    NSString *tips = NSLocalizedStringFromSelf(@"Tips_Buy_MonthFee");
    UIAlertView *premiumAlertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    premiumAlertView.tag = AlertTypeBuyMonthFee;
    [premiumAlertView show];
    
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
    
    if( [ServerManager manager].item != nil && ![ServerManager manager].item.fake ) {
        // 真服务器
        // EMF
        dictionary = [NSMutableDictionary dictionary];
        viewSize = CGSizeMake(_tableView.frame.size.width, [CommonSettingTableViewCell cellHeight]);
        rowSize = [NSValue valueWithCGSize:viewSize];
        [dictionary setValue:rowSize forKey:ROW_SIZE];
        [dictionary setValue:[NSNumber numberWithInteger:RowTypeWebEMF] forKey:ROW_TYPE];
        [array addObject:dictionary];
    }
    
    if (self.memberType == MonthFeeTypeFeeMember || self.memberType == MonthFeeTypeNoramlMember) {
        // 充值
        dictionary = [NSMutableDictionary dictionary];
        viewSize = CGSizeMake(_tableView.frame.size.width, [CommonSettingTableViewCell cellHeight]);
        rowSize = [NSValue valueWithCGSize:viewSize];
        [dictionary setValue:rowSize forKey:ROW_SIZE];
        [dictionary setValue:[NSNumber numberWithInteger:RowTypeAddCredits] forKey:ROW_TYPE];
        [array addObject:dictionary];
    }
    
    
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

- (void)reloadMemberType {
    NSString* money = @"0.00";
    if( self.otherGetCountItemObject ) {
        money = [NSString stringWithFormat:@"%.2f", self.otherGetCountItemObject.money];
    }
    [self.creditsBalanceCount setTitle:money forState:UIControlStateNormal];
    [self.creditsBalanceCount sizeToFit];
    
    switch (self.memberType) {
            // 不允许买月费或者已经购买
        case MonthFeeTypeNoramlMember: {
            // 隐藏已经购买月费标记
            [self showNormalMemnber];
            // 显示余额按钮
            [self showMemberCreditBalance];
        }break;
        case MonthFeeTypeFeeMember:{
            // 显示已经购买月费标记
            [self showAlreadyPaidMonthFeeMember];
            // 显示余额按钮
            [self showMemberCreditBalance];
            
        }break;
            // 允许买月费
        case MonthFeeTypeFirstFeeMember:
        case MonthFeeTypeNoFirstFeeMember:{
            // 显示购买月费按钮
            [self showNotPaidMonthFeeMember];
            // 显示余额按钮
            if( self.otherGetCountItemObject.money <= 0 ) {
                [self hideshowMemberCreditBalance];
            } else {
                // 显示余额按钮
                [self showMemberCreditBalance];
            }
        }break;
        default:
            break;
    }
}

- (BOOL)getCount {
    GetCountRequest* request = [[GetCountRequest alloc] init];
    request.finishHandler = ^(BOOL success, OtherGetCountItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
        if( success ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"SettingViewController::getCount( 获取男士余额成功 )");
                self.otherGetCountItemObject = item;
                
                [self reloadMemberType];
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

// 获取EMF没读邮件数
- (BOOL)getEMFCount {
    GetEMFCountRequest* request = [[GetEMFCountRequest alloc] init];
    request.finishHandler = ^(BOOL success, int total, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
        if( success ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"SettingViewController::getCount( 获取EMF没读邮件数成功 )");
                if( total > 0 ) {
                    [self.mainVC reloadEMFNotice:YES];
                }
                self.totalEMF = total;
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
            case RowTypeWebEMF:{
                // 充值
                CommonSettingTableViewCell *cell = [CommonSettingTableViewCell getUITableViewCell:tableView];
                result = cell;
                
                [cell.leftImageView setImage:[UIImage imageNamed:@"Setting-WebEMF"]];
                cell.titleLabel.textColor = [UIColor colorWithIntRGB:255 green:102 blue:0 alpha:255];
                cell.titleLabel.text = NSLocalizedStringFromSelf(@"EMF_MAILBOX");
                cell.detailLabel.text = NSLocalizedStringFromSelf(@"READ_AND_SEND_MAIL");
                cell.detailLabel.font = [UIFont systemFontOfSize:14];
                cell.detailLabel.textColor = [UIColor colorWithIntRGB:121 green:121 blue:121 alpha:255];
                if (self.totalEMF > 0) {
                    [cell.detailButton setHidden:NO];
                    [cell.detailButton setTitle:[NSString stringWithFormat:@"%ld",(long)self.totalEMF] forState:UIControlStateNormal];
                    //[cell.detailButton sizeToFit];
                }
                else{
                    [cell.detailButton setHidden:YES];
                }

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
                
            case RowTypeWebEMF:{
                //TestViewController *appSetting = [[TestViewController alloc] initWithNibName:nil bundle:nil];
                //RequestManager* manager = [RequestManager manager];
                //appSetting.cookiesObject = [manager getCookiesItem];
                //[nvc pushViewController:appSetting animated:YES];
                EMFViewController *EMFWebView = [[EMFViewController alloc] initWithNibName:nil bundle:nil];
                [nvc pushViewController:EMFWebView animated:YES];
                
                // 隐藏EMF未读
                [self.mainVC reloadEMFNotice:NO];
            }break;
            default:break;
        }
    }
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

#pragma mark - Apple支付回调
- (void)onGetOrderNo:(PaymentManager* _Nonnull)mgr result:(BOOL)result code:(NSString* _Nonnull)code orderNo:(NSString* _Nonnull)orderNo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( result ) {
            NSLog(@"SettingViewController::onGetOrderNo( 获取订单成功, orderNo : %@ )", orderNo);
            self.orderNo = orderNo;
            
        } else {
            NSLog(@"SettingViewController::onGetOrderNo( 获取订单失败, code : %@ )", code);
            
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

- (void)onAppStorePay:(PaymentManager* _Nonnull)mgr result:(BOOL)result orderNo:(NSString* _Nonnull)orderNo canRetry:(BOOL)canRetry {
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

- (void)onCheckOrder:(PaymentManager* _Nonnull)mgr result:(BOOL)result code:(NSString* _Nonnull)code orderNo:(NSString* _Nonnull)orderNo canRetry:(BOOL)canRetry {
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

- (void)onPaymentFinish:(PaymentManager* _Nonnull)mgr orderNo:(NSString* _Nonnull)orderNo {
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
        self.monthFeeManager.bRequest = NO;
        [self.monthFeeManager getQueryMemberType];
        
    });
}


#pragma mark - 月费管理器回调
- (void)manager:(MonthFeeManager *)manager onGetMemberType:(BOOL)success errnum:(NSString *)errnum errmsg:(NSString *)errmsg memberType:(int)memberType {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"SettingViewController::onGetMemberType( 获取月费类型, memberType : %d )", memberType);
        if (success) {
            self.memberType = (MonthFeeType)memberType;
            [self reloadMemberType];
            [self reloadData:YES];
        }
        
    });
}


@end
