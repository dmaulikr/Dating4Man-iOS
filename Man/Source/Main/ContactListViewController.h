//
//  ContactListViewController.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "ContactListTableView.h"
#import "MainViewController.h"

@interface ContactListViewController : KKViewController

@property (nonatomic, weak) IBOutlet KKButtonBar* kkButtonBar;
@property (nonatomic, weak) IBOutlet ContactListTableView* tableView;
@property (nonatomic, weak) MainViewController* mainVC;
@property (nonatomic, weak) IBOutlet UIButton* navLeftButton;

/**
 *  邀请条数
 */
@property (nonatomic, weak) IBOutlet UIButton *inviteCount;
@end
