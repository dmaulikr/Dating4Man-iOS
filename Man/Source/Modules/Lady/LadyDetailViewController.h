//
//  LadyDetailViewController.h
//  dating
//
//  Created by Max on 16/2/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
@class QueryLadyListItemObject;

@interface LadyDetailViewController : KKViewController

@property (nonatomic, weak) IBOutlet PZPagingScrollView* pagingScrollView;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
/** 女士模型数据 */
@property (nonatomic,strong) QueryLadyListItemObject *itemObject;

/**
 *  点击举报
 *
 *  @param sender 响应控件
 */
- (IBAction)reportAction:(id)sender;

/**
 *  点击聊天
 *
 *  @param sender 响应控件
 */
- (IBAction)chatAction:(id)sender;

@end
