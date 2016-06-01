//
//  CommonTextFieldTableViewCell.m
//  dating
//
//  Created by lance on 16/3/15.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CommonTextFieldTableViewCell.h"

@implementation CommonTextFieldTableViewCell

+ (NSString *)cellIdentifier {
    return @"CommonTextFieldTableViewCell";
}

+ (NSInteger)cellHeight {
    return 56;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    CommonTextFieldTableViewCell *cell = (CommonTextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[CommonTextFieldTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[CommonTextFieldTableViewCell cellIdentifier] owner:tableView options:nil];
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



@end
