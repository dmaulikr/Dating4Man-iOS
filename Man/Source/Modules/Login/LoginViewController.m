//
//  LoginViewController.m
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginManager.h"
#import "RequestManager.h"
#import "RegisterViewController.h"
#import "LiveChatManager.h"



@interface LoginViewController () <LoginManagerDelegate> {
    CGRect _orgFrame;
    CGRect _newFrame;
}

@property (nonatomic, strong) LoginManager* manager;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
 
    _orgFrame = CGRectZero;
    _newFrame = CGRectZero;

    self.emailTextField.text = self.manager.email;
    self.passwordTextField.text = self.manager.password;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.hidden = YES;
    
    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 隐藏验证码
    [self hideCheckCode];
    
    // 判断是否登陆中
    switch (self.manager.status) {
        case NONE: {
            // 没登陆
            // 获取验证码
            [self getCheckCode];

        }break;
        case LOGINING:{
            // 登陆中
            [self showLoading];
            
            self.emailTextField.text = self.manager.lastInputEmail;
            self.passwordTextField.text = self.manager.lastInputPassword;
        }break;
        case LOGINED:{
            // 已经登陆
            
        }break;
        default:
            break;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 记录inputview原始大小
    if( CGRectIsEmpty(_orgFrame) ) {
       _orgFrame = self.inputView.frame;
        
    }

    // 是否用新frame
    if( !CGRectIsEmpty(_newFrame) ) {
        self.inputView.frame = _newFrame;
        
    }
    
}



#pragma mark - 界面逻辑
- (void)initCustomParam {
    [super initCustomParam];
    self.backTitle = NSLocalizedString(@"Login", nil);
    self.manager = [LoginManager manager];
    [self.manager addDelegate:self];
}

- (void)unInitCustomParam {
    [self.manager removeDelegate:self];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    
    // 标题
    UIButton* button = nil;
    UIImage* image = nil;
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    image = [UIImage imageNamed:@"Navigation-Qpid"];
    [button setImage:image forState:UIControlStateDisabled];
    [button setTitle:NSLocalizedString(@"QDating", nil) forState:UIControlStateNormal];
    [button sizeToFit];
    [button setEnabled:NO];
    self.navigationItem.titleView = button;
    
}

- (void)setupContainView {
    [super setupContainView];
    
    [self setupInputView];
    [self setupCheckCodeView];
}

- (void)setupInputView {
    // 初始化输入框
    self.inputView.layer.cornerRadius = 5.0f;
    self.inputView.layer.masksToBounds = YES;
    
    // 初始化注册按钮
    self.signUpButton.layer.cornerRadius = 5.0f;
    self.signUpButton.layer.masksToBounds = YES;
    
}

- (void)setupCheckCodeView {
    // 初始化验证码图片手势
    self.checkcodeImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCheckCodeImageViewSingleTap:)];
    [self.checkcodeImageView addGestureRecognizer:singleTap];
    
    // 默认图片
    [self.checkcodeImageView setImage:nil];



}

- (IBAction)loginAction:(id)sender {
    // 收起键盘
    [self closeKeyBoard];
    
    
    NSString *tipsEmail = NSLocalizedStringFromSelf(@"Tips_RegisterMessage_Email");
    NSString *tipsPassword = NSLocalizedStringFromSelf(@"Tips_RegisterMessage_Password");
    NSString *confirm = NSLocalizedStringFromSelf(@"OK");
    
    if (self.emailTextField.text.length == 0 ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tipsEmail delegate:self cancelButtonTitle:confirm otherButtonTitles:nil, nil];
        [alertView show];
        return;
        
    }
    if (self.passwordTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tipsPassword delegate:self cancelButtonTitle:confirm otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }

    if( [self.manager login:self.emailTextField.text password:self.passwordTextField.text checkcode:self.checkcodeTextField.text] == LOGINING ) {
        // 开始登陆
        [self showLoading];
    }
    
    if( self.manager.status == LOGINED ) {
        // 已经登陆
        KKNavigationController *nvc = (KKNavigationController* )self.navigationController;
        [nvc dismissViewControllerAnimated:YES completion:nil];
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}

- (IBAction)signupAccount:(id)sender {
    [self closeKeyBoard];
    RegisterViewController *registerView = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerView animated:YES];
    
}


- (void)handleCheckCodeImageViewSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    // 点击验证码
    [self getCheckCode];
}

- (void)closeKeyBoard {
    [self.emailTextField endEditing:YES];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField endEditing:YES];
    [self.passwordTextField resignFirstResponder];
    [self.checkcodeTextField endEditing:YES];
    [self.checkcodeTextField resignFirstResponder];
}

- (void)hideCheckCode {
    self.checkCodeHight.constant = 0;
    self.inputViewHeight.constant = 150;
//    self.separated2.hidden = YES;
    self.separatedHeight.constant = 0;
//    for(NSLayoutConstraint* lc in self.checkCodeView.constraints) {
//        if( [lc.identifier isEqualToString:@"secureCodeHight"] ) {
//            lc.constant = 0;
//            break;
//        }
//    }
}

- (void)showCheckCode {
    self.checkCodeHight.constant = 50;
    self.inputViewHeight.constant = 200;
//    self.separated2.hidden = NO;
    self.separatedHeight.constant = 1;
//    for(NSLayoutConstraint* lc in self.checkCodeView.constraints) {
//        if( [lc.identifier isEqualToString:@"secureCodeHight"] ) {
//            lc.constant = 50;
//            break;
//        }
//    }
}

#pragma mark - 数据逻辑
- (void)getCheckCode {
    RequestManager* manager = [RequestManager manager];
    [manager getCheckCode:^(BOOL success, const char * _Nullable data, int len, NSString * _Nonnull errnum, NSString * _Nonnull errmsg) {
        __block UIImage* image = [UIImage imageWithData:[NSData dataWithBytes:data length:len]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if( success )  {
                // 获取验证码成功
                if( len > 0 ) {
                    // 有验证码, 不能自动登陆
                    [self.checkcodeImageView setImage:image];
                    [self showCheckCode];
                } else {
                    // 无验证码
                    [self hideCheckCode];
    
                }

            } else {
                // 获取验证码失败
                
            }
        });
    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}



#pragma mark - 输入回调
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( self.emailTextField == textField ) {
        // 完成用户名
        [self.passwordTextField becomeFirstResponder];
        
    } else if( self.passwordTextField == textField ) {
        // 完成密码
        [self.checkcodeTextField becomeFirstResponder];
        
    } else {
        // 完成验证码
        [textField resignFirstResponder];
    }

    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.checkcodeTextField) {
        if (range.location >= 4) {
            return NO;
        }
    }

    return YES;
}



#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {    
    // Ensures that all pending layout operations have been completed
    [self.view layoutIfNeeded];
    
    if(height != 0) {
        // 弹出键盘
        self.inputViewBottom.constant = -height + self.signUpButton.frame.size.height;
        
    } else {
        // 收起键盘
        self.inputViewBottom.constant = -10;
        
    }
    
    [UIView animateWithDuration:duration animations:^{
        // Make all constraint changes here, Called on parent view
        [self.view layoutIfNeeded];
        
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

#pragma mark - 登陆管理器回调 (LoginManagerDelegate)
- (void)manager:(LoginManager *)manager onLogin:(BOOL)success loginItem:(LoginItemObject *)loginItem errnum:(NSString *)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LoginViewController::onLogin( success : %d )", success);
        [self hideLoading];
        
        if( success ) {
            // 登陆成功
            KKNavigationController *nvc = (KKNavigationController* )self.navigationController;
            [nvc dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            // 登陆失败
            if( [errnum isEqualToString:CHECKCODE_EMPTY] || [errnum isEqualToString:CHECKCODE_ERROR] ) {
                // 验证码为空/验证码无效
                // 重新获取验证码
                [self getCheckCode];
            }
            
            // 弹出提示
            if( errmsg.length > 0 ) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errmsg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
                [alertView show];
            }

        }
    });
}




- (void)manager:(LoginManager * _Nonnull)manager onLogout:(BOOL)kick {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LoginViewController::onLogout( kick : %d )", kick);
    });
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
