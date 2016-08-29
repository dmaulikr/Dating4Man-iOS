//
//  AppSettingContentViewController.m
//  dating
//
//  Created by test on 16/7/1.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "AppSettingContentViewController.h"
#import "LoginManager.h"
typedef enum : NSUInteger {
    NoticeStyleSoundWithVibrate ,
    NoticeStyleVibrateOnly,
    NoticeStyleSilent,
    NoticeStyleNotPush
} NoticeStyle;

typedef enum : NSUInteger {
    cacheCleanTypeOK,
    cacheCleanTypeCancel
    
} cacheCleanType;

typedef enum : NSUInteger {
    SettingTipNoteTypeNotification,
    SettingTipNoteTypePushAndOffers,
    SettingTipNoteTypeCleanUpNote,
} SettingTipNoteType;

@interface AppSettingContentViewController ()<UIAlertViewDelegate,UIActionSheetDelegate>

@end

@implementation AppSettingContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}



#pragma mark - 界面逻辑
- (void)setupContainView{
    [super setupContainView];
    
    self.chatNotificationView.layer.cornerRadius = 8.0f;
    self.chatNotificationView.layer.masksToBounds = YES;
    
    self.pushView.layer.cornerRadius = 8.0f;
    self.pushView.layer.masksToBounds = YES;
    
    self.appSettingView.layer.cornerRadius = 8.0f;
    self.appSettingView.layer.masksToBounds = YES;
    
    
    self.notificationStatus.text = @"Sound With Vibrate";
    self.offerStatus.text = @"Sound With Vibrate";
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *curVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    self.versonCode.text = [NSString stringWithFormat:@"Verson: %@",curVersion];

}



- (void)initCustomParam {
    // 初始化父类参数
    [super initCustomParam];
    self.backTitle = NSLocalizedString(@"", nil);
}

- (void)setupNavigationBar{
    [super setupNavigationBar];
    UILabel *appSetting = [[UILabel alloc] init];
    appSetting.textColor = [UIColor whiteColor];
    appSetting.text = NSLocalizedString(@"App  Setting", nil);
    [appSetting sizeToFit];
    self.navigationItem.titleView = appSetting;
    
    
}



#pragma mark - 按钮事件
- (IBAction)chatNotificationStatusChange:(id)sender {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"NOTIFICATION" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Sound With Vibrate",@"Vibrate Only" ,@"Silent",@"Don`t Push", nil];
    [action showInView:self.view];
    action.tag = 301;
}

- (IBAction)pushAndOffersStatusChange:(id)sender {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"NOTIFICATION" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Sound With Vibrate",@"Vibrate Only" ,@"Silent",@"Don`t Push", nil];
    action.tag = 302;
    [action showInView:self.view];
}

- (IBAction)cleanCacheAction:(id)sender {
    NSString *tips = NSLocalizedStringFromSelf(@"Tips_CleanCache");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:tips message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
    alertView.tag = 303;
    [alertView show];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 301) {
        switch (buttonIndex) {
            case NoticeStyleSoundWithVibrate:{
                //                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                self.notificationStatus.text = @"Sound With Vibrate";
                
            }break;
            case NoticeStyleVibrateOnly:{
                self.notificationStatus.text = @"Vibrate Only";
                //                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }break;
            case NoticeStyleSilent:{
                self.notificationStatus.text = @"Silent";
                
            }break;
            case NoticeStyleNotPush:{
                self.notificationStatus.text = @"Don`t Push";
                
            }
            default:
                break;
        }
    }else if (actionSheet.tag == 302){
        switch (buttonIndex) {
            case NoticeStyleSoundWithVibrate:{
                //                UILocalNotification *local = [[UILocalNotification alloc] init];
                
                
                self.offerStatus.text = @"Sound With Vibrate";
                
            }break;
            case NoticeStyleVibrateOnly:{
                self.offerStatus.text = @"Vibrate Only";
                
            }break;
            case NoticeStyleSilent:{
                self.offerStatus.text = @"Silent";
                
            }break;
            case NoticeStyleNotPush:{
                self.offerStatus.text = @"Don`t Push";
                
            }
            default:
                break;
        }
     
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 303) {
        switch (buttonIndex) {
            case cacheCleanTypeOK:{
                [self clearCache];
                
            }break;
            case cacheCleanTypeCancel:{
                
            }break;
            default:
                break;
        }
    }
}


- (void)clearCache{
    // for test
    if( AppDelegate().demo || AppDelegate().debug ) {
        [[LoginManager manager] logout:YES];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSString * path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        
        NSArray * files = [[NSFileManager defaultManager]subpathsAtPath:path];
        for (NSString * fileName in files) {
            
            NSError * error = nil;
            
            NSString * cachPath = [path stringByAppendingPathComponent:fileName];
            
            if ([[NSFileManager defaultManager]fileExistsAtPath:cachPath]) {
                
                [[NSFileManager defaultManager]removeItemAtPath:cachPath error:&error];
                
            }
            
        }
        
    });
}


@end
