//
//  LadyDetailCheckPhtoViewController.h
//  dating
//
//  Created by test on 16/11/10.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "GoogleAnalyticsViewController.h"

@class LadyDetailCheckPhtoViewController;
@protocol LadyDetailCheckPhtoViewControllerDelegate <NSObject>

- (void)ladyDetailCheckPhtoViewController:(LadyDetailCheckPhtoViewController *)checkPhotoViewController didScrollToIndex:(NSInteger)index;

@end


@interface LadyDetailCheckPhtoViewController : GoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet PZPagingScrollView *pagingScrollView;

/** 图片预览 */
@property (nonatomic,strong) PZPhotoView *photoView;

/** 图片数组 */
@property (nonatomic,strong) NSArray *ladyListArray;
/** 图片位置 */
@property (nonatomic,assign) NSInteger photoIndex;
/** 代理 */
@property (nonatomic,weak) id<LadyDetailCheckPhtoViewControllerDelegate> delegate;
@end
