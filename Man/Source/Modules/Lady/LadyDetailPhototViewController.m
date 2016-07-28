//
//  LadyDetailPhototViewController.m
//  dating
//
//  Created by ken Zhao on 16/5/29.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyDetailPhototViewController.h"
#import "Reachability.h"

@interface LadyDetailPhototViewController ()<UIScrollViewDelegate,ImageViewLoaderDelegate>

/** 图片 */
@property (nonatomic,weak) UIImageView *ladyPhoto;

@end

@implementation LadyDetailPhototViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.closeBtn.layer.cornerRadius = self.closeBtn.frame.size.width * 0.5;
    self.closeBtn.layer.masksToBounds = YES;
  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//     [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)setupContainView {
    [super setupContainView];
    
    
    if ([[self GetCurrntNet] isEqualToString:@"noReachable"] ) {
        self.retryBtn.layer.cornerRadius = 5.0f;
        self.retryBtn.layer.masksToBounds = YES;
        self.errorMsg.hidden = NO;
        self.retryBtn.hidden = NO;
        
    }else{
             [self setupLoadingError];
          [self setupScrollView];
   
    }
}


- (void)setupLoadingError{
    self.errorMsg.hidden = YES;
    self.retryBtn.layer.cornerRadius = 5.0f;
    self.retryBtn.layer.masksToBounds = YES;
    self.retryBtn.hidden = YES;
}



- (void)setupScrollView {
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToClose)];
    [self.photoScrollView addGestureRecognizer:tap];
    
    
    self.photoScrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.photoScrollView.delegate = self;
    self.photoScrollView.pagingEnabled = YES;
    self.photoScrollView.showsVerticalScrollIndicator = NO;
    self.photoScrollView.showsHorizontalScrollIndicator = NO;
    self.loadingView.hidden = NO;
    BOOL result = self.enableScroll;
    self.photoScrollView.scrollEnabled = result;
   
    
    self.pageControl.numberOfPages = self.ladyListArray.count;
    self.pageControl.hidden = YES;
    
  
    
    self.photoScrollView.contentSize =  CGSizeMake(self.ladyListArray.count * self.photoScrollView.frame.size.width, 0);
    NSMutableArray *imageViewLoaders = [NSMutableArray array];
    for (int i = 0; i < self.ladyListArray.count; i++) {
        ImageViewLoader *imageViewLoader = [[ImageViewLoader alloc] init];
        [imageViewLoaders addObject:imageViewLoader];
    }
    ImageViewLoader *imageViewLoader = [[ImageViewLoader alloc] init];
    
    if (self.ladyListArray.count > 0) {
        for (int i = 0; i < self.ladyListArray.count; i++) {
            CGRect frame = CGRectMake(self.photoScrollView.frame.size.width * i, 0, self.photoScrollView.frame.size.width, self.photoScrollView.frame.size.height);
            UIImageView *photoImage = [[UIImageView alloc] initWithFrame:frame];
            photoImage.contentMode = UIViewContentModeScaleAspectFit;
//            UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
//            photoImage.userInteractionEnabled = YES;
//            [photoImage addGestureRecognizer:pinch];
//            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToClose)];
//            photoImage.userInteractionEnabled = YES;
//            [photoImage addGestureRecognizer:tap];
            
            
            imageViewLoader = [imageViewLoaders objectAtIndex:i];
            imageViewLoader.delegate = self;
            imageViewLoader.view = photoImage;
            imageViewLoader.url = [self.ladyListArray objectAtIndex:i];
            imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:imageViewLoader.url];
            if ([self.ladyListPath containsObject:imageViewLoader.path] == YES) {
                self.ladyPhoto = (UIImageView *)imageViewLoader.view;
                self.ladyPhoto.image = [UIImage imageWithContentsOfFile:imageViewLoader.path];
                if (self.ladyPhoto.image == nil) {
                    self.loadingView.hidden = YES;
                    self.retryBtn.layer.cornerRadius = 5.0f;
                    self.retryBtn.layer.masksToBounds = YES;
                    self.errorMsg.hidden = NO;
                    self.retryBtn.hidden = NO;
                }else{
                [self.photoScrollView addSubview:self.ladyPhoto];
                }
            

//                [self.loadingView stopAnimating];
//                self.loadingView.hidden = YES;
            }else{
             
                    [imageViewLoader loadImage];
                    

//                    [self.loadingView stopAnimating];
                    self.ladyPhoto = (UIImageView *)imageViewLoader.view;
                    [self.photoScrollView addSubview:self.ladyPhoto];
             
//                    self.loadingView.hidden = YES;
  
          
            }
        }
    }
//    if (self.ladyPhoto.image == nil) {
////        self.closeBtn.hidden = NO;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.loadingView.hidden = YES;
//            self.retryBtn.hidden = NO;
//            self.errorMsg.hidden = NO;
//        });
//    }
//    
    [self.photoScrollView setContentOffset:CGPointMake(self.photoScrollView.frame.size.width * self.photoIndex,0) animated:NO];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int pageNum =(int)(scrollView.contentOffset.x / scrollView.frame.size.width + 0.5);
    self.pageControl.currentPage = pageNum;
 
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGPoint offsetofScrollView = scrollView.contentOffset;
    [scrollView setContentOffset:offsetofScrollView];
}


#pragma mark - 获取网络状态
- (NSString *)GetCurrntNet{
    
    NSString *result;
    
    Reachability *reachabilityStatus = [Reachability reachabilityWithHostName:@"www.apple.com"];
    
    switch ([reachabilityStatus currentReachabilityStatus]) {
            
        case NotReachable:
            
            result = @"noReachable";
            
            break;
            
        case ReachableViaWWAN:
            
            result = @"mobileNetwork";
            
            break;
            
        case ReachableViaWiFi:
            
            result = @"wifi";
            
            break;
            
    }
    
    return result;
    
}
- (IBAction)retryAction:(id)sender {
    self.loadingView.hidden = NO;
    self.errorMsg.hidden = YES;
    self.retryBtn.hidden = YES;
//    if ([[self GetCurrntNet] isEqualToString:@"noReachable"] ) {
//        self.retryBtn.layer.cornerRadius = 5.0f;
//        self.retryBtn.layer.masksToBounds = YES;
//        self.errorMsg.hidden = NO;
//        self.retryBtn.hidden = NO;
//
//        
//    }else{
//          [self setupLoadingError];
//        [self setupScrollView];
//      
//    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self setupContainView];
    });
   
    
    
}
- (IBAction)closeAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

}


#pragma mark - 手势回调
//- (void)pinchAction:(UIPinchGestureRecognizer *)recognizer{
//    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
//    recognizer.scale = 1;
//}
- (void)clickToClose{
    [self dismissViewControllerAnimated:NO completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}


#pragma mark - 下载图片完成回调
- (void)loadImageFinish:(ImageViewLoader *)imageViewLoader success:(BOOL)success{
    self.loadingView.hidden = YES;
    self.ladyPhoto = (UIImageView *)imageViewLoader.view;
    if (success) {
          [self.photoScrollView addSubview:self.ladyPhoto];
    }else{
        self.retryBtn.layer.cornerRadius = 5.0f;
        self.retryBtn.layer.masksToBounds = YES;
        self.errorMsg.hidden = NO;
        self.retryBtn.hidden = NO;
    }
  
}

@end
