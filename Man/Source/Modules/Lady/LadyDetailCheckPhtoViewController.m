//
//  LadyDetailCheckPhtoViewController.m
//  dating
//
//  Created by test on 16/11/10.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyDetailCheckPhtoViewController.h"

@interface LadyDetailCheckPhtoViewController ()<PZPagingScrollViewDelegate,ImageViewLoaderDelegate,PZPhotoViewDelegate>

@end

@implementation LadyDetailCheckPhtoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.pagingScrollView.pagingViewDelegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.pagingScrollView displayPagingViewAtIndex:self.photoIndex animated:NO];
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - 画廊回调 (PZPagingScrollViewDelegate)
- (Class)pagingScrollView:(PZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    return [PZPhotoView class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(PZPagingScrollView *)pagingScrollView {
    NSUInteger count = 0;
    count = self.ladyListArray.count;
    CGSize size = pagingScrollView.contentSize;
    size.height = CGRectGetHeight(pagingScrollView.frame);
    size.width = CGRectGetWidth(pagingScrollView.frame) * count;
    pagingScrollView.contentSize = size;
    //    pagingScrollView.alwaysBounceHorizontal = NO;
    return count;
}

- (UIView *)pagingScrollView:(PZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    CGFloat photoSizeHeight = CGRectGetHeight(pagingScrollView.frame);
    CGFloat photoSizeWidth = CGRectGetWidth(pagingScrollView.frame);
    PZPhotoView *photoView = [[PZPhotoView alloc] initWithFrame:CGRectMake(0, 0, photoSizeWidth, photoSizeHeight)];
 
//    PZPhotoView *photoView = [[PZPhotoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    photoView.imageViewContentMode = UIViewContentModeScaleAspectFit;

    
    return photoView; 
    
}

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    // 还原默认图片
    PZPhotoView* photoView = (PZPhotoView *)pageView;
    [photoView prepareForReuse];
    photoView.photoViewDelegate = self;
    photoView.pagingEnabled = YES;
    
    // 图片路径
    NSString* url = [self.ladyListArray objectAtIndex:index];
    // 停止旧的
    static NSString *imageViewLoaderKey = @"imageViewLoaderKey";
    ImageViewLoader* imageViewLoader = objc_getAssociatedObject(pageView, &imageViewLoaderKey);
    [imageViewLoader stop];
    
    // 创建新的
    imageViewLoader = [ImageViewLoader loader];
    objc_setAssociatedObject(pageView, &imageViewLoaderKey, imageViewLoader, OBJC_ASSOCIATION_RETAIN);
    
    // 加载图片
    imageViewLoader.delegate = self;
    imageViewLoader.view = photoView;
    imageViewLoader.url = url;
    imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:imageViewLoader.url];
    //     [self showLoading];
    [imageViewLoader loadImage];
}

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    //    self.photoIndex = index;
    //    NSLog(@"visiblePageView %@",pagingScrollView.visiblePageView);
    if (self.delegate && [self.delegate respondsToSelector:@selector(ladyDetailCheckPhtoViewController:didScrollToIndex:)]) {
        [self.delegate ladyDetailCheckPhtoViewController:self didScrollToIndex:index];
    }
    
}


#pragma mark - 照片手势处理回调

- (void)photoViewDidSingleTap:(PZPhotoView *)photoView {
    [self dismissViewControllerAnimated:NO completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)photoViewDidDoubleTap:(PZPhotoView *)photoView {
    
}

- (void)photoViewDidTwoFingerTap:(PZPhotoView *)photoView {
    
}

- (void)photoViewDidDoubleTwoFingerTap:(PZPhotoView *)photoView {
    
}

#pragma mark - 下载完成回调
- (void)loadImageFinish:(ImageViewLoader *)imageViewLoader success:(BOOL)success {
    if (success) {
        //        [self hideLoading];
    }else {
        
    }
    
}


@end
