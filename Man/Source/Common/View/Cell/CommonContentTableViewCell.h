//
//  CommonContentTableViewCell.h
//  dating
//
//  Created by lance on 16/3/10.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommonContentTableViewCell;
@protocol CommonContentCellDelegate <NSObject>

@optional

/** 点击按钮操作 */
- (void)commonContentCellBtnDidClick:(CommonContentTableViewCell *)cell;

@end



@interface CommonContentTableViewCell : UITableViewCell
/** 个人详情 */
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
/** 编辑 */
@property (weak, nonatomic) IBOutlet UIButton *editBtn;

@property (weak, nonatomic) IBOutlet UITextView *detailText;
@property (weak, nonatomic) IBOutlet UIView *bgView;

/** 代理 */
@property (nonatomic, weak ) id<CommonContentCellDelegate> delegate;

//标识符
+ (NSString *)cellIdentifier;
//根据算内容的高度
+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSString *)detailString;
+ (NSInteger)cellHeight;
//创建cell
+ (id)getUITableViewCell:(UITableView*)tableView;



@end
