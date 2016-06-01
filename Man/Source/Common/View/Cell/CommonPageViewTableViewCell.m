//
//  CommonPageViewTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CommonPageViewTableViewCell.h"

@implementation CommonPageViewTableViewCell
+ (NSString *)cellIdentifier {
    return @"CommonPageViewTableViewCell";
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    CommonPageViewTableViewCell *cell = (CommonPageViewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[CommonPageViewTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[CommonPageViewTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.curIndex = 0;
        
    }
    
    cell.onlineView.layer.cornerRadius = 3.0f;
    cell.onlineView.layer.masksToBounds = YES;
    
        
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _curIndex = 0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
    [self.pagingScrollView displayPagingViewAtIndex:_curIndex animated:YES];
}

@end
