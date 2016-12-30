//
//  ChatSmallEmotionLadyTableViewCell.m
//  dating
//
//  Created by test on 16/11/22.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatSmallEmotionLadyTableViewCell.h"

@implementation ChatSmallEmotionLadyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier {
    return @"ChatSmallEmotionLadyTableViewCell";
}

+ (NSInteger)cellHeight {
    return 120;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    ChatSmallEmotionLadyTableViewCell *cell = (ChatSmallEmotionLadyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ChatSmallEmotionLadyTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[ChatSmallEmotionLadyTableViewCell cellIdentifier] owner:tableView options:nil];
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

@end
