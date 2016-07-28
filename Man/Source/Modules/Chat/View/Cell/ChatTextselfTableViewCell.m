//
//  ChatTextSelfTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatTextSelfTableViewCell.h"

@implementation ChatTextSelfTableViewCell
+ (NSString *)cellIdentifier {
    return @"ChatTextSelfTableViewCell";
}

+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSAttributedString *)detailString {
    NSInteger height = 15;
    
    if(detailString.length > 0) {
        CGRect rect = [detailString boundingRectWithSize:CGSizeMake(width - 125, MAXFLOAT)
                                   options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];

        height += ceil(rect.size.height);
    }
    height += 15;
    
    return height;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    ChatTextSelfTableViewCell *cell = (ChatTextSelfTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ChatTextSelfTableViewCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[ChatTextSelfTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.detailLabel.text = @"";
    cell.backgroundImageView.layer.cornerRadius = 21.0f;
    cell.backgroundImageView.layer.masksToBounds = YES;

    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    [self.detailLabel sizeToFit];
    
}

- (IBAction)retryBtnClick:(id)sender {
    if ( self.delegate && [self.delegate respondsToSelector:@selector(chatTextSelfRetryButtonClick:)] ) {
        [self.delegate chatTextSelfRetryButtonClick:self];
    }
}

@end
