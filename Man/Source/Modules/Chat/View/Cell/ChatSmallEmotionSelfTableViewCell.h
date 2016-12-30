//
//  ChatSmallEmotionSelfTableViewCell.h
//  dating
//
//  Created by test on 16/11/22.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChatSmallEmotionSelfTableViewCell;
@protocol ChatSmallEmotionSelfTableViewCellDelegate <NSObject>

@optional
/**  点击重试   */
- (void)ChatSmallEmotionSelfTableViewCellDelegate:(ChatSmallEmotionSelfTableViewCell *)cell DidClickRetryBtn:(UIButton *)retryBtn;

@end


@interface ChatSmallEmotionSelfTableViewCell : UITableViewCell

/** 代理 */
@property (nonatomic,weak) id<ChatSmallEmotionSelfTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *smallEmotonImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *sendingLoadingView;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end
