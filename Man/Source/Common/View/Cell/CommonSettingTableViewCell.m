//
//  CommonSettingTableViewCell.m
//  dating
//
//  Created by test on 16/6/30.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CommonSettingTableViewCell.h"

@implementation CommonSettingTableViewCell

+ (NSString *)cellIdentifier {
    return @"CommonSettingTableViewCell";
}

+ (NSInteger)cellHeight {
    return 74;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    CommonSettingTableViewCell *cell = (CommonSettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[CommonSettingTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[CommonSettingTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.bgView.layer.cornerRadius = 8.0f;
    cell.bgView.layer.masksToBounds = YES;
    cell.titleLabel.text = @"";
    cell.detailLabel.text = @"";
    [cell.detailButton setHidden:YES];
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
