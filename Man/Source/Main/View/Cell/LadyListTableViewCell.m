//
//  LadyListTableViewCell.m
//  DrPalm4EBaby
//
//  Created by KingsleyYau on 13-9-5.
//  Copyright (c) 2013年 KingsleyYau. All rights reserved.
//

#import "LadyListTableViewCell.h"

@implementation LadyListTableViewCell
+ (NSString *)cellIdentifier {
    return @"LadyListTableViewCell";
}

+ (NSInteger)cellHeight {
    return 0;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LadyListTableViewCell *cell = (LadyListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LadyListTableViewCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LadyListTableViewCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    cell.loadingView.hidden = YES;
    cell.loadingActivity.hidden = YES;
    cell.ladyImageView.hidden = NO;
    cell.onlineImageView.hidden = YES;
    cell.leftLabel.text = @"";
    cell.rightlLabel.text = @"";
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if( self ) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
