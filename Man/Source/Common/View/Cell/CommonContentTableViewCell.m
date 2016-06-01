//
//  CommonContentTableViewCell.m
//  dating
//
//  Created by lance on 16/3/10.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CommonContentTableViewCell.h"

@implementation CommonContentTableViewCell
//标识符
+ (NSString *)cellIdentifier{
    return @"CommonContentTableViewCell";
}
//根据算内容的高度
+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSString *)detailString {

    NSInteger height = 40;
    
    if(detailString.length > 0) {
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14], NSFontAttributeName, nil];
        
        height += [detailString boundingRectWithSize:CGSizeMake(width - 20, MAXFLOAT)
                                             options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                          attributes:dict context:nil].size.height;
    }
    height += 40;

    
    return height;

}

+ (CGFloat)heightForString:(UITextView *)textView andWidth:(CGFloat)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}


//创建cell
+ (id)getUITableViewCell:(UITableView *)tableView {
    CommonContentTableViewCell *cell = (CommonContentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[CommonContentTableViewCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[CommonContentTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.descriptionLabel.text = @"";
    
//    cell.detaiLabel.text = @"";
  
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

//点击自我描述编辑功能
- (IBAction)edit:(id)sender {
    if ([self.delegate respondsToSelector:@selector(commonContentCellBtnDidClick:)]) {
        [self.delegate commonContentCellBtnDidClick:self];
    }
}

@end
