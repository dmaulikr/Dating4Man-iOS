//
//  CommonSpecialTitleTableViewCell.m
//  dating
//
//  Created by test on 16/6/22.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CommonSpecialTitleTableViewCell.h"

@implementation CommonSpecialTitleTableViewCell

+ (NSString *)cellIdentifier {
    return @"CommonSpecialTitleTableViewCell";
}

+ (NSInteger)cellHeight {
    return 74;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    CommonSpecialTitleTableViewCell *cell = (CommonSpecialTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[CommonSpecialTitleTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[CommonSpecialTitleTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.bgView.layer.cornerRadius = 8.0f;
    cell.bgView.layer.masksToBounds = YES;
    cell.titleLabel.text = @"";
    cell.detailLabel.text = @"";
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
