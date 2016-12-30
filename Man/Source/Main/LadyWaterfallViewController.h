//
//  LadyWaterfallViewController.h
//  dating
//
//  Created by Calvin on 16/12/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GoogleAnalyticsViewController.h"
#import "MainViewController.h"
#import "LadyWaterfallView.h"
#import "LadySearthView.h"
@interface LadyWaterfallViewController : GoogleAnalyticsViewController

/**
 *  导航栏
 */
@property (nonatomic, weak) MainViewController* mainVC;

/**
 *  瀑布流
 */
@property (weak, nonatomic) IBOutlet LadyWaterfallView *collectionView;

/**
 *  搜索界面
 */
@property (strong, nonatomic) LadySearthView * searthView;
@end
