//
//  ChatViewController.h
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"

#import "ChatTitleView.h"
#import "ChatTextView.h"

@interface ChatViewController : KKViewController

/**
 *  消息列表
 */
@property (nonatomic, weak) IBOutlet UITableView* tableView;

/**
 *  输入框
 */
@property (nonatomic, weak) IBOutlet ChatTextView* textView;

/**
 *  头像
 */
@property (nonatomic, strong) UIImageView *personImageView;

/**
 *  买点控件
 */
@property (nonatomic, weak) IBOutlet UIView *addCreditsView;
@property (nonatomic, weak) IBOutlet UIButton *add8CreditButton;
@property (nonatomic, weak) IBOutlet UIButton *add16CreditButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottom;
@property (nonatomic, assign) CGFloat creditsAccount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addCreditsViewHeight;

/**
 *  女士信息
 */
@property (nonatomic, strong) NSString *womanId;
@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *photoURL;

@property (weak, nonatomic) IBOutlet KKCheckButton *emotionBtn;

/**
 *  点击发送
 *
 *  @param sender 响应控件
 */
- (IBAction)sendMsgAction:(id)sender;

/**
 *  点击购买8个信用点
 *
 *  @param sender 响应控件
 */
- (IBAction)buy8CreditAction:(id)sender;

/**
 *  点击购买16个信用点
 *
 *  @param sender 响应控件
 */
- (IBAction)buy16CreditAction:(id)sender;

@end
