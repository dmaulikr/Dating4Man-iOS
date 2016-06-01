//
//  CommonLeftTitleTableViewCell.h
//  dating
//
//  Created by lance on 16/3/10.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  左标题，右按钮

#import <UIKit/UIKit.h>

@interface CommonLeftTitleTableViewCell : UITableViewCell

/** 个人详情人物信息 */
@property (weak, nonatomic) IBOutlet UILabel *profileMessage;
/** 个人详情人物地点信息 */
@property (weak, nonatomic) IBOutlet UIButton *profileLocation;

//标识符号
+ (NSString *)cellIdentifier;
//高度
+ (NSInteger)cellHeight;
//根据标识符创建
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
