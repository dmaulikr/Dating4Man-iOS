//
//  LadyDetailLockPhotoView.h
//  dating
//
//  Created by test on 16/11/7.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LadyDetailLockPhotoView;
@protocol LadyDetailLockPhotoViewDelegate <NSObject>

- (void)ladyDetailLockPhotoView:(LadyDetailLockPhotoView *)lockPhotoView didClickBtnAction:(id)sender;

@end


@interface LadyDetailLockPhotoView : UIView
@property (weak, nonatomic) IBOutlet UIImageViewTopFit *lockPhotoView;
@property (weak, nonatomic) IBOutlet UIButton *lockPhotoLabel;
/** 代理 */
@property (nonatomic,weak) id<LadyDetailLockPhotoViewDelegate> delegate;

+ (instancetype)ladyDetailLockPhotoView:(id)owner;
- (instancetype)initWithFrame:(CGRect)frame;
@end
