//
//  LadyDetailLockPhotoView.m
//  dating
//
//  Created by test on 16/11/7.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyDetailLockPhotoView.h"

@implementation LadyDetailLockPhotoView


+ (instancetype)ladyDetailLockPhotoView:(id)owner {
    NSArray *nibs =  [[NSBundle mainBundle] loadNibNamedWithFamily:@"LadyDetailLockPhotoView" owner:owner options:nil];
    LadyDetailLockPhotoView *lockPhotoView = [nibs objectAtIndex:0];
    return lockPhotoView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self =  [[NSBundle mainBundle] loadNibNamedWithFamily:@"LadyDetailLockPhotoView" owner:self options:nil].firstObject;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.lockPhotoLabel.layer.cornerRadius = self.lockPhotoLabel.frame.size.height * 0.5;
    self.lockPhotoLabel.layer.masksToBounds = YES;
    self.lockPhotoLabel.titleLabel.numberOfLines = 0;
    self.lockPhotoLabel.adjustsImageWhenHighlighted = NO;

    
}
- (IBAction)btnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ladyDetailLockPhotoView:didClickBtnAction:)]) {
        [self.delegate ladyDetailLockPhotoView:self didClickBtnAction:sender];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
