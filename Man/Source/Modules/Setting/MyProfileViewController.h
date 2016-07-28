//
//  MyProfileViewController.h
//  dating
//
//  Created by test on 16/6/8.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "GoogleAnalyticsViewController.h"

@interface MyProfileViewController : GoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *loadingView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottom;
@end
