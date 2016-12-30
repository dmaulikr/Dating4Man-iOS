//
//  ChatNomalSmallEmotionView.h
//  dating
//
//  Created by test on 16/11/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatSmallGradeEmotion.h"
#import "ChatEmotionChooseView.h"
#import "ChatSmallEmotionView.h"
@class ChatNomalSmallEmotionView;
@protocol ChatNormalSmallEmotionViewDelegate <NSObject>

@optional
- (void)chatNormalSmallEmotionViewDidScroll:(ChatNomalSmallEmotionView *)normalSmallView ;
- (void)chatNormalSmallEmotionViewDidEndDecelerating:(ChatNomalSmallEmotionView *)normalSmallView;
- (void)chatNormalSmallEmotionView:(ChatNomalSmallEmotionView *)normalSmallView didSelectNormalItem:(NSInteger)item;
- (void)chatNormalSmallEmotionView:(ChatNomalSmallEmotionView *)normalSmallView didSelectSmallItem:(ChatSmallGradeEmotion *)item;
@end



@interface ChatNomalSmallEmotionView : UIView<UIScrollViewDelegate,ChatSmallEmotionViewDelegate,ChatEmotionChooseViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *pageScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;
/** 小高表 */
@property (nonatomic,strong) ChatSmallEmotionView *smallEmotionView;
/** 普通和小高级表情 */
@property (nonatomic, strong) ChatEmotionChooseView *emotionInputView;


/** 代理 */
@property (nonatomic,weak) id<ChatNormalSmallEmotionViewDelegate> delegate;
/** 普通小高级表情 */
@property (nonatomic,strong) NSArray *smallEmotionArray;
/** 普通表情 */
@property (nonatomic,strong) NSArray *defaultEmotionArray;

+ (instancetype)chatNormalSmallEmotionView:(id)owner;

- (void)reloadData;

@end
