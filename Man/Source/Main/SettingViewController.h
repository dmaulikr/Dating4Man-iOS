//
//  SettingViewController.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "MainViewController.h"
#import "GoogleAnalyticsViewController.h"

@interface SettingViewController : GoogleAnalyticsViewController

@property (nonatomic, weak) IBOutlet UIImageView* imageViewHead;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) MainViewController* mainVC;
@property (nonatomic, weak) IBOutlet UIButton* navRightButton;
/**
 *  显示余额的view
 */
@property (weak, nonatomic) IBOutlet UIView *creditBar;
/**
 *  余额显示
 */
@property (weak, nonatomic) IBOutlet UIButton *creditsBalanceCount;
/**
 *  余额view的高度约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *creditBalanceHeight;
/**
 *  月费的view
 */
@property (weak, nonatomic) IBOutlet UIView *premiumView;
/**
 *  月费的高度约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *premiumViewHeight;
/**
 *  头部月费标识
 */
@property (weak, nonatomic) IBOutlet UIButton *premiumMark;
/**
 *  余额点击效果
 */
@property (weak, nonatomic) IBOutlet UIButton *buyCreditsBtn;
/**
 *  头部标识的底部
 */
@property (weak, nonatomic) IBOutlet UIView *premiumMarkView;



@end
