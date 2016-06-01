//
//  LadyDetailPhototViewController.m
//  dating
//
//  Created by ken Zhao on 16/5/29.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyDetailPhototViewController.h"
#import "Reachability.h"

@interface LadyDetailPhototViewController ()<UIScrollViewDelegate>

/** 图片 */
@property (nonatomic,weak) UIImageView *ladyPhoto;

@end

@implementation LadyDetailPhototViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)setupContainView {
    [super setupContainView];
    
    
    if ([[self GetCurrntNet] isEqualToString:@"noReachable"] ) {
        self.retryBtn.layer.cornerRadius = 5.0f;
        self.retryBtn.layer.masksToBounds = YES;
        self.errorMsg.hidden = NO;
        self.retryBtn.hidden = NO;
        
    }else{
          [self setupScrollView];
        [self setupLoadingError];
    }
}


- (void)setupLoadingError{
    self.errorMsg.hidden = YES;
    self.retryBtn.layer.cornerRadius = 5.0f;
    self.retryBtn.layer.masksToBounds = YES;
    self.retryBtn.hidden = YES;
}


- (void)setupScrollView {
    
    
    self.photoScrollView.delegate = self;
    self.photoScrollView.pagingEnabled = YES;
    self.photoScrollView.showsVerticalScrollIndicator = NO;
    self.photoScrollView.showsHorizontalScrollIndicator = NO;
    self.loadingView.hidden = NO;
   
    self.pageControl.numberOfPages = self.ladyListArray.count;
    self.pageControl.hidden = YES;

    
    self.photoScrollView.contentSize =  CGSizeMake(self.ladyListArray.count * self.photoScrollView.sizeWidth, 0);
    NSMutableArray *imageViewLoaders = [NSMutableArray array];
    for (int i = 0; i < self.ladyListArray.count; i++) {
        ImageViewLoader *imageViewLoader = [[ImageViewLoader alloc] init];
        [imageViewLoaders addObject:imageViewLoader];
    }
    ImageViewLoader *imageViewLoader = [[ImageViewLoader alloc] init];
    
    if (self.ladyListArray.count > 0) {
        for (int i = 0; i < self.ladyListArray.count; i++) {
            CGRect frame = CGRectMake(self.photoScrollView.sizeWidth * i, 0, self.photoScrollView.sizeWidth, self.photoScrollView.sizeHeight);
            UIImageView *photoImage = [[UIImageView alloc] initWithFrame:frame];
            photoImage.contentMode = UIViewContentModeScaleAspectFit;
            UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
            photoImage.userInteractionEnabled = YES;
            
            
            [photoImage addGestureRecognizer:pinch];
            imageViewLoader = [imageViewLoaders objectAtIndex:i];
            imageViewLoader.view = photoImage;
            imageViewLoader.url = [self.ladyListArray objectAtIndex:i];
            imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:imageViewLoader.url];
            if ([self.ladyListPath containsObject:imageViewLoader.path] == YES) {
                self.ladyPhoto = (UIImageView *)imageViewLoader.view;
                self.ladyPhoto.image = [UIImage imageWithContentsOfFile:imageViewLoader.path];
                [self.photoScrollView addSubview:self.ladyPhoto];
            
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.loadingView.hidden = YES;
                });
//                [self.loadingView stopAnimating];
//                self.loadingView.hidden = YES;
            }else{
                if ([imageViewLoader loadImage]) {
                    [imageViewLoader loadImage];
                    

//                    [self.loadingView stopAnimating];
                    self.ladyPhoto = (UIImageView *)imageViewLoader.view;
                    [self.photoScrollView addSubview:self.ladyPhoto];
             
//                    self.loadingView.hidden = YES;
                }else{
                    

                    self.retryBtn.hidden = NO;
                    self.errorMsg.hidden = NO;
                }
          
            }
        }
    }
    
    
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
    if ([[self GetCurrntNet] isEqualToString:@"noReachable"] ) {
        self.retryBtn.layer.cornerRadius = 5.0f;
        self.retryBtn.layer.masksToBounds = YES;
        self.errorMsg.hidden = NO;
        self.retryBtn.hidden = NO;

        
    }else{
        [self setupScrollView];
        [self setupLoadingError];
    }
    
    
}
- (IBAction)closeAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 手势回调
- (void)pinchAction:(UIPinchGestureRecognizer *)recognizer{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}


@end
