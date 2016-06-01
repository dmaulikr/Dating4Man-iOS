//
//  RegisterSecondStepViewController.h
//  dating
//
//  Created by lance on 16/3/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "MainViewController.h"
#import "RegisterItemObject.h"
#import "registerProfileObject.h"




@interface RegisterSecondStepViewController : KKViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) MainViewController* mainVC;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;
/** 模型数据 */
@property (nonatomic,strong) RegisterItemObject *registerItem;
/** 个人图片 */
@property (nonatomic,strong) UIImageView *profileImage;
/** 上一页的模型数据 */
@property (nonatomic,strong) RegisterProfileObject *lastProfileObject;
/** 上一页的国家 */
@property (nonatomic,assign) int countryIndex;
/** 个人图片文件名 */
@property (nonatomic,strong) NSString *profilePhoto;
/** 底部约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomNum;
/** 加载 */
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityLoad;
@end
