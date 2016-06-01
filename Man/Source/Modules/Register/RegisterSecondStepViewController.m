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
#import "CreditsTipView.h"
#import "CoverView.h"
#import "FileCacheManager.h"
#import "ConfigManager.h"
#import "SessionRequestManager.h"
#import "UploadHeaderPhoto.h"


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

/** <#detail#> */
@property (nonatomic,strong) UIAlertView *alertView;

@end

@implementation RegisterSecondStepViewController

#pragma mark - lazy
- (NSArray *)dataName{
    if (!_dataName) {
        _dataName = @[@"Your email address     |",
                      @"Your password",
                      @"Confirm password"];
    }
    return _dataName;
}

- (NSArray *)placeholderText{
    if (!_placeholderText) {
        _placeholderText = @[@"e.g@domain.com",
                             @"Enter",
                             @"Enter"
                             ];
    }
    return _placeholderText;
}


#pragma mark - view生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activityLoad.hidden = YES;
    

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
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self reloadData:YES];
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

#pragma mark - 界面逻辑
- (void)initNavigationItems {
    self.customBackTitle = @"step1";
}

//设置导航栏
- (void)setupNavigationBar{
    [super setupNavigationBar];
    UILabel *Register = [[UILabel alloc] init];
    Register.textColor = [UIColor whiteColor];
    Register.text = @"Register";
    [Register sizeToFit];
    self.navigationItem.titleView = Register;


}

- (void)setupTableView {
    self.tableView.separatorColor = [UIColor grayColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    headerView.backgroundColor = self.tableView.separatorColor;
    headerView.alpha = 0.4f;
    [self.tableView setTableHeaderView:headerView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
    
}

- (void)setupContainView{
    [super setupContainView];
    [self setupTableView];
}

#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView{

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
        number = self.dataName.count;
    }
    return number;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *result = nil;
    CommonTextFieldTableViewCell *commomTextCell = [CommonTextFieldTableViewCell getUITableViewCell:tableView];
    result = commomTextCell;
    commomTextCell.detailLabel.text = self.dataName[indexPath.row];
    commomTextCell.contentTextField.placeholder = self.placeholderText[indexPath.row];
    [commomTextCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == 0) {
        self.emailTextField  = commomTextCell.contentTextField;
        self.emailTextField.delegate = self;
    }else if (indexPath.row == 1){
        self.passwordTextField = commomTextCell.contentTextField;
        self.passwordTextField.delegate = self;
        self.passwordTextField.secureTextEntry = YES;
    }else{
        commomTextCell.contentTextField.returnKeyType = UIReturnKeyDone;
        self.checkPasswordTextField = commomTextCell.contentTextField;
        self.checkPasswordTextField.delegate = self;
        self.checkPasswordTextField.secureTextEntry = YES;
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


    [self closeKeyBoard];

    RequestManager *manager = [RequestManager manager];

    NSString *year;
    NSString *month;
    NSString *day;
    //分别获取年月日
    if (self.lastProfileObject.birthday.length > 0) {
        year = [self.lastProfileObject.birthday substringToIndex:4];
        month = [self.lastProfileObject.birthday substringWithRange:NSMakeRange(5, 3)];
        day = [self.lastProfileObject.birthday substringFromIndex:8];
    }
    
    //将self改为弱引用的self
    __weak typeof(self) weakSelf = self;
    if (self.lastProfileObject.email && self.lastProfileObject.email.length > 0  && self.lastProfileObject.password && self.lastProfileObject.password.length > 0  && self.lastProfileObject.name && self.lastProfileObject.name.length > 0 ) {

                if (HTTPREQUEST_INVALIDREQUESTID != [manager registerUser:self.lastProfileObject.email password:self.lastProfileObject.password sex:self.lastProfileObject.isMale firstname:self.lastProfileObject.name lastname:self.lastProfileObject.name country:self.countryIndex birthday_y:year birthday_m:month birthday_d:day weeklymail:NO  finishHandler:^(BOOL success, RegisterItemObject * _Nonnull item, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
                    
                    @synchronized(self) {
                            if (success) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (weakSelf.profileImage.image) {
                                        [self upLoadHeaderPhoto];
                                        
                                    }else{
                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注册成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil ,nil];
                                        alertView.tag = 9009;
                                        [alertView show];
                                    }
                                });
    
                                

                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"注册失败  %@ \n  %@ 请重新注册",errnum,errmsg] delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil ,nil];
                                [alertView show];
                            });
                        }

                    }
          
                }]) {
                    


                    
                }
           
            
        
       
    }else{
        //弹出提示
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注册信息不能为空" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil ,nil];
        [alertView show];
        
    }

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 9009) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if (alertView.tag == 9010){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


//关闭键盘
- (void)closeKeyBoard {
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.checkPasswordTextField resignFirstResponder];
}


- (BOOL)upLoadHeaderPhoto{
    self.sessionManager = [SessionRequestManager manager];
    UploadHeaderPhoto *request = [[UploadHeaderPhoto alloc] init];
    request.fileName = self.profilePhoto;
    request.finishHandler = ^(BOOL success,NSString *error,NSString *errmsg){
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注册成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil ,nil];
                alertView.tag = 9010;
                [alertView show];
            });
        }
        


        
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        // 判断输入的字是否是回车，即按下return
        [textView resignFirstResponder];
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
        // 确认密码
        if (self.passwordTextField.text != self.checkPasswordTextField.text) {
            //提示两次密码错误,重新输入密码
            NSLog(@"请重新输入密码");
            self.passwordTextField.text = nil;
            self.checkPasswordTextField.text = nil;
            [self.passwordTextField becomeFirstResponder];
        }
        [self.checkPasswordTextField resignFirstResponder];
    }
    return YES;
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
