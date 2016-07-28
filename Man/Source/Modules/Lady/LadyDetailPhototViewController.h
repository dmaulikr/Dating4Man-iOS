//
//  LadyDetailPhototViewController.h
//  dating
//
//  Created by ken Zhao on 16/5/29.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "GoogleAnalyticsViewController.h"

@interface LadyDetailPhototViewController : GoogleAnalyticsViewController

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

/** 图片数组 */
@property (nonatomic,strong) NSArray *ladyListArray;
/** 图片地址 */
@property (nonatomic,strong) NSArray *ladyListPath;
@property (weak, nonatomic) IBOutlet UILabel *errorMsg;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;

@property (weak, nonatomic) IBOutlet UIView *photoContentView;
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
/** 图片位置 */
@property (nonatomic,assign) NSInteger photoIndex;
/** 是否允许桂东 */
@property (nonatomic,assign) BOOL enableScroll;
@end
