//
//  ChatLargeEmotionSelfTableViewCell.h
//  dating
//
//  Created by test on 16/9/22.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LargeEmotionShowView.h"

@class ChatLargeEmotionSelfTableViewCell;
@protocol ChatLargeEmotionSelfTableViewCellDelegate <NSObject>

@optional
/**  点击重试   */
- (void)chatLargeEmotionSelfTableViewCell:(ChatLargeEmotionSelfTableViewCell *)cell DidClickRetryBtn:(UIButton *)retryBtn;

@end


@interface ChatLargeEmotionSelfTableViewCell : UITableViewCell


/** 代理 */
@property (nonatomic,weak) id<ChatLargeEmotionSelfTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet LargeEmotionShowView *largeEmotionImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *sendingLoadingView;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
