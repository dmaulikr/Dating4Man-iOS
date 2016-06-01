//
//  ContactListTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactListTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *ladyImageView;
@property (nonatomic, weak) IBOutlet UIImageView *onlineImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic, weak) IBOutlet UIImageView *bookmarkImageView;
@property (nonatomic, weak) IBOutlet UIImageView *inchatImageView;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
+ (UIEdgeInsets)defaultInsets;

@end
