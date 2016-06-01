//
//  AppSettingViewController.m
//  dating
//
//  Created by test on 16/5/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "AppSettingViewController.h"


#import "CommonTitleDetailTableViewCell.h"
#import "AppSettingGroup.h"
#import "AppSettingRow.h"
#import <AudioToolbox/AudioToolbox.h>  

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


@interface AppSettingViewController ()<UIActionSheetDelegate,UIAlertViewDelegate>
/** 数据  */
@property (nonatomic,strong) NSArray *dataArray;

/** chat NotificationType */
@property (nonatomic,strong) NSString *notificationType;
/** push NotificationType */
@property (nonatomic,strong) NSString *pushNotificationType;
@end

@implementation AppSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadData:YES];
}


#pragma mark - 界面逻辑
- (void)initNavigationItems {

    self.customBackTitle = @"Setting";
}

- (void)setupNavigationBar{
    [super setupNavigationBar];
    UILabel *appSetting = [[UILabel alloc] init];
    appSetting.textColor = [UIColor whiteColor];
    appSetting.text = @"AppSetting";
    [appSetting sizeToFit];
    self.navigationItem.titleView = appSetting;
    
    
}


- (void)setupContainView {
    [super setupContainView];
    
    [self setupTableView];
}



- (void)setupTableView {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    headerView.backgroundColor = self.tableView.separatorColor;
    headerView.alpha = 0.4f;
    [self.tableView setTableHeaderView:headerView];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
    
    
    
}


- (void)reloadData:(BOOL)isReloadView{
    NSMutableArray *array = [NSMutableArray array];
    AppSettingGroup *group = [[AppSettingGroup alloc] init];
    group.groupTitle = @"NOTIFICATION";
    AppSettingRow *row1 = [[AppSettingRow alloc] init];
    row1.rowTitle = @"Chat Notification";
    row1.rowDetail = self.notificationType;
    AppSettingRow *row2 = [[AppSettingRow alloc] init];
    row2.rowTitle = @"Push news & offers";
    row2.rowDetail = self.pushNotificationType;
    group.groupData = @[row1,row2];
    [array addObject:group];
    
    
    group = [[AppSettingGroup alloc] init];
    group.groupTitle = @"APPLICATION";
    AppSettingRow *group2row1 = [[AppSettingRow alloc] init];
    group2row1.rowTitle = @"Clean cache";
    group2row1.rowDetail = @"";
//    AppSettingRow *group2row2 = [[AppSettingRow alloc] init];
//    group2row2.rowTitle = @"Check update";
//    group2row2.rowDetail = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    group.groupData = @[group2row1];
    [array addObject:group];
    
    
    self.dataArray = array;
    
    if( isReloadView ) {
        [self.tableView reloadData];
    }
}


#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger count = 0;
    
    if ([tableView isEqual:self.tableView]) {
        count = self.dataArray.count;
    }
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger dataCount = 0;
    
    if ([tableView isEqual:self.tableView]) {
        AppSettingGroup *group = self.dataArray[section];
        dataCount = group.groupData.count;
    }
    
    return dataCount;
    
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell *result = nil;
    CommonTitleDetailTableViewCell *cell = [CommonTitleDetailTableViewCell getUITableViewCell:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    AppSettingGroup *groupData = self.dataArray[indexPath.section];
    AppSettingRow *rowdata = groupData.groupData[indexPath.row];
    cell.titleLabel.text = rowdata.rowTitle;
    cell.detailLabel.text = rowdata.rowDetail;
    cell.titleLabel.textColor = [UIColor colorWithIntRGB:51 green:51 blue:51 alpha:255];
    cell.detailLabel.textColor = [UIColor colorWithIntRGB:179 green:179 blue:179 alpha:255];
    if (indexPath.section == 1 && indexPath.row == 0) {
        cell.leftImageView.image = [UIImage imageNamed:@"Setting-AppSettings"];
    }
    
    result = cell;
    
    return result;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    AppSettingGroup *groupData = self.dataArray[section];
    return groupData.groupTitle;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"NOTIFICATION" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Sound With Vibrate",@"Vibrate Only" ,@"Silent",@"Don`t Push", nil];
        [action showInView:self.view];
        action.tag = 301;
        
    }else if (indexPath.section == 0 && indexPath.row == 1){
            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"NOTIFICATION" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Sound With Vibrate",@"Vibrate Only" ,@"Silent",@"Don`t Push", nil];
        action.tag = 302;
            [action showInView:self.view];
        
    }else if (indexPath.section == 1 && indexPath.row == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you wish to clean the app cache" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"CANCEL", nil];
        alertView.tag = 303;
        [alertView show];
    }
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 301) {
        switch (buttonIndex) {
            case NoticeStyleSoundWithVibrate:{
//                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                self.notificationType = @"Sound With Vibrate";
                
            }break;
            case NoticeStyleVibrateOnly:{
                self.notificationType = @"Vibrate Only";
//                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }break;
            case NoticeStyleSilent:{
                self.notificationType = @"Silent";
                
            }break;
            case NoticeStyleNotPush:{
                self.notificationType = @"Don`t Push";
                
            }
            default:
                break;
        }
        [self reloadData:YES];
    }else if (actionSheet.tag == 302){
        switch (buttonIndex) {
            case NoticeStyleSoundWithVibrate:{
                //                UILocalNotification *local = [[UILocalNotification alloc] init];
                
                
                self.pushNotificationType = @"Sound With Vibrate";
            
            }break;
            case NoticeStyleVibrateOnly:{
                self.pushNotificationType = @"Vibrate Only";
                
            }break;
            case NoticeStyleSilent:{
                self.pushNotificationType = @"Silent";
                
            }break;
            case NoticeStyleNotPush:{
                self.pushNotificationType = @"Don`t Push";
                
            }
            default:
                break;
        }
         [self reloadData:YES];

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

