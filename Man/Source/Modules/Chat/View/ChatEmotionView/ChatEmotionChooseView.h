//
//  ChatEmotionChooseView.h
//  dating
//
//  Created by Max on 16/5/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatEmotion.h"
#import "ChatSmallGradeEmotion.h"
#import "ChatEmotionCreditsCollectionViewLayout.h"

@class ChatEmotionChooseView;
@protocol ChatEmotionChooseViewDelegate <NSObject>
@optional

- (void)chatEmotionChooseView:(ChatEmotionChooseView *)chatEmotionChooseView didSelectNomalItem:(NSInteger)item;
- (void)chatEmotionChooseView:(ChatEmotionChooseView *)chatEmotionChooseView didSelectSmallItem:(ChatSmallGradeEmotion *)item;
@end

@interface ChatEmotionChooseView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

/**
 *  事件回调
 */
@property (weak,nonatomic) id<ChatEmotionChooseViewDelegate> delegate;

/**
 *  表情选择控件
 */
@property (weak,nonatomic) IBOutlet UICollectionView* emotionCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *smallEmotionCollectionView;

/**
 *  表情数组
 */
@property (retain) NSArray<ChatEmotion*>* emotions;
///** 默认表情界面的小高表数组 */
//@property (nonatomic,strong) NSArray<ChatSmallGradeEmotion *> *smallEmotions;
/** 默认表情界面的小高表数组 */
@property (nonatomic,strong) NSArray<ChatSmallGradeEmotion *> *smallEmotions;
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;

/**  */
@property (nonatomic,strong) ChatEmotionCreditsCollectionViewLayout *layout;


/**
 *  生成实例
 *
 *  @return <#return value description#>
 */
+ (instancetype)emotionChooseView:(id)owner;

/**
 *  刷新界面
 */
- (void)reloadData;

@end
