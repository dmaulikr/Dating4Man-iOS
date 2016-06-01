//
//  RegisterViewController.h
//  dating
//
//  Created by lance on 16/3/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "MainViewController.h"
#import "registerProfileObject.h"

@interface RegisterViewController : KKViewController
@property (weak, nonatomic) IBOutlet UIImageView *choosePhotoImage;
@property (nonatomic, weak) MainViewController* mainVC;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
