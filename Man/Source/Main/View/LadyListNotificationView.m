//
//  LadyListNotificationView.m
//  dating
//
//  Created by Calvin on 16/12/20.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyListNotificationView.h"

#define HideAnmationTime 5

@interface LadyListNotificationView ()

@end

@implementation LadyListNotificationView

+ (instancetype)initLadyListNotificationViewXibLoadUser:(LiveChatUserInfoItemObject *)user msg:(NSString *)msg {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:@"LadyListNotificationView" owner:nil options:nil];
    LadyListNotificationView* view = [nibs objectAtIndex:0];
    [view loadUser:user msg:msg];
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)loadUser:(LiveChatUserInfoItemObject *)user msg:(NSString *)msg
{
    self.ladyImageView.layer.cornerRadius = self.ladyImageView.frame.size.width/2;
    self.ladyImageView.layer.masksToBounds = YES;
    
    self.imageViewLoader = nil;
    // 头像
    // 显示默认头像
    [self.ladyImageView setImage:[UIImage imageNamed:@"ContactList-LadyImage-Default"]];
    // 停止旧的
    if(self.imageViewLoader ) {
        [self.imageViewLoader stop];
    }
    // 创建新的
    self.imageViewLoader = [ImageViewLoader loader];
    
    // 加载
    self.imageViewLoader.view = self.ladyImageView;
    self.imageViewLoader.url = user.imgUrl;
    self.imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:self.imageViewLoader.url];
    [self.imageViewLoader loadImage];
    
    self.nameLabel.text = user.userName;
    self.msgLabel.text = msg;
    
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1;
        }completion:^(BOOL finished) {
            [self performSelector:@selector(removeNotificationView) withObject:nil afterDelay:HideAnmationTime];
        }];
}
- (IBAction)cancalNotication:(id)sender {
    [self removeNotificationView];
}

- (void)removeNotificationView
{
    if (self) {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        }completion:^(BOOL finished) {
            [self.imageViewLoader stop];
            self.imageViewLoader = nil;
            [self removeFromSuperview];
        }];
    }
}


@end
