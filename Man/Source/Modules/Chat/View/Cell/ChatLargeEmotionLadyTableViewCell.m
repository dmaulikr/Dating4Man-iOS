//
//  ChatLargeEmotionLadyTableViewCell.m
//  dating
//
//  Created by test on 16/9/22.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatLargeEmotionLadyTableViewCell.h"
#import "Masonry.h"

@implementation ChatLargeEmotionLadyTableViewCell

+ (NSString *)cellIdentifier {
    return @"ChatLargeEmotionLadyTableViewCell";
}

+ (NSInteger)cellHeight {
    return 120;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    ChatLargeEmotionLadyTableViewCell *cell = (ChatLargeEmotionLadyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ChatLargeEmotionLadyTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[ChatLargeEmotionLadyTableViewCell cellIdentifier] owner:tableView options:nil];
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

@end
