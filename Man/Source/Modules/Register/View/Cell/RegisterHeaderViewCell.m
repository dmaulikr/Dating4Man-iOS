//
//  RegisterHeaderViewCell.m
//  dating
//
//  Created by test on 16/6/23.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "RegisterHeaderViewCell.h"

@implementation RegisterHeaderViewCell

//标识符
+ (NSString *)cellIdentifier{
    return @"RegisterHeaderViewCell";
}


//高度
+ (NSInteger)cellHeight{
    return 200;
}

//根据标识符创建
+ (id)getUITableViewCell:(UITableView *)tableView {
    RegisterHeaderViewCell *cell = (RegisterHeaderViewCell *)[tableView dequeueReusableCellWithIdentifier:[RegisterHeaderViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[RegisterHeaderViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.addPhotoImageView.layer.cornerRadius = cell.addPhotoImageView.frame.size.width * 0.5f;
    cell.addPhotoImageView.layer.masksToBounds = YES;
    cell.addPhotoImageView.userInteractionEnabled = YES;
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(addHeaderAction:)];
    [cell.addPhotoImageView addGestureRecognizer:tap];
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}
- (IBAction)addHeaderAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(registerHeaderViewAddPhoto:)]) {
        [self.delegate registerHeaderViewAddPhoto:self];
    }
}

@end
