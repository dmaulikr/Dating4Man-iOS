//
//  ContactListTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactListTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageViewTopFit *test;
@property (nonatomic, weak) IBOutlet UIImageViewTopFit *ladyImageView;
@property (nonatomic, weak) IBOutlet UIImageView *onlineImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic, weak) IBOutlet UIImageView *bookmarkImageView;
@property (nonatomic, weak) IBOutlet UIImageView *inchatImageView;
@property (nonatomic, strong) ImageViewLoader* imageViewLoader;

/**
 *  收藏width约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* bookmarkImageViewWidth;
/**
 *  收藏leading约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* bookmarkImageViewLeading;

/**
 *  在聊width约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* inchatImageViewWidth;
/**
 *  在聊leading约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* inchatImageViewLeading;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
+ (UIEdgeInsets)defaultInsets;

@end
