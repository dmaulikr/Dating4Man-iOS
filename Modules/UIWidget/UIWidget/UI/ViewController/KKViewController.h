//
//  KKViewController.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKViewController : UIViewController
@property (nonatomic, assign) BOOL viewDidAppearEver;

#pragma mark - 横屏切换
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)shouldAutorotate;
- (UIInterfaceOrientationMask)supportedInterfaceOrientations;

#pragma mark - 界面布局
- (void)initCustomParam;
- (void)setupNavigationBar;
- (void)setupContainView;
@end
