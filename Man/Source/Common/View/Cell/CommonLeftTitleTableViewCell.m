//
//  CommonLeftTitleTableViewCell.m
//  dating
//
//  Created by lance on 16/3/10.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CommonLeftTitleTableViewCell.h"

@implementation CommonLeftTitleTableViewCell
//标识符号
+ (NSString *)cellIdentifier {
    return @"CommonLeftTitleTableViewCell";
}
//高度
+ (NSInteger)cellHeight {
    return 74;
}
//根据标识符创建
+ (id)getUITableViewCell:(UITableView*)tableView {
    CommonLeftTitleTableViewCell *cell = (CommonLeftTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[CommonLeftTitleTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[CommonLeftTitleTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    
    cell.bgView.layer.cornerRadius = 8.0f;
    cell.bgView.layer.masksToBounds = YES;
    cell.profileMessage.text = @"";
    [cell.profileLocation setTitle:@"" forState:UIControlStateNormal];
    
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
