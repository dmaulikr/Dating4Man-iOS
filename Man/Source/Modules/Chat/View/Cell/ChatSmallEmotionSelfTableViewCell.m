//
//  ChatSmallEmotionSelfTableViewCell.m
//  dating
//
//  Created by test on 16/11/22.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatSmallEmotionSelfTableViewCell.h"

@implementation ChatSmallEmotionSelfTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier {
    return @"ChatSmallEmotionSelfTableViewCell";
}

+ (NSInteger)cellHeight {
    return 120;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    ChatSmallEmotionSelfTableViewCell *cell = (ChatSmallEmotionSelfTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ChatSmallEmotionSelfTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[ChatSmallEmotionSelfTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        

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
    if (self.delegate && [self.delegate respondsToSelector:@selector(ChatSmallEmotionSelfTableViewCellDelegate:DidClickRetryBtn:)]) {
        [self.delegate ChatSmallEmotionSelfTableViewCellDelegate:self DidClickRetryBtn:sender];
    }
    
}

@end
