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
    
    self.manager = [LoginManager manager];
    [self.manager addDelegate:self];

 
    _orgFrame = CGRectZero;
    _newFrame = CGRectZero;

    self.emailTextField.text = self.manager.email;
    self.passwordTextField.text = self.manager.password;

//    self.emailTextField.text = @"CM46528572";
//    self.passwordTextField.text = @"123456";
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 判断是否登陆中
    switch (self.manager.status) {
        case NONE: {
            // 没登陆
            // 获取验证码
            [self getCheckCode];

        }break;
        case LOGINING:{
            // 登陆中
            self.loadingView.hidden = NO;
            
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
- (void)setupNavigationBar {
    [super setupNavigationBar];
    
    NSString *title = @"QDate";
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
}

- (void)setupContainView {
    [super setupContainView];
    
    [self setupInputView];
    [self setupLoadingView];
    [self setupCheckCodeView];
}

- (void)setupInputView {
    // 初始化输入框
    self.inputView.layer.cornerRadius = 5.0f;
    self.inputView.layer.masksToBounds = YES;
    
}

- (void)setupLoadingView {
    // 初始化菊花
    self.loadingView.layer.cornerRadius = 5.0f;
    self.loadingView.layer.masksToBounds = YES;
    self.loadingView.hidden = YES;
}

- (void)setupCheckCodeView {
    // 初始化验证码图片手势
    self.checkcodeImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCheckCodeImageViewSingleTap:)];
    [self.checkcodeImageView addGestureRecognizer:singleTap];
    
    // 默认图片
    [self.checkcodeImageView setImage:nil];

    // 隐藏验证码
    [self hideCheckCode];

}

- (IBAction)loginAction:(id)sender {
    // 收起键盘
    [self closeKeyBoard];
    
    if( [self.manager login:self.emailTextField.text password:self.passwordTextField.text checkcode:self.checkcodeTextField.text] ) {
        // 开始登陆
        self.loadingView.hidden = NO;
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
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.checkcodeTextField resignFirstResponder];
}

- (void)hideCheckCode {
    for(NSLayoutConstraint* lc in self.checkCodeView.constraints) {
        if( [lc.identifier isEqualToString:@"secureCodeHight"] ) {
            lc.constant = 0;
            break;
        }
    }
}

- (void)showCheckCode {
    for(NSLayoutConstraint* lc in self.checkCodeView.constraints) {
        if( [lc.identifier isEqualToString:@"secureCodeHight"] ) {
            lc.constant = 50;
            break;
        }
    }
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
                }

            } else {
                // 获取验证码失败
                
            }
        });
    }];
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

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration animations:^{
        if(height > 0) {
            // 弹出键盘
            _newFrame = CGRectMake(_orgFrame.origin.x, _orgFrame.origin.y - height, _orgFrame.size.width, _orgFrame.size.height);
            self.inputView.frame = _newFrame;
            
        } else {
            self.inputView.frame = _orgFrame;
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

#pragma mark - 登陆管理器回调 (LoginManagerDelegate)
- (void)manager:(LoginManager *)manager onLogin:(BOOL)success loginItem:(LoginItemObject *)loginItem errnum:(NSString *)errnum errmsg:(NSString *)errmsg {
    NSLog(@"LoginViewController::onLogin( success : %d )", success);
    self.loadingView.hidden = YES;
    if( success ) {
        // 登陆成功
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        // 登陆失败
        
    }
}


- (void)manager:(LoginManager * _Nonnull)manager onLogout:(BOOL)timeout {
    NSLog(@"LoginViewController::onLogout( timeout : %d )", timeout);
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
