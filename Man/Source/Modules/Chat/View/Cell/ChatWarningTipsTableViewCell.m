//
//  ChatWarningTipsTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatWarningTipsTableViewCell.h"

@implementation ChatWarningTipsTableViewCell
+ (NSString *)cellIdentifier {
    return @"ChatWarningTipsTableViewCell";
}

+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSAttributedString *)detailString {
    NSInteger height = 20;
    
    if(detailString.length > 0) {
        CGRect rect = [detailString boundingRectWithSize:CGSizeMake(width - 50 - 16, MAXFLOAT)
                                                 options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        
        height += ceil(rect.size.height);
        
    }
    height += 20;
    
    return height;
}
+ (id)getUITableViewCell:(UITableView*)tableView {
    ChatWarningTipsTableViewCell *cell = (ChatWarningTipsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ChatWarningTipsTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[ChatWarningTipsTableViewCell cellIdentifier] owner:tableView options:nil];
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
