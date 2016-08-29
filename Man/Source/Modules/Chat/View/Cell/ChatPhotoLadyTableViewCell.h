//
//  ChatPhotoLadyTableViewCell.h
//  dating
//
//  Created by test on 16/7/8.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "UIImageViewFitCell.h"

@class ChatPhotoLadyTableViewCell;
@protocol ChatPhotoLadyTableViewCellDelegate <NSObject>
@optional
/**  点击查看大图   */
- (void)ChatPhotoLadyTableViewCellDidLookPhoto:(ChatPhotoLadyTableViewCell *)cell;

@end


@interface ChatPhotoLadyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *secretPhoto;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageH;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingPhoto;
/** 代理 */
@property (nonatomic,weak) id<ChatPhotoLadyTableViewCellDelegate> delegate;

+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end
