//
//  CommonTitleDetailTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CommonTitleDetailTableViewCell.h"

@implementation CommonTitleDetailTableViewCell
+ (NSString *)cellIdentifier {
    return @"CommonTitleDetailTableViewCell";
}

+ (NSInteger)cellHeight {
    return 56;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    CommonTitleDetailTableViewCell *cell = (CommonTitleDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[CommonTitleDetailTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[CommonTitleDetailTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
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
