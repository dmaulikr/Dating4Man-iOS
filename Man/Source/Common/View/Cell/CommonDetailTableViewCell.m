//
//  CommonDetailTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CommonDetailTableViewCell.h"

@implementation CommonDetailTableViewCell
+ (NSString *)cellIdentifier {
    return @"CommonDetailTableViewCell";
}

+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSString *)detailString {
    NSInteger height = 5;
    
    if(detailString.length > 0) {
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName, nil];
        
        height += [detailString boundingRectWithSize:CGSizeMake(width - 20, MAXFLOAT)
                                             options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                             attributes:dict context:nil].size.height;
    }
    height += 5;
    
    return height;
}

+ (NSInteger)cellHeight:(CGFloat)width detailAttributedString:(NSAttributedString *)detailString {
    NSInteger height = 5;
    
    if(detailString.length > 0) {
        CGRect rect = [detailString boundingRectWithSize:CGSizeMake(width - 20, MAXFLOAT)
                                                 options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        height += ceil(rect.size.height);

    }
    height += 5;
    
    return height;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    CommonDetailTableViewCell *cell = (CommonDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[CommonDetailTableViewCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[CommonDetailTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
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
