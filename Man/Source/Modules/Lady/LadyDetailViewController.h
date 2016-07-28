//
//  LadyDetailViewController.h
//  dating
//
//  Created by Max on 16/2/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "GoogleAnalyticsViewController.h"

@class QueryLadyListItemObject;
@interface LadyDetailViewController : GoogleAnalyticsViewController

/**
 *  附件相册
 */
@property (nonatomic, weak) IBOutlet PZPagingScrollView* pagingScrollView;
/**
 *  详情分栏
 */
@property (nonatomic, weak) IBOutlet UITableView* tableView;
/**
 *  收藏按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *addFavouriesBtn;

/**
 *  女士列表Item
 */
@property (nonatomic, strong) NSString *womanId;

/**
 *  菊花
 */
@property (weak, nonatomic) IBOutlet UIView *loadingView;

/** 女士图片大图 */
@property (nonatomic,strong) UIImageView *ladyImageView;

/**
 *  聊天按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;

/** 女士列表头像 */
@property (nonatomic,strong) NSString *ladyListImageUrl;

/**
 *  聊天按钮是否直接返回
 */
@property (nonatomic) BOOL backToChat;

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
