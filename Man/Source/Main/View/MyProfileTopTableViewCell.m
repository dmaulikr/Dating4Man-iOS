//
//  MyProfileTopTableViewCell.m
//  dating
//
//  Created by lance on 16/3/10.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "MyProfileTopTableViewCell.h"

@implementation MyProfileTopTableViewCell

//标识符
+ (NSString *)cellIdentifier{
    return @"MyProfileTopTableViewCell";
}


//高度
+ (NSInteger)cellHeight{
    return [UIScreen mainScreen].bounds.size.width;
}

//根据标识符创建
+ (id)getUITableViewCell:(UITableView *)tableView {
    MyProfileTopTableViewCell *cell = (MyProfileTopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[MyProfileTopTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[MyProfileTopTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.takePhotoBtn.layer.cornerRadius = cell.takePhotoBtn.frame.size.width * 0.5;
    cell.takePhotoBtn.layer.masksToBounds = YES;
    

    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


//点击拍照按钮操作
- (IBAction)recordPhoto:(id)sender {
    if ([self.delegate respondsToSelector:@selector(myProfileTopCellPhotoBtnDidClick:)]) {
        [self.delegate myProfileTopCellPhotoBtnDidClick:self];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    [self.contentView layoutSubviews];
}
@end
