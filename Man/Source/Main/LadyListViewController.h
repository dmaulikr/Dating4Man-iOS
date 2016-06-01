//
//  LadyListViewController.h
//  dating
//
//  Created by Max on 16/2/15.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "LadyListTableView.h"
#import "MainViewController.h"

#import "AgeRangeSlider.h"

@interface LadyListViewController : KKViewController
#pragma mark - 界面控件
/**
 *  导航栏
 */
@property (nonatomic, weak) MainViewController* mainVC;
@property (nonatomic, weak) IBOutlet UIButton* navLeftButton;
@property (nonatomic, weak) IBOutlet BadgeButton* navRightButton;
/**
 *  女士列表
 */
@property (nonatomic, weak) IBOutlet LadyListTableView* tableView;
/**
 *  聊天按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *chatNowBtn;
/**
 *  搜索栏与view的顶部约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchTop;
/**
 *  性别选择器
 */
@property (weak, nonatomic) IBOutlet UISegmentedControl *sexSegment;
@property (weak, nonatomic) IBOutlet KKButtonBar *itemSelect;
/**
 *  在线状态选择器
 */
@property (weak, nonatomic) IBOutlet UISwitch *onlineStatusSelect;
/**
 *  搜索按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
/**
 *  年龄最小值文本
 */
@property (weak, nonatomic) IBOutlet UILabel *minValueLabel;
/**
 *  年龄最大值文本
 */
@property (weak, nonatomic) IBOutlet UILabel *maxValueLabel;
/**
 *  年龄选择器
 */
@property (weak, nonatomic) IBOutlet AgeRangeSlider *ageSlider;
/**
 *  条件搜索栏目
 */
@property (weak, nonatomic) IBOutlet UIView *searchTable;

#pragma mark - 界面事件
/**
 *  点击搜索栏选择器
 *
 *  @param sender <#sender description#>
 */
- (void)buttonBarAction:(id)sender;

/**
 *  记录选择的在线状态
 *
 *  @param sender <#sender description#>
 */
- (IBAction)onlineStatusChange:(id)sender;

/**
 *  搜素按钮点击弹出搜索栏
 *
 *  @param sender <#sender description#>
 */
- (IBAction)searchConfig:(id)sender;

/**
 *  搜索栏搜索按钮的点击
 *
 *  @param sender <#sender description#>
 */
- (IBAction)searchFinish:(id)sender;

/**
 *  点击聊天按钮
 *
 *  @param sender <#sender description#>
 */
- (IBAction)chatNowAction:(id)sender;

/**
 *  选择下个女士
 *
 *  @param sender <#sender description#>
 */
- (IBAction)backToLastLady:(id)sender;
@end
