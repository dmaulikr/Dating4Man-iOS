//
//  ContactListTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ContactListTableViewCell.h"
#import "Masonry.h"

@implementation ContactListTableViewCell
+ (NSString *)cellIdentifier {
    return @"ContactListTableViewCell";
}

+ (NSInteger)cellHeight {
    return 56;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    ContactListTableViewCell *cell = (ContactListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ContactListTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[ContactListTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.ladyImageView.hidden = NO;
    cell.ladyImageView.layer.cornerRadius = cell.ladyImageView.sizeWidth * 0.5;
    cell.ladyImageView.layer.masksToBounds = YES;
    
    cell.onlineImageView.hidden = YES;
    cell.bookmarkImageView.hidden = YES;
    cell.inchatImageView.hidden = YES;
    cell.titleLabel.text = @"";
    cell.detailLabel.text = @"";
    
    return cell;
}

+ (UIEdgeInsets)defaultInsets {
    return UIEdgeInsetsMake(0, 64, 0, 0);
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
    
    [self.titleLabel sizeToFit];
    
    UIView *lastView = self.titleLabel;
    if( self.bookmarkImageView.hidden ) {
        [self.bookmarkImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@0);
        }];
        
    } else {
        [self.bookmarkImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@15);
            make.left.equalTo(lastView.mas_right).with.offset(10);
        }];
        lastView = self.bookmarkImageView;
    }
    
    if( self.inchatImageView.hidden ) {
        [self.inchatImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@0);
        }];
        
    } else {
        [self.inchatImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@15);
            make.left.equalTo(lastView.mas_right).with.offset(10);
        }];

    }
}
@end
