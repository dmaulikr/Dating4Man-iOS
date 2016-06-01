//
//  CommonDetailAndAccessoryTableViewCell.h
//  dating
//
//  Created by lance on 16/3/8.
//   cell包含标题和辅助视图
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CommonDetailAndAccessoryTableViewCell.h"

@implementation CommonDetailAndAccessoryTableViewCell
//标识符
+ (NSString *)cellIdentifier{
    return @"CommonDetailAndAccessoryTableViewCell";
}
//高度
+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSString *)detailString accessoryString:(NSString *)accessoryString{
    NSInteger height = 5;
    
    if(detailString.length > 0) {
        NSDictionary *detailDict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName, nil];
        
        height += [detailString boundingRectWithSize:CGSizeMake(width - 20, MAXFLOAT)
                                             options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                          attributes:detailDict context:nil].size.height;
        
    }
    
    
    if (accessoryString.length > 0) {
        NSDictionary *accessoryDict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13],NSFontAttributeName, [UIColor grayColor],NSForegroundColorAttributeName ,nil];
        height += [detailString boundingRectWithSize:CGSizeMake(width - 20, MAXFLOAT)
                                             options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                          attributes:accessoryDict context:nil].size.height;
    }
    height += 5;
    
    
    return height;
}

//根据标识符生成
+ (id)getUITableViewCell:(UITableView *)tableView {
    CommonDetailAndAccessoryTableViewCell *cell = (CommonDetailAndAccessoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[CommonDetailAndAccessoryTableViewCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[CommonDetailAndAccessoryTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.detailLabel.text = @"";
    cell.accessoryLabel.text = @"";
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}



@end
