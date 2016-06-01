//
//  LadyDetailNameTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyDetailNameTableViewCell.h"

@implementation LadyDetailNameTableViewCell
+ (NSString *)cellIdentifier {
    return @"LadyDetailNameTableViewCell";
}

+ (NSInteger)cellHeight {
    return 56;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LadyDetailNameTableViewCell *cell = (LadyDetailNameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LadyDetailNameTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[LadyDetailNameTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.titleLabel.text = @"";
    cell.detailLabel.hidden = NO;
    
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
