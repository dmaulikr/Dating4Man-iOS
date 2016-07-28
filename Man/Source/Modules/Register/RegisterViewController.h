//
//  RegisterViewController.h
//  dating
//
//  Created by lance on 16/3/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "MainViewController.h"
#import "registerProfileObject.h"
#import "GoogleAnalyticsViewController.h"

@interface RegisterViewController : GoogleAnalyticsViewController

@property (nonatomic, weak) MainViewController* mainVC;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueBtnBottom;
@end
