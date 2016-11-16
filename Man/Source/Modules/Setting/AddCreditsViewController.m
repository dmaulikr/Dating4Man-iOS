//
//  addCreditsViewController.m
//  dating
//
//  Created by lance on 16/3/8.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  setting添加credits

#import "AddCreditsViewController.h"

#import "CommonDetailAndAccessoryTableViewCell.h"
#import "CommonTitleTableViewCell.h"
#import "CoverView.h"
#import "CommonData.h"
#import "CommonCreditTableViewCell.h"

#import "GetCountRequest.h"

#import "PaymentManager.h"
#import "PaymentErrorCode.h"

typedef enum AlertType {
    AlertTypeDefault = 100000,
    AlertTypeAppStorePay,
    AlertTypeCheckOrder
} AlertType;


typedef enum : NSUInteger {
    CreditsViewTypeBanlance,
    CreditsViewTypeTitle,
    CreditsViewTypeCreditLevel,
} CreditsViewType;


@interface AddCreditsViewController() <PaymentManagerDelegate>

/**
 *  数据列表
 */
@property (nonatomic,strong) NSArray *tableViewDataArray;
/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager* sessionManager;

/**
 *  余额
 */
@property (nonatomic, strong) NSString* money;

/**
 *  支付管理器
 */
@property (nonatomic, strong) PaymentManager* paymentManager;

/**
 *  当前支付订单号
 */
@property (nonatomic, strong) NSString* orderNo;
/**
 *  行数
 */
@property (nonatomic, strong) NSArray *tableViewArray;

@end

@implementation AddCreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = NO;
    [self reloadData:YES];
    [self getCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 界面事件
- (void)setupNavigationBar{
    [super setupNavigationBar];
    UILabel *credits = [[UILabel alloc] init];
    credits.textColor = [UIColor whiteColor];
    credits.text = NSLocalizedStringFromSelf(@"Credits");
    [credits sizeToFit];
    self.navigationItem.titleView = credits;
    
    [self.mainVC setupNavigationBar];
}

- (void)setupContainView {
    [super setupContainView];
//    [self setupLoadingView];
    [self setupTableView];
}

- (void)setupTableView {
    //    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    //    headerView.backgroundColor = self.tableView.separatorColor;
    //    headerView.alpha = 0.4f;
    //    [self.tableView setTableHeaderView:headerView];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
}

//- (void)setupLoadingView {
//    // 初始化菊花
//    self.loadingView.layer.cornerRadius = 5.0f;
//    self.loadingView.layer.masksToBounds = YES;
//    self.loadingView.hidden = YES;
//}

- (void)initCustomParam {
    // 初始化父类参数
    [super initCustomParam];
    self.backTitle = NSLocalizedString(@"", nil);
    
    self.orderNo = @"";
    self.money = @"0.0";
    
    self.sessionManager = [SessionRequestManager manager];
    
    self.paymentManager = [PaymentManager manager];
    [self.paymentManager addDelegate:self];
}

- (void)dealloc {
    [self.paymentManager removeDelegate:self];
}

//- (void)showLoading {
//    self.loadingView.hidden = NO;
//    self.view.userInteractionEnabled = NO;
//}

//- (void)hideLoading {
//    self.loadingView.hidden = YES;
//    self.view.userInteractionEnabled = YES;
//}

#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView{

    // credits数据列表
    NSMutableArray *array = [NSMutableArray array];
    CommonData *item = [[CommonData alloc] init];
    item.creditLevel =  NSLocalizedStringFromSelf(@"CREDITS_BALANCE");
    item.creditPrice = self.money;
    [array addObject:item];
    
    item = [[CommonData alloc] init];
    item.creditLevel = NSLocalizedStringFromSelf(@"ADD_MORE_CREDITS");
    item.creditPrice = @"";
    [array addObject:item];
    
    
    item = [[CommonData alloc] init];
    item.creditLevel = NSLocalizedStringFromSelf(@"CREDIT_FIRST_LEVEL");
    item.creditPrice = NSLocalizedStringFromSelf(@"CREDIT_FIRST_LEVEL_PRICE");
    item.creditSet = @"SP2003";
    [array addObject:item];
    
    item = [[CommonData alloc] init];
    item.creditLevel = NSLocalizedStringFromSelf(@"CREDIT_SECOND_LEVEL");
    item.creditPrice = NSLocalizedStringFromSelf(@"CREDIT_SECOND_LEVEL_PRICE");
    item.creditSet = @"SP2008";
    [array addObject:item];
    
    self.items = array;
    
    //    item = [[CommonData alloc] init];
    //    item.creditLevel = @"16 credits";
    //    item.creditPrice = @"$139.99";
    //    [array addObject:item];
    //
    //    item = [[CommonData alloc] init];
    //    item.creditLevel = @"30 credits";
    //    item.creditPrice = @"$21.00";
    //    [array addObject:item];
    //
    //    item = [[CommonData alloc] init];
    //    item.creditLevel = @"60 credits";
    //    item.creditPrice = @"$21.00";
    //    [array addObject:item];
    //
    //    item = [[CommonData alloc] init];
    //    item.creditLevel = @"100 credits";
    //    item.creditPrice = @"$21.00";
    //    [array addObject:item];
    
    
    
    // 主tableView
    NSMutableArray *rowArray = [NSMutableArray array];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    CGSize viewSize;
    NSValue *rowSize;
    

    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonCreditTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:CreditsViewTypeBanlance] forKey:ROW_TYPE];
    [rowArray addObject:dictionary];
    

    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, 46);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:CreditsViewTypeTitle] forKey:ROW_TYPE];
    [rowArray addObject:dictionary];
    
 
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonDetailAndAccessoryTableViewCell cellHeight]);
    //    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonContentTableViewCell cellHeight]);
    
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:CreditsViewTypeCreditLevel] forKey:ROW_TYPE];
    [rowArray addObject:dictionary];
    
    
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonDetailAndAccessoryTableViewCell cellHeight]);
    //    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonContentTableViewCell cellHeight]);
    
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:CreditsViewTypeCreditLevel] forKey:ROW_TYPE];
    [rowArray addObject:dictionary];
    
    self.tableViewArray = rowArray;
    
    if( isReloadView ) {
        [self.tableView reloadData];
    }
}

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


#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    NSInteger count = 0;
    
    if ([tableView isEqual:self.tableView]) {
        count = 1;
    }
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger dataCount = 0;
    
    if ([tableView isEqual:self.tableView]) {
        dataCount = self.items.count ;
    }
    
    return dataCount;
    
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    if (indexPath.row == 0) {
    //        return 74;
    //    }else if (indexPath.row == 1){
    //        return 46;
    //    }
    //
    //    return 106;
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


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *result = nil;
    
    CommonData *item = [self.items objectAtIndex:indexPath.row];
    
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
        
        // 大小
        CGSize viewSize;
        NSValue *value = [dictionarry valueForKey:ROW_SIZE];
        [value getValue:&viewSize];
        
        // 类型
        CreditsViewType type = (CreditsViewType)[[dictionarry valueForKey:ROW_TYPE] intValue];
        switch (type) {
            case CreditsViewTypeBanlance:{
                CommonCreditTableViewCell *cell = [CommonCreditTableViewCell getUITableViewCell:tableView];
                result = cell;
                [cell.creditBtn setTitle:self.money forState:UIControlStateNormal];
                [cell.creditBtn sizeToFit];
                cell.titleLabel.text = item.creditLevel;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }break;
            case CreditsViewTypeTitle:{
                CommonTitleTableViewCell *cell = [CommonTitleTableViewCell getUITableViewCell:tableView];
                result = cell;
                cell.titleLabel.text = item.creditLevel;
                cell.leftImageView.image = [UIImage imageNamed:@"AddCredits-ShopBus"];
                
            }break;
            case CreditsViewTypeCreditLevel:{
                // 自我描述
                CommonDetailAndAccessoryTableViewCell  *cell = [CommonDetailAndAccessoryTableViewCell getUITableViewCell:tableView];
                result = cell;
                
                cell.accessoryLabel.text = item.creditPrice;
                cell.detailLabel.text = item.creditLevel;
                
            }break;
            default:
                break;
        }
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CommonData *item = [self.items objectAtIndex:indexPath.row];
    
    if (indexPath.row > 1) {
        // 支付
        [self showLoading];
        [self.paymentManager pay:item.creditSet];
    }

}


#pragma mark - 监听返回按钮
//实现返回按钮的功能
- (void)backToSettings{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 接口回调
- (BOOL)getCount {
    GetCountRequest* request = [[GetCountRequest alloc] init];
    request.finishHandler = ^(BOOL success, OtherGetCountItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
        if( success ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"AddCreditsViewController::getCount( 获取男士余额成功 )");
                self.money = [NSString stringWithFormat:@"%.2f", item.money];
                [self reloadData:YES];
            });
            
        } else{
            NSLog(@"AddCreditsViewController::getCount( 获取男士余额失败 ) %@",errnum);
        }
    };
    return [self.sessionManager sendRequest:request];
}

#pragma mark - Apple支付回调
- (void)onGetOrderNo:(PaymentManager* _Nonnull)mgr result:(BOOL)result code:(NSString* _Nonnull)code orderNo:(NSString* _Nonnull)orderNo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( result ) {
            NSLog(@"AddCreditsViewController::onGetOrderNo( 获取订单成功, orderNo : %@ )", orderNo);
            self.orderNo = orderNo;
            
        } else {
            NSLog(@"AddCreditsViewController::onGetOrderNo( 获取订单失败, code : %@ )", code);
            
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
                NSLog(@"AddCreditsViewController::onAppStorePay( AppStore支付成功, orderNo : %@ )", orderNo);
                
            } else {
                NSLog(@"AddCreditsViewController::onAppStorePay( AppStore支付失败, orderNo : %@, canRetry :%d )", orderNo, canRetry);
                
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
                NSLog(@"AddCreditsViewController::onCheckOrder( 验证订单成功, orderNo : %@ )", orderNo);
                
            } else {
                NSLog(@"AddCreditsViewController::onCheckOrder( 验证订单失败, orderNo : %@, canRetry :%d, code : %@ )", orderNo, canRetry, code);
                
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
        NSLog(@"AddCreditsViewController::onPaymentFinish( 支付完成 orderNo : %@ )", orderNo);
        
        // 隐藏菊花
        [self hideLoading];
        
        // 弹出提示窗口
        NSString* tips = NSLocalizedStringFromSelf(@"PAY_SUCCESS");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        alertView.tag = AlertTypeDefault;
        [alertView show];
        
        // 清空订单号
        [self cancelPay];
        
        // 刷新点数
        [self getCount];
    });
}

#pragma mark - 点击弹窗提示
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
            
        default:
            break;
    }
}

@end
