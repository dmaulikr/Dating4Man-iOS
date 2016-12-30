//
//  ChatNomalSmallEmotionView.m
//  dating
//
//  Created by test on 16/11/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatNomalSmallEmotionView.h"

#import <AVFoundation/AVFoundation.h>

@interface ChatNomalSmallEmotionView()

@end



@implementation ChatNomalSmallEmotionView




+ (instancetype)chatNormalSmallEmotionView:(id)owner {
    ChatNomalSmallEmotionView* view  = [[NSBundle mainBundle] loadNibNamedWithFamily:@"ChatNomalSmallEmotionView" owner:owner options:nil].firstObject;
    //    ChatNomalSmallEmotionView* view = [nibs objectAtIndex:0];
    
    
    view.pageView.numberOfPages = 0;
    view.pageView.currentPage = 0;
    
    view.pageScrollView.pagingEnabled = YES;
    view.pageScrollView.showsVerticalScrollIndicator = NO;
    view.pageScrollView.showsHorizontalScrollIndicator = NO;
    view.pageScrollView.delegate = view;
    
    view.emotionInputView = [ChatEmotionChooseView emotionChooseView:owner];
    // 小高表
    view.smallEmotionView = [ChatSmallEmotionView chatSmallEmotionView:owner];

    view.pageView.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    view.pageView.pageIndicatorTintColor = [UIColor lightGrayColor];
    
    return view;
}




- (void)awakeFromNib {
    [super awakeFromNib];
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    
    self.pageScrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    NSInteger lineCount = (self.frame.size.width - 60) / ( 60 + 10 ) + 1 ;
    
    
    NSUInteger pageItemCount = self.smallEmotionArray.count - lineCount;
    
    NSInteger page = pageItemCount / (lineCount * 2) + 1;
    
    
    self.pageView.numberOfPages = page + 1;
    self.pageView.currentPage = 0;
    
    self.emotionInputView.emotions = self.defaultEmotionArray;
    self.emotionInputView.smallEmotions = self.smallEmotionArray;
    
    
    
    
    NSMutableArray *smallArray = [NSMutableArray array];
    for (NSInteger i = lineCount; i < self.smallEmotionArray.count; i++) {
        [smallArray addObject:self.smallEmotionArray[i]];
    }
    self.smallEmotionView.smallEmotions = smallArray;
    
    
    
    self.pageScrollView.contentSize = CGSizeMake(self.frame.size.width * (page + 1), 0);
    
    for (int i = 0; i <= page; i++) {
        if (i == 0) {
            self.emotionInputView.frame = CGRectMake(i * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
            [self.pageScrollView addSubview:self.emotionInputView];
            continue;
        }
        self.smallEmotionView.frame = CGRectMake(i * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
        [self.pageScrollView addSubview:self.smallEmotionView];
        
        
    }
    
    
}


- (void)reloadData {
    [self.emotionInputView reloadData];
    [self.smallEmotionView reloadData];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatNormalSmallEmotionViewDidScroll:)]) {
        [self.delegate chatNormalSmallEmotionViewDidScroll:self];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatNormalSmallEmotionViewDidEndDecelerating:)]) {
        [self.delegate chatNormalSmallEmotionViewDidEndDecelerating:self];
    }
}

@end
