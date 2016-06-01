//
//  addCreditsViewController.h
//  dating
//
//  Created by lance on 16/3/8.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface AddCreditsViewController : KKViewController

@property (nonatomic,weak) IBOutlet UITableView *tableView;
/** 数据 */
@property (nonatomic,strong) NSArray *items;

@property (nonatomic, weak) MainViewController* mainVC;
@end
