//
//  CommonCreditTableViewCell.m
//  dating
//
//  Created by test on 16/7/1.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CommonCreditTableViewCell.h"

@implementation CommonCreditTableViewCell

+ (NSString *)cellIdentifier {
    return @"CommonCreditTableViewCell";
}

+ (NSInteger)cellHeight {
    return 74;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    CommonCreditTableViewCell *cell = (CommonCreditTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[CommonCreditTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[CommonCreditTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.bgView.layer.cornerRadius = 8.0f;
    cell.bgView.layer.masksToBounds = YES;
    cell.creditBtn.layer.cornerRadius = 8.0f;
    cell.creditBtn.layer.masksToBounds = YES;
    cell.titleLabel.text = @"";
    [cell.creditBtn setTitle:@"0.0" forState:UIControlStateNormal];

    
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
