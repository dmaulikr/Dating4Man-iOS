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
    return 72;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    ContactListTableViewCell *cell = (ContactListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ContactListTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[ContactListTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.imageViewLoader = nil;
    }
    
    cell.ladyImageView.hidden = NO;
    cell.ladyImageView.layer.masksToBounds = YES;
    
    cell.onlineImageView.layer.masksToBounds = YES;
    
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
    
    [self.ladyImageView layoutIfNeeded];
    [self.onlineImageView layoutIfNeeded];
    
    self.ladyImageView.layer.cornerRadius = self.ladyImageView.frame.size.width * 0.5;
    self.onlineImageView.layer.cornerRadius = self.onlineImageView.frame.size.width * 0.5;
    
    [self.titleLabel sizeToFit];
    
    UIView *lastView = self.titleLabel;
    if( self.bookmarkImageView.hidden ) {
        self.bookmarkImageViewWidth.constant = 0;
        self.bookmarkImageViewLeading.constant = 0;
//        [self.bookmarkImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(@0);
//        }];
        
    } else {
        lastView = self.bookmarkImageView;
        self.bookmarkImageViewWidth.constant = 15;
        self.bookmarkImageViewLeading.constant = 10;
//        [self.bookmarkImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(@15);
//            make.left.equalTo(lastView.mas_right).with.offset(10);
//        }];

    }
    
    if( self.inchatImageView.hidden ) {
        self.inchatImageViewWidth.constant = 0;
        self.inchatImageViewLeading.constant = 0;
//        [self.inchatImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(@0);
//        }];
        
    } else {
        self.inchatImageViewWidth.constant = 15;
        self.inchatImageViewLeading.constant = 10;
//        [self.inchatImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(@15);
//            make.left.equalTo(lastView.mas_right).with.offset(10);
//        }];

    }
}
@end
