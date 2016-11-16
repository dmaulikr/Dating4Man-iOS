//
//  ChatMoonFeeTableViewCell.m
//  dating
//
//  Created by test on 16/8/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatMoonFeeTableViewCell.h"

@implementation ChatMoonFeeTableViewCell
//标识符
+ (NSString *)cellIdentifier{
    return @"ChatMoonFeeTableViewCell";
}
//高度
+ (NSInteger)cellHeight{
    return 106;
}


//根据标识符生成
+ (id)getUITableViewCell:(UITableView *)tableView {
    ChatMoonFeeTableViewCell *cell = (ChatMoonFeeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ChatMoonFeeTableViewCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[ChatMoonFeeTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.premiumBtn.layer.cornerRadius = cell.premiumBtn.frame.size.height * 0.5;
    cell.premiumBtn.layer.masksToBounds = YES;
    cell.bgView.layer.cornerRadius = 8.0f;
    cell.bgView.layer.masksToBounds = YES;

    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (IBAction)goPremium:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatMoonFeeDidClickPremiumBtn:)]) {
        [self.delegate chatMoonFeeDidClickPremiumBtn:self];
    }
}

@end
