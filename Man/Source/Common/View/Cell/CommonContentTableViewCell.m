//
//  CommonContentTableViewCell.m
//  dating
//
//  Created by lance on 16/3/10.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CommonContentTableViewCell.h"

@interface CommonContentTableViewCell()<UITextViewDelegate>

@end


@implementation CommonContentTableViewCell
//标识符
+ (NSString *)cellIdentifier{
    return @"CommonContentTableViewCell";
}
//根据算内容的高度
+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSString *)detailString {

//    NSInteger height = 43;
    NSInteger height = 65;
    
    if(detailString.length > 0) {
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16], NSFontAttributeName, nil];
        
        CGRect rect= [detailString boundingRectWithSize:CGSizeMake(width - 40, MAXFLOAT)
                                             options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                          attributes:dict context:nil];

            height += ceil(rect.size.height);
    }
    
//    height += 6;
    height += 65;
    
    return height;


}

+ (NSInteger)cellHeight{
        return [UIScreen mainScreen].bounds.size.height * 0.5;
}

//创建cell
+ (id)getUITableViewCell:(UITableView *)tableView {
    CommonContentTableViewCell *cell = (CommonContentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[CommonContentTableViewCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[CommonContentTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    
    cell.bgView.layer.cornerRadius = 8.0f;
    cell.bgView.layer.masksToBounds = YES;
    cell.editBtn.layer.cornerRadius = 8.0f;
    cell.editBtn.layer.masksToBounds = YES;
    cell.descriptionLabel.text = @"";
    cell.detailText.text = nil;
    
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
