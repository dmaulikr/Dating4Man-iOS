//
//  LadyListNotificationView.h
//  dating
//
//  Created by Calvin on 16/12/20.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveChatUserInfoItemObject.h"
@interface LadyListNotificationView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *notificationView;
@property (weak, nonatomic) IBOutlet UIImageViewTopFit *ladyImageView;
@property (nonatomic, strong) ImageViewLoader* imageViewLoader;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

+ (instancetype)initLadyListNotificationViewXibLoadUser:(LiveChatUserInfoItemObject *)user msg:(NSString *)msg;
@end
