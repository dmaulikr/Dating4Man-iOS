//
//  MainViewController.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleAnalyticsViewController.h"

@interface MainViewController : GoogleAnalyticsViewController

@property (nonatomic, weak) IBOutlet PZPagingScrollView* pagingScrollView;

#pragma mark - 左右页面切换
/**
 *  切换到左页
 *
 *  @param sender 响应控件
 */
- (IBAction)pageLeftAction:(id)sender;

/**
 *  切换到右页
 *
 *  @param sender 响应控件
 */
- (IBAction)pageRightAction:(id)sender;

@end

