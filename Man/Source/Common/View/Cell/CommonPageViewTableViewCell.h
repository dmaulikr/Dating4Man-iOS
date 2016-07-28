//
//  CommonPageViewTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonPageViewTableViewCell : UITableViewCell

//@property (nonatomic, weak) IBOutlet UIImageView* onlineImageView;
@property (weak, nonatomic) IBOutlet UIView *onlineView;
@property (nonatomic, weak) IBOutlet PZPagingScrollView* pagingScrollView;

+ (NSString *)cellIdentifier;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
