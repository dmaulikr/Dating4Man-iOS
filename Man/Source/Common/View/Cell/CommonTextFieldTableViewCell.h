//
//  CommonTextFieldTableViewCell.h
//  dating
//
//  Created by lance on 16/3/15.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface CommonTextFieldTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UITextField *contentTextField;


+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
