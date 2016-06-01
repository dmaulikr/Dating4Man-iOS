//
//  ChatCouponTableViewCell.m
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatCouponTableViewCell.h"

@implementation ChatCouponTableViewCell
+ (NSString *)cellIdentifier {
    return @"ChatCouponTableViewCell";
}

+ (NSInteger)cellHeight {
    NSInteger height = 64;
    
    return height;
}
+ (id)getUITableViewCell:(UITableView*)tableView {
    ChatCouponTableViewCell *cell = (ChatCouponTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ChatCouponTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[ChatCouponTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.backgroundImageView.layer.cornerRadius = cell.backgroundImageView.frame.size.height / 8;
        cell.backgroundImageView.layer.masksToBounds = YES;
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
