//
//  ChatLargeEmotionSelfTableViewCell.m
//  dating
//
//  Created by test on 16/9/22.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatLargeEmotionSelfTableViewCell.h"
#import "Masonry.h"

@implementation ChatLargeEmotionSelfTableViewCell

+ (NSString *)cellIdentifier {
    return @"ChatLargeEmotionSelfTableViewCell";
}
+ (NSInteger)cellHeight {
    return 120;
}
+ (id)getUITableViewCell:(UITableView*)tableView {
    ChatLargeEmotionSelfTableViewCell *cell = (ChatLargeEmotionSelfTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ChatLargeEmotionSelfTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[ChatLargeEmotionSelfTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.largeEmotionImageView = [LargeEmotionShowView largeEmotionShowView];
        [cell.view addSubview:cell.largeEmotionImageView];
        [cell.largeEmotionImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(cell.view);
            make.height.equalTo(cell.view);
            make.left.equalTo(cell.view);
            make.top.equalTo(cell.view);
        }];
    }
    
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (IBAction)retryBtnClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatLargeEmotionSelfTableViewCell:DidClickRetryBtn:)]) {
        [self.delegate chatLargeEmotionSelfTableViewCell:self DidClickRetryBtn:sender];
    }
}


@end
