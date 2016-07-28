//
//  RegisterSecondStepViewController.m
//  dating
//
//  Created by lance on 16/3/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "RegisterSecondStepViewController.h"
#import "LoginViewController.h"
#import "CommonTextFieldTableViewCell.h"
#import "RequestManager.h"
#import "RegisterProfileObject.h"
#import "CoverView.h"
#import "FileCacheManager.h"
#import "ConfigManager.h"
#import "ServerManager.h"
#import "LoginManager.h"
#import "SessionRequestManager.h"
#import "UploadHeaderPhoto.h"


typedef enum : NSUInteger {
    RegisterAccountTypeEmail,
    RegisterAccountTypePassword,
    RegisterAccountTypeCheckPassword
} RegisterAccountType;


typedef enum : NSUInteger {
    RegisterTipTypeSuccess = 9009,
    RegisterTipTypeFail,
    RegisterTipTypeOther,
} RegisterTipType;



@interface RegisterSecondStepViewController ()<UITextFieldDelegate,UIAlertViewDelegate>{
    CGRect _orgFrame;
    CGRect _newFrame;
}


/** cell名称 */
@property (nonatomic,strong) NSArray *dataName;
/** 输入的名称 */
@property (nonatomic,strong) NSArray *dataTextName;
/** 占位文字 */
@property (nonatomic,strong) NSArray *placeholderText;
/** email */
@property (nonatomic,strong) UITextField *emailTextField;
/** password */
@property (nonatomic,strong) UITextField *passwordTextField;
/** checkPassword */
@property (nonatomic,strong) UITextField *checkPasswordTextField;
/** 任务管理 */
@property (nonatomic,strong) SessionRequestManager *sessionManager;

/** tips */
@property (nonatomic,strong) UIAlertView *alertView;

/** <#detail#> */
@property (nonatomic,strong) NSArray *tableViewArray;

@end

@implementation RegisterSecondStepViewController


#pragma mark - view生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 记录inputview原始大小
    if( CGRectIsEmpty(_orgFrame) ) {
        _orgFrame = self.finishBtn.frame;
        
    }
    // 是否用新frame
    if( !CGRectIsEmpty(_newFrame) ) {
        self.finishBtn.frame = _newFrame;
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.loadingView.hidden = YES;
    [self reloadData:YES];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
 
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

#pragma mark - 界面逻辑
- (void)initCustomParam {
    [super initCustomParam];
}

//设置导航栏
- (void)setupNavigationBar{
    [super setupNavigationBar];
    UILabel *Register = [[UILabel alloc] init];
    Register.textColor = [UIColor whiteColor];
    Register.text = NSLocalizedString(@"Register", nil);
    [Register sizeToFit];
    self.navigationItem.titleView = Register;


}

- (void)setupTableView {
//    self.tableView.separatorColor = [UIColor grayColor];
    
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
//    headerView.backgroundColor = self.tableView.separatorColor;
//    headerView.alpha = 0.4f;
//    [self.tableView setTableHeaderView:headerView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
    
}

- (void)setupContainView{
    [super setupContainView];
    [self setupTableView];
}

#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView{
    // 主tableView
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    CGSize viewSize;
    NSValue *rowSize;
    
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonTextFieldTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RegisterAccountTypeEmail] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonTextFieldTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RegisterAccountTypePassword] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonTextFieldTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RegisterAccountTypeCheckPassword] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    self.tableViewArray = array;
    
    if (isReloadView) {
        [self.tableView reloadData];
    }
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
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



- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

//    UITableViewCell *result = nil;
//    CommonTextFieldTableViewCell *commomTextCell = [CommonTextFieldTableViewCell getUITableViewCell:tableView];
//    result = commomTextCell;
//    commomTextCell.detailLabel.text = self.dataName[indexPath.row];
//    commomTextCell.contentTextField.placeholder = self.placeholderText[indexPath.row];
//    [commomTextCell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    if (indexPath.row == 0) {
//        self.emailTextField  = commomTextCell.contentTextField;
//        self.emailTextField.delegate = self;
//    }else if (indexPath.row == 1){
//        self.passwordTextField = commomTextCell.contentTextField;
//        self.passwordTextField.delegate = self;
//        self.passwordTextField.secureTextEntry = YES;
//    }else{
//        commomTextCell.contentTextField.returnKeyType = UIReturnKeyDone;
//        self.checkPasswordTextField = commomTextCell.contentTextField;
//        self.checkPasswordTextField.delegate = self;
//        self.checkPasswordTextField.secureTextEntry = YES;
//    }
// 
//    return result;
    

        UITableViewCell *result = nil;
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
        
        // 大小
        CGSize viewSize;
        NSValue *value = [dictionarry valueForKey:ROW_SIZE];
        [value getValue:&viewSize];
        CommonTextFieldTableViewCell *commomCell = [CommonTextFieldTableViewCell getUITableViewCell:tableView];
        result = commomCell;
        [commomCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // 类型
        RegisterAccountType type = (RegisterAccountType)[[dictionarry valueForKey:ROW_TYPE] intValue];
        switch (type) {
            case RegisterAccountTypeEmail:{
                    commomCell.detailLabel.text = NSLocalizedStringFromSelf(@"YOUR_EMAIL_ADDRESS");
                    commomCell.contentTextField.placeholder = NSLocalizedStringFromSelf(@"EMAIL_PLACEHOLDER");
                        self.emailTextField  = commomCell.contentTextField;
                        self.emailTextField.delegate = self;

            }break;
            case RegisterAccountTypePassword:{
                commomCell.detailLabel.text = NSLocalizedStringFromSelf(@"YOUR_PASSWORD");
                commomCell.contentTextField.placeholder = NSLocalizedStringFromSelf(@"ENTER");
                        self.passwordTextField = commomCell.contentTextField;
                        self.passwordTextField.delegate = self;
                        self.passwordTextField.secureTextEntry = YES;

            }break;
            case RegisterAccountTypeCheckPassword:{
                commomCell.detailLabel.text = NSLocalizedStringFromSelf(@"CONFIRM_PASSWORD");
                commomCell.contentTextField.placeholder = NSLocalizedStringFromSelf(@"ENTER");
                        commomCell.contentTextField.returnKeyType = UIReturnKeyDone;
                        self.checkPasswordTextField = commomCell.contentTextField;
                        self.checkPasswordTextField.delegate = self;
                        self.checkPasswordTextField.secureTextEntry = YES;

            }break;

                      default:
                break;
        }
    }
    
    return result;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - 监听按钮操作
//实现返回按钮的功能
- (void)backToSettings{
    [self closeKeyBoard];
    [self.navigationController popViewControllerAnimated:YES];
}

//创建账号
- (IBAction)createAccount:(id)sender {
    self.loadingView.hidden = NO;
    
    if ([self.emailTextField isFirstResponder] || [self.passwordTextField isFirstResponder] || [self.checkPasswordTextField isFirstResponder]) {
        [self closeKeyBoard];
        [self checkPassword];
        self.loadingView.hidden = YES;
        
    }else{
        
        RequestManager *manager = [RequestManager manager];
        
        NSString *year;
        NSString *month;
        NSString *day;
        //分别获取年月日
        if (self.lastProfileObject.birthday.length > 0) {
            year = [self.lastProfileObject.birthday substringToIndex:4];
            month = [self.lastProfileObject.birthday substringWithRange:NSMakeRange(5, 2)];
            day = [self.lastProfileObject.birthday substringFromIndex:8];
        }
        
        //将self改为弱引用的self
        __weak typeof(self) weakSelf = self;
        if (self.lastProfileObject.email && self.lastProfileObject.email.length > 0  && self.lastProfileObject.password && self.lastProfileObject.password.length > 0  && self.lastProfileObject.name && self.lastProfileObject.name.length > 0 && self.lastProfileObject.birthday.length > 0 && self.lastProfileObject.birthday) {
            
            // 配置假服务器路径
            [[ConfigManager manager] clean];
            [[ServerManager manager] clean];
            [AppDelegate() setRequestHost:NO];
            
            [manager registerUser:self.lastProfileObject.email password:self.lastProfileObject.password sex:self.lastProfileObject.isMale firstname:self.lastProfileObject.name lastname:self.lastProfileObject.name country:self.countryIndex birthday_y:year birthday_m:month birthday_d:day weeklymail:NO  finishHandler:^(BOOL success, RegisterItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.loadingView.hidden = YES;
            
                    if (success) {
                        if (weakSelf.profileImage) {
                            [self upLoadHeaderPhoto];
                            
                        } else {
                            NSString *tips = NSLocalizedStringFromSelf(@"TIPS");
                            NSString *tipsMessage = NSLocalizedStringFromSelf(@"TIPS_REGISTERMESSAGE_SUCCESS");
                            NSString *confirm = NSLocalizedStringFromSelf(@"OK");
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:tips message:tipsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:confirm, nil ,nil];
                            alertView.tag = RegisterTipTypeSuccess;
                            [alertView show];
                        }

                    } else {

                        NSString *tips = NSLocalizedStringFromSelf(@"TIPS");
                        NSString *tipsMessage = NSLocalizedStringFromSelf(@"TIPS_REGISTERMESSAGE_FAIL");
                        NSString *confirm = NSLocalizedStringFromSelf(@"OK");
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:tips message:[NSString stringWithFormat:@"%@  %@ ",tipsMessage,errmsg] delegate:self cancelButtonTitle:nil otherButtonTitles:confirm, nil ,nil];
                        alertView.tag = RegisterTipTypeFail;
                        [alertView show];
                    }
                    
                });
                
            }];
            
        }else{
            self.loadingView.hidden = YES;
            //弹出提示
            NSString *tips = NSLocalizedStringFromSelf(@"TIPS");
            NSString *tipsMessage = NSLocalizedStringFromSelf(@"TIPS_REGISTERMESSAGE_NULL");
            NSString *confirm = NSLocalizedStringFromSelf(@"OK");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:tips message:tipsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:confirm, nil ,nil];
            [alertView show];
            
        }

    }

   
    

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    LoginManager* manager = [LoginManager manager];
    if (alertView.tag == RegisterTipTypeSuccess) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [manager login:self.lastProfileObject.email password:self.lastProfileObject.password checkcode:nil];
    }else if (alertView.tag == RegisterTipTypeOther){
        [self.navigationController popToRootViewControllerAnimated:YES];
        [manager login:self.lastProfileObject.email password:self.lastProfileObject.password checkcode:nil];
    }else if (alertView.tag == RegisterTipTypeFail){
        self.passwordTextField.text = nil;
        self.checkPasswordTextField.text = nil;
    }
}


//关闭键盘
- (void)closeKeyBoard {
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.checkPasswordTextField resignFirstResponder];
}


- (BOOL)upLoadHeaderPhoto{
    self.loadingView.hidden = NO;
    self.sessionManager = [SessionRequestManager manager];
    UploadHeaderPhoto *request = [[UploadHeaderPhoto alloc] init];
    request.fileName = self.profilePhoto;
    request.finishHandler = ^(BOOL success,NSString *error,NSString *errmsg){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadingView.hidden = YES;
            NSString *tips = NSLocalizedStringFromSelf(@"TIPS");
            NSString *tipsMessage = NSLocalizedStringFromSelf(@"TIPS_REGISTERMESSAGE_SUCCESS");
            NSString *confirm = NSLocalizedStringFromSelf(@"OK");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:tips message:tipsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:confirm, nil ,nil];
            alertView.tag = RegisterTipTypeSuccess;
            [alertView show];
        });

    };
    return [self.sessionManager sendRequest:request];
    
}



#pragma mark - 输入回调
- (void)textViewDidChange:(UITextView *)textView {
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

    self.lastProfileObject.email = self.emailTextField.text;
    self.lastProfileObject.password = self.passwordTextField.text;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]){
        // 判断输入的字是否是回车，即按下return
        [textField resignFirstResponder];
        return NO;
    }
    if (range.location >= 30) {
        return NO;
    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( self.emailTextField == textField ) {
        // 完成email

        self.lastProfileObject.email = self.emailTextField.text;
  
        [self.passwordTextField becomeFirstResponder];
        
    } else if( self.passwordTextField == textField ) {
        // 完成密码
              self.lastProfileObject.password = self.passwordTextField.text;
        [self.checkPasswordTextField becomeFirstResponder];
        
    } else {
        [self checkPassword];

        [self.checkPasswordTextField resignFirstResponder];
    }
    return YES;
}




- (void)checkPassword{
    
    // 确认密码
    if (![self.passwordTextField.text isEqualToString:self.checkPasswordTextField.text]) {
    //提示两次密码错误,重新输入密码
    NSString *tips = NSLocalizedStringFromSelf(@"TIPS");
    NSString *tipsMessage = NSLocalizedStringFromSelf(@"TIPS_CONFIRMPASSWORD_FAIL");
    NSString *confirm = NSLocalizedStringFromSelf(@"OK");
    UIAlertView *falsePassword = [[UIAlertView alloc] initWithTitle:tips message:tipsMessage delegate:self cancelButtonTitle:confirm otherButtonTitles:nil, nil];
//    falsePassword.tag = 9011;
    [falsePassword show];
    self.passwordTextField.text = nil;
    self.checkPasswordTextField.text = nil;
    [self.passwordTextField becomeFirstResponder];
    }
}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration animations:^{
        if(height > 0) {
            // 弹出键盘
            _newFrame = CGRectMake(_orgFrame.origin.x, _orgFrame.origin.y - height, _orgFrame.size.width, _orgFrame.size.height);
            self.finishBtn.frame = _newFrame;
            
        } else {
            self.finishBtn.frame = _orgFrame;
            _newFrame = CGRectZero;
            
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}




@end
