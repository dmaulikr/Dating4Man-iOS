//
//  LoginViewController.h
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"

@interface LoginViewController : KKViewController

@property (nonatomic, weak) IBOutlet UIView* loadingView;
@property (nonatomic, weak) IBOutlet UIView* inputView;
@property (nonatomic, weak) IBOutlet UITextField* emailTextField;
@property (nonatomic, weak) IBOutlet UITextField* passwordTextField;
@property (nonatomic, weak) IBOutlet UIView* checkCodeView;
@property (nonatomic, weak) IBOutlet UITextField* checkcodeTextField;
@property (nonatomic, weak) IBOutlet UIImageView* checkcodeImageView;
@property (nonatomic, weak) IBOutlet UIButton* loginButton;
@property (nonatomic, weak) IBOutlet UIButton* signUpButton;

/**
 *  点击登陆
 *
 *  @param sender 响应控件
 */
- (IBAction)loginAction:(id)sender;

@end
