//
//  LadyDetailNameTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LadyDetailNameTableViewCell;
@protocol LadyDetailNameTableViewCellDelegate <NSObject>

- (void)LadyDetailNameTableViewCellReportBtnClick:(LadyDetailNameTableViewCell *)cell;

@end

@interface LadyDetailNameTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *leftImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UILabel *countryLabel;

/** 代理 */
@property (nonatomic,weak) id<LadyDetailNameTableViewCellDelegate> delegate;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
