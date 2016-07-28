//
//  RegisterHeaderViewCell.h
//  dating
//
//  Created by test on 16/6/23.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RegisterHeaderViewCell;
@protocol RegisterHeaderViewCellDelegate <NSObject>

@optional

- (void)registerHeaderViewAddPhoto:(RegisterHeaderViewCell *)cell;


@end



@interface RegisterHeaderViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *addPhotoImageView;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoBtn;

@property (weak, nonatomic) IBOutlet UIImageView *headerPhoto;
/** 代理 */
@property (nonatomic,weak) id<RegisterHeaderViewCellDelegate> delegate;


+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end
