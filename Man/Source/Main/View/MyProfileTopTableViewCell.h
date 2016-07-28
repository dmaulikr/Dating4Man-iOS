//
//  MyProfileTopTableViewCell.h
//  dating
//
//  Created by lance on 16/3/10.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyProfileTopTableViewCell;

@protocol MyProfileTopCellDelegate <NSObject>

@optional

//点击按钮操作
- (void)myProfileTopCellPhotoBtnDidClick:(MyProfileTopTableViewCell *)cell;

@end

@interface MyProfileTopTableViewCell : UITableViewCell

//标识符
+ (NSString *)cellIdentifier;
//高度
+ (NSInteger)cellHeight;
//根据标识符创建
+ (id)getUITableViewCell:(UITableView*)tableView;
/** 代理 */
@property (nonatomic, weak ) id<MyProfileTopCellDelegate> delegate;

//个人资料图片
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;

@end
