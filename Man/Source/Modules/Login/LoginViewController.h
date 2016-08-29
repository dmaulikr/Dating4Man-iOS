//
//  LoginViewController.h
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "GoogleAnalyticsViewController.h"

@interface LoginViewController : GoogleAnalyticsViewController

@property (nonatomic, weak) IBOutlet UIView* inputView;
@property (nonatomic, weak) IBOutlet UITextField* emailTextField;
@property (nonatomic, weak) IBOutlet UITextField* passwordTextField;
@property (nonatomic, weak) IBOutlet UIView* checkCodeView;
@property (nonatomic, weak) IBOutlet UITextField* checkcodeTextField;
@property (nonatomic, weak) IBOutlet UIImageView* checkcodeImageView;
@property (nonatomic, weak) IBOutlet UIButton* loginButton;
@property (nonatomic, weak) IBOutlet UIButton* signUpButton;
@property (weak, nonatomic) IBOutlet UIView *separated2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatedHeight;

/**
 *  验证码高度约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* checkCodeHight;

/**
 *  输入框高度约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* inputViewHeight;

/**
 *  输入框底部约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* inputViewBottom;

/**
 *  点击登陆
 *
 *  @param sender 响应控件
 */
- (IBAction)loginAction:(id)sender;

@end
