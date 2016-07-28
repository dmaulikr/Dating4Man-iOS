//
//  AppSettingContentViewController.h
//  dating
//
//  Created by test on 16/7/1.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "GoogleAnalyticsViewController.h"

@interface AppSettingContentViewController : GoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet UIView *chatNotificationView;
@property (weak, nonatomic) IBOutlet UIView *pushView;
@property (weak, nonatomic) IBOutlet UIView *appSettingView;
@property (weak, nonatomic) IBOutlet UILabel *notificationStatus;
@property (weak, nonatomic) IBOutlet UILabel *offerStatus;
@property (weak, nonatomic) IBOutlet UILabel *versonCode;

@end
