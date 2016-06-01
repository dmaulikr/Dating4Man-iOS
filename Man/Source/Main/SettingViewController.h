//
//  SettingViewController.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "MainViewController.h"

@interface SettingViewController : KKViewController

@property (nonatomic, weak) IBOutlet UIImageView* imageViewHead;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) MainViewController* mainVC;
@property (nonatomic, weak) IBOutlet UIButton* navRightButton;
@property (weak, nonatomic) IBOutlet UILabel *CreditsBalanceCount;

@end
